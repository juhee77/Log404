const STATIC_SAVE_KEY = 'log404-static-save-v1';
const STATIC_CASE_ID = 'case_001';

const stateStore = {
  sourceType: 'all',
  search: '',
  activeDocId: null,
  payload: null,
  runtimeMode: null,
  staticSession: null,
};

const els = {
  objective: document.getElementById('objective'),
  progress: document.getElementById('progress'),
  stageBadge: document.getElementById('stageBadge'),
  nextStep: document.getElementById('nextStep'),
  storyCurrentTitle: document.getElementById('storyCurrentTitle'),
  storyGoal: document.getElementById('storyGoal'),
  storyQuestion: document.getElementById('storyQuestion'),
  storyBeats: document.getElementById('storyBeats'),
  storyRoadmap: document.getElementById('storyRoadmap'),
  suspectBoard: document.getElementById('suspectBoard'),
  documentList: document.getElementById('documentList'),
  documentTitle: document.getElementById('documentTitle'),
  documentMetaTags: document.getElementById('documentMetaTags'),
  documentContent: document.getElementById('documentContent'),
  activityLog: document.getElementById('activityLog'),
  clueList: document.getElementById('clueList'),
  investigationPanelTitle: document.getElementById('investigationPanelTitle'),
  bookmarkList: document.getElementById('bookmarkList'),
  opsRail: document.getElementById('opsRail'),
  statusLine: document.getElementById('statusLine'),
  sourceFilter: document.getElementById('sourceFilter'),
  searchInput: document.getElementById('searchInput'),
  culpritInput: document.getElementById('culpritInput'),
  motiveInput: document.getElementById('motiveInput'),
  methodInput: document.getElementById('methodInput'),
  submitButton: document.getElementById('submitButton'),
  reportGuide: document.getElementById('reportGuide'),
  reportPresets: document.getElementById('reportPresets'),
  reportResult: document.getElementById('reportResult'),
  searchButton: document.getElementById('searchButton'),
  resetButton: document.getElementById('resetButton'),
  saveButton: document.getElementById('saveButton'),
  loadButton: document.getElementById('loadButton'),
};

function setStatus(message) {
  els.statusLine.textContent = message;
}

function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

function normalizeApiPath(path) {
  return path.replace(/^\/+/, '');
}

async function fetchJson(path) {
  const response = await fetch(path);
  if (!response.ok) {
    throw new Error(`Failed to fetch ${path}: ${response.status}`);
  }
  return response.json();
}

async function loadStaticData() {
  const chapterNumbers = [1, 2, 3, 4, 5];
  const chapterResults = await Promise.allSettled(
    chapterNumbers.map(async (chapter) => {
      const chapterId = `chapter_${String(chapter).padStart(2, '0')}`;
      const payload = await fetchJson(`./data/story/${chapterId}/${chapterId}_content_pack.json`);
      return [chapter, payload];
    })
  );

  const chapterPacks = Object.fromEntries(
    chapterResults
      .filter((result) => result.status === 'fulfilled')
      .map((result) => result.value)
  );

  const [caseData, storyBible, cluesData, tasksData, gatesData, documentsData] = await Promise.all([
    fetchJson(`./data/cases/${STATIC_CASE_ID}.json`),
    fetchJson('./data/story/season_01/story_bible.json'),
    fetchJson('./data/clues.json'),
    fetchJson('./data/investigation_tasks.json'),
    fetchJson('./data/chapter_gates.json'),
    fetchJson('./data/documents.json'),
  ]);

  return {
    caseData,
    storyBible,
    cluesData,
    tasksData,
    gatesData,
    documentsData,
    chapterPacks,
  };
}

function createStaticSession(data) {
  const documents = Object.fromEntries(
    data.documentsData.map((row) => [
      row.id,
      {
        doc_id: row.id,
        source_type: row.source_type,
        title: row.title,
        chapter: row.chapter,
        content: row.content,
      },
    ])
  );
  const clues = Object.fromEntries(
    data.cluesData.map((row) => [
      row.clue_id,
      {
        clue_id: row.clue_id,
        chapter: row.chapter,
        source_type: row.source_type,
        name: row.name,
        description: row.description,
        required_documents: row.required_documents,
      },
    ])
  );
  const tasks = Object.fromEntries(
    data.tasksData.map((row) => [
      row.task_id,
      {
        task_id: row.task_id,
        chapter: row.chapter,
        title: row.title,
        prompt: row.prompt,
        required_opened_documents: row.required_opened_documents,
        prerequisite_tasks: row.prerequisite_tasks,
        options: row.options,
        correct_option: row.correct_option,
        unlock_targets: row.unlock_targets,
        resolves_clue: row.resolves_clue,
        success_message: row.success_message,
        failure_message: row.failure_message,
      },
    ])
  );
  const chapterArc = Object.fromEntries(
    (data.storyBible.chapter_emotional_arc || []).map((row) => [row.chapter, row])
  );

  const session = {
    caseData: data.caseData,
    storyBible: data.storyBible,
    cluesData: data.cluesData,
    tasksData: data.tasksData,
    gatesData: data.gatesData,
    documentsData: data.documentsData,
    chapterPacks: data.chapterPacks,
    chapterArc,
    documents,
    clues,
    tasks,
    state: {
      case_id: data.caseData.case_id,
      case_title: data.caseData.title,
      objective: data.caseData.objective,
      current_chapter: 1,
      unlocked_documents: new Set(data.caseData.documents_unlocked),
      opened_documents: new Set(),
      bookmarks: new Set(),
      discovered_clues: new Set(),
      solved_tasks: new Set(),
    },
    activeDocId: null,
    lastMessage: '사건 파일을 펼쳤습니다. 좌측 문서를 열어 모순부터 확인하세요.',
    lastReportMessage: '최종 보고서는 아직 작성되지 않았습니다.',
    activityLog: ['사건 파일을 펼쳤습니다. 좌측 문서를 열어 모순부터 확인하세요.'],
  };

  function chapterNumber(chapterId) {
    if (!chapterId.startsWith('chapter_')) return null;
    return Number.parseInt(chapterId.split('_').at(-1), 10);
  }

  function storyBrief() {
    const maxChapter = Math.max(...Object.keys(session.chapterPacks).map(Number), session.state.current_chapter);
    const currentChapter = Math.min(session.state.current_chapter, maxChapter);
    const currentPack = session.chapterPacks[currentChapter] || {};
    const currentArc = session.chapterArc[currentChapter] || {};
    const roadmap = [];

    for (let chapter = currentChapter + 1; chapter <= Math.min(currentChapter + 2, maxChapter); chapter += 1) {
      const pack = session.chapterPacks[chapter] || {};
      const arc = session.chapterArc[chapter] || {};
      roadmap.push({
        chapter,
        title: pack.title || arc.title || `챕터 ${chapter}`,
        hook: pack.chapter_question || pack.story_goal || '',
        feelings: arc.player_feeling || pack.emotional_focus || [],
      });
    }

    return {
      current: {
        chapter: currentChapter,
        title: currentPack.title || currentArc.title || `챕터 ${currentChapter}`,
        story_goal: currentPack.story_goal || '',
        chapter_question: currentPack.chapter_question || '',
        emotional_focus: currentPack.emotional_focus || currentArc.player_feeling || [],
        screen_beats: currentPack.screen_beats || [],
      },
      roadmap,
    };
  }

  function listSourceTypes() {
    return [...new Set(Object.values(session.documents).map((doc) => doc.source_type))].sort();
  }

  function listDocuments({ sourceType = 'all', searchKeyword = '', bookmarksOnly = false } = {}) {
    const docIds = bookmarksOnly ? session.state.bookmarks : session.state.unlocked_documents;
    let docs = [...docIds]
      .map((docId) => session.documents[docId])
      .filter(Boolean);

    if (sourceType && sourceType !== 'all') {
      docs = docs.filter((doc) => doc.source_type === sourceType);
    }

    if (searchKeyword) {
      const keyword = searchKeyword.toLowerCase().trim();
      if (keyword) {
        docs = docs.filter((doc) => `${doc.title}\n${doc.content}`.toLowerCase().includes(keyword));
      }
    }

    return docs.sort((a, b) => (a.chapter - b.chapter) || a.doc_id.localeCompare(b.doc_id));
  }

  function listClues() {
    return Object.values(session.clues).sort((a, b) => (a.chapter - b.chapter) || a.clue_id.localeCompare(b.clue_id));
  }

  function listActiveTasks() {
    return Object.values(session.tasks)
      .filter((task) =>
        task.chapter === session.state.current_chapter
        && !session.state.solved_tasks.has(task.task_id)
        && task.prerequisite_tasks.every((taskId) => session.state.solved_tasks.has(taskId))
      )
      .sort((a, b) => a.task_id.localeCompare(b.task_id));
  }

  function reportReviewDocuments() {
    return [
      'chat_alice_late_help',
      'note_john_contingency_map',
      'log_alice_dm_read',
      'mail_alice_unsent_escalation',
    ];
  }

  function canSubmit() {
    return session.caseData.solution_conditions.every((clueId) => session.state.discovered_clues.has(clueId));
  }

  function investigationStage() {
    if (canSubmit()) return '최종 보고 단계';
    if (session.state.current_chapter <= 1) return '초기 진술 검증 단계';
    if (session.state.current_chapter === 2) return '용의선상 재정렬 단계';
    return '은폐 구조 재구성 단계';
  }

  function nextStep() {
    const activeTasks = listActiveTasks();
    if (activeTasks.length) {
      const task = activeTasks[0];
      const missingDocuments = task.required_opened_documents.filter((docId) => !session.state.opened_documents.has(docId));
      if (missingDocuments.length) {
        return `현재 조사 과제는 '${task.title}' 입니다. 먼저 ${missingDocuments.join(', ')} 문서를 열어 모순을 확인하세요.`;
      }
      return `현재 조사 과제는 '${task.title}' 입니다. 오른쪽 패널에서 가장 맞는 해석을 골라 다음 증거를 여세요.`;
    }

    const unsolved = listClues().filter((clue) => !session.state.discovered_clues.has(clue.clue_id));
    if (!unsolved.length) {
      return `세 단서를 모두 확보했습니다. 바로 제출하기보다 ${reportReviewDocuments().join(', ')} 문서를 다시 읽고, 내가 누구의 설명을 빌려 여기까지 왔는지 먼저 정리하세요.`;
    }

    const target = unsolved[0];
    const missingDocuments = target.required_documents.filter((docId) => !session.state.opened_documents.has(docId));
    const availableDocuments = missingDocuments.filter((docId) => session.state.unlocked_documents.has(docId));

    if (availableDocuments.length) {
      return `다음 표적 단서는 '${target.name}' 입니다. 먼저 ${availableDocuments.join(', ')} 문서를 열람해 근거를 모으세요.`;
    }

    if (!missingDocuments.length) {
      return `'${target.name}' 단서의 필수 문서를 모두 읽었습니다. 우측 단서 카드에서 추론 버튼을 눌러 정리하세요.`;
    }

    return `아직 '${target.name}' 단서에 필요한 문서가 잠겨 있습니다. 현재 챕터의 단서를 먼저 확정하면 다음 기록이 열립니다.`;
  }

  function reportGuidance() {
    if (!canSubmit()) {
      const remaining = listClues()
        .filter((clue) => !session.state.discovered_clues.has(clue.clue_id))
        .map((clue) => clue.name);
      return `최종 보고서는 세 단서를 모두 확보한 뒤 열립니다. 남은 정리 대상: ${remaining.join(', ')}`;
    }

    return `지금 필요한 건 새 증거가 아니라, 이미 읽은 기록을 누구의 말 없이 다시 읽는 일입니다. 보고서는 세 줄로 정리하면 됩니다. 범인에는 기록의 방향을 통제한 인물, 동기에는 왜 진실을 비틀었는지, 방법에는 어떤 로그/타임라인 조작이 있었는지를 적으세요. 추천 재검토: ${reportReviewDocuments().join(', ')}`;
  }

  function assessReport(culprit, motive, method) {
    const culpritValue = culprit.trim().toLowerCase();
    const culpritOk = ['alice', 'alice han', 'alice.h', '앨리스', '앨리스 한'].includes(culpritValue);
    const motiveOk = ['은폐', '보호', '통제', '죄책감', '감추'].some((token) => motive.includes(token));
    const methodOk = ['로그 조작', '캐시', '타임라인', '재작성', '기록 조작'].some((token) => method.includes(token));
    return { culpritOk, motiveOk, methodOk };
  }

  function ending(culprit, motive, method) {
    const assessment = assessReport(culprit, motive, method);
    if (assessment.culpritOk && assessment.motiveOk && assessment.methodOk) {
      return [
        '[진실 엔딩]',
        '당신은 범인, 동기, 수법을 모두 정확히 연결했다.',
        '앨리스는 존을 보호하고 자신이 설계한 해석 방향을 유지하려고 기록의 시간축을 비틀었다.',
        '공식 발표는 철회되고 내부 공모 정황은 별도 수사로 넘어간다.',
      ].join('\n');
    }

    return [
      '[부분 정답 엔딩]',
      '사건의 방향은 잡았지만 보고서가 아직 완성되지는 않았습니다.',
      '',
      '재검토 가이드',
      assessment.culpritOk
        ? '범인: 적절합니다.'
        : '범인: 플레이어를 돕는 척하면서 기록 접근권과 시간축 통제권을 동시에 가진 인물을 다시 보세요.',
      assessment.motiveOk
        ? '동기: 적절합니다.'
        : '동기: 단순한 적대감보다 보호, 은폐, 죄책감이 섞인 이유를 찾아야 합니다.',
      assessment.methodOk
        ? '방법: 적절합니다.'
        : '방법: 출입 기록, 인증 로그, VPN 재작성 흔적처럼 시간축을 비튼 조작 방식을 명시해야 합니다.',
      '',
      '추천 재열람 문서',
      '- chat_alice_late_help',
      '- note_john_contingency_map',
      '- log_alice_dm_read',
      '- mail_alice_unsent_escalation',
      '',
      '사건은 재조사로 넘어가고, 보고서가 모호한 탓에 일부 책임 소재는 흐려집니다.',
    ].join('\n');
  }

  function serializeDocument(doc) {
    return {
      doc_id: doc.doc_id,
      source_type: doc.source_type,
      title: doc.title,
      chapter: doc.chapter,
      opened: session.state.opened_documents.has(doc.doc_id),
      bookmarked: session.state.bookmarks.has(doc.doc_id),
    };
  }

  function serializeClue(clue) {
    const openedRequired = clue.required_documents.filter((docId) => session.state.opened_documents.has(docId)).length;
    const missingDocuments = clue.required_documents.filter((docId) => !session.state.opened_documents.has(docId));
    return {
      clue_id: clue.clue_id,
      name: clue.name,
      description: clue.description,
      chapter: clue.chapter,
      solved: session.state.discovered_clues.has(clue.clue_id),
      required_count: clue.required_documents.length,
      opened_required_count: openedRequired,
      missing_documents: missingDocuments,
      story_prompt: clueStoryPrompt(clue, missingDocuments),
      ready_to_infer: !missingDocuments.length && !session.state.discovered_clues.has(clue.clue_id),
    };
  }

  function serializeTask(task) {
    const missingDocuments = task.required_opened_documents.filter((docId) => !session.state.opened_documents.has(docId));
    return {
      task_id: task.task_id,
      title: task.title,
      prompt: task.prompt,
      chapter: task.chapter,
      required_documents: task.required_opened_documents,
      opened_required_count: task.required_opened_documents.length - missingDocuments.length,
      required_count: task.required_opened_documents.length,
      missing_documents: missingDocuments,
      ready_to_submit: !missingDocuments.length,
      options: task.options,
    };
  }

  function clueStoryPrompt(clue, missingDocuments) {
    const solved = session.state.discovered_clues.has(clue.clue_id);

    if (clue.clue_id === 'clue_empty_resignation') {
      if (solved) {
        return '회사가 만든 퇴사 서사는 깨졌습니다. 이제 누가 그 공백을 이용했는지 넘어갈 차례입니다.';
      }
      if (missingDocuments.length) {
        return '공식 공지와 미전송 초안의 감정 차이를 먼저 붙잡으세요.';
      }
      return '퇴사 통보가 아니라 검열된 마지막 문장인지 판단할 시점입니다.';
    }

    if (clue.clue_id === 'clue_jones_false_face') {
      if (solved) {
        return '존스는 여전히 거칠지만, 바로 그 점 때문에 너무 편한 범인처럼 소비됐습니다.';
      }
      if (missingDocuments.includes('note_security_jones_override') || missingDocuments.includes('note_john_contingency_map')) {
        return '존스를 더 강하게 의심하게 만드는 표면 기록과, 존이 남긴 대비 메모를 함께 읽어야 합니다.';
      }
      return '이제 존스를 향한 분노가 자연발생인지, 누군가가 정리해 준 감정인지 재구성하세요.';
    }

    if (clue.clue_id === 'clue_alice_tampered_truth') {
      if (solved) {
        return '도움과 조작이 같은 손에서 나왔습니다. 문제는 누가 범인인가보다 왜 그 방향을 믿었는가입니다.';
      }
      if (missingDocuments.includes('mail_alice_unsent_escalation')) {
        return '앨리스의 개입만으론 부족합니다. 그녀가 왜 보고를 미뤘는지 보여 주는 초안까지 읽어야 합니다.';
      }
      return '조작의 증거와 보호의 동기가 같은 인물에게서 나왔는지 읽을 차례입니다.';
    }

    return '';
  }

  function suspectBoard() {
    const discovered = session.state.discovered_clues;
    const hasJonesOverride = session.state.opened_documents.has('note_security_jones_override');
    const hasJohnPlan = session.state.opened_documents.has('note_john_contingency_map');
    const hasAliceDraft = session.state.opened_documents.has('mail_alice_unsent_escalation');

    return [
      {
        name: 'Alice Han',
        role: '플레이어 조력자 / 운영 접근권 보유',
        status: discovered.has('clue_alice_tampered_truth')
          ? '핵심 조작자'
          : hasAliceDraft
            ? '도움과 은폐를 함께 쥔 내부자'
            : '조력자인 척하는 고위험 인물',
        score: discovered.has('clue_alice_tampered_truth') ? 5 : hasAliceDraft ? 4 : 3,
        note: discovered.has('clue_alice_tampered_truth')
          ? 'DM 열람 기록, 재작성 흔적, 미전송 보고 초안이 겹치며 보호 욕망이 통제로 변질된 구조가 보인다.'
          : hasAliceDraft
            ? '미전송 보고 초안은 그녀가 숨기고 있음을 보여주지만, 출발점에 보호 충동과 망설임도 섞여 있다.'
            : '존의 기록에 먼저 접근할 수 있었던 인물인지 계속 확인해야 한다.',
      },
      {
        name: 'Jones',
        role: '거친 동료 / 초반 용의선상',
        status: discovered.has('clue_jones_false_face')
          ? '희생양에 가까움'
          : hasJonesOverride
            ? '폭주 직전의 유력 용의자'
            : '표면상 가장 수상함',
        score: discovered.has('clue_jones_false_face') ? 1 : hasJonesOverride ? 5 : 4,
        note: discovered.has('clue_jones_false_face')
          ? '보안 인계 메모와 반복 통화를 다시 읽으면, 위협보다 뒤늦은 수습과 차단 시도가 더 선명해진다.'
          : hasJonesOverride
            ? '수동 개방 요청 메모까지 보면 바로 범인으로 적고 싶어지지만, 아직 재해석 여지가 남아 있다.'
            : '거친 발언과 실제 행동 사이에 간극이 있는지 확인이 필요하다.',
      },
      {
        name: 'John Kim',
        role: '실종자 / 피해자',
        status: hasJohnPlan
          ? '사라지기 전 대비를 남긴 실종자'
          : discovered.has('clue_empty_resignation')
            ? '강요된 퇴사 서사'
            : '자발적 퇴사처럼 위장됨',
        score: 0,
        note: hasJohnPlan
          ? 'contingency_map은 존이 마지막까지 사건의 순서와 증거 보존을 설계하려 했음을 보여준다.'
          : discovered.has('clue_empty_resignation')
            ? '미전송 초안의 감정과 공식 퇴사 공지의 문체가 너무 다르다.'
            : '퇴사 서사가 지나치게 깔끔하다. 공백 자체가 단서일 수 있다.',
      },
    ];
  }

  function reportPresets() {
    if (!canSubmit()) return [];
    return [
      { field: 'culprit', label: '범인 힌트', value: '앨리스' },
      { field: 'motive', label: '동기 힌트', value: '존을 보호하려던 은폐와 죄책감' },
      { field: 'method', label: '방법 힌트', value: '로그 조작과 시간축 재작성' },
    ];
  }

  function snapshot(sourceType = 'all', searchKeyword = '') {
    const documentsList = listDocuments({ sourceType, searchKeyword }).map(serializeDocument);
    const bookmarks = listDocuments({ bookmarksOnly: true }).map(serializeDocument);
    const cluesList = listClues().map(serializeClue);
    const activeTasks = listActiveTasks().map(serializeTask);

    let activeDocument = null;
    if (session.activeDocId && session.documents[session.activeDocId] && session.state.unlocked_documents.has(session.activeDocId)) {
      const doc = session.documents[session.activeDocId];
      activeDocument = {
        ...serializeDocument(doc),
        content: `[${doc.doc_id}] ${doc.title}\n(source: ${doc.source_type})\n\n${doc.content}`,
      };
    }

    return {
      case_title: session.state.case_title,
      objective: session.state.objective,
      chapter: Math.min(session.state.current_chapter, 3),
      story_brief: storyBrief(),
      report_review_documents: reportReviewDocuments(),
      active_tasks: activeTasks,
      opened_count: session.state.opened_documents.size,
      clue_count: session.state.discovered_clues.size,
      total_clue_count: Object.keys(session.clues).length,
      bookmark_count: session.state.bookmarks.size,
      can_submit: canSubmit(),
      stage_label: investigationStage(),
      next_step: nextStep(),
      report_guidance: reportGuidance(),
      source_types: listSourceTypes(),
      last_message: session.lastMessage,
      last_report_message: session.lastReportMessage,
      activity_log: session.activityLog,
      suspects: suspectBoard(),
      report_presets: reportPresets(),
      documents: documentsList,
      bookmarks,
      clues: cluesList,
      active_document: activeDocument,
    };
  }

  function snapshotResponse(sourceType, searchKeyword, message) {
    return {
      message,
      state: snapshot(sourceType, searchKeyword),
    };
  }

  function recordActivity(message) {
    const headline = message.trim().split('\n')[0] || '알 수 없는 작업';
    const entry = `챕터 ${Math.min(session.state.current_chapter, 3)} · ${headline}`;
    session.activityLog = [entry, ...session.activityLog.slice(0, 6)];
  }

  function applyChapterGates() {
    const newlyUnlocked = [];
    let progressed = true;

    while (progressed) {
      progressed = false;
      session.gatesData.forEach((gate, index) => {
        const required = new Set(gate.required_clues);
        const unlocked = [...required].every((clueId) => session.state.discovered_clues.has(clueId));
        const targetChapter = index + 2;
        if (!unlocked || targetChapter <= session.state.current_chapter) {
          return;
        }

        gate.unlock_targets.forEach((docId) => {
          if (!session.state.unlocked_documents.has(docId)) {
            session.state.unlocked_documents.add(docId);
            newlyUnlocked.push(docId);
          }
        });

        session.state.current_chapter = targetChapter;
        progressed = true;
      });
    }

    return newlyUnlocked;
  }

  function openDocument(docId) {
    if (!session.state.unlocked_documents.has(docId)) {
      return `잠겨 있는 문서입니다: ${docId}`;
    }
    const doc = session.documents[docId];
    if (!doc) {
      return `문서를 찾을 수 없습니다: ${docId}`;
    }
    session.state.opened_documents.add(docId);
    session.activeDocId = docId;
    return `[${doc.doc_id}] ${doc.title}\n(source: ${doc.source_type})\n\n${doc.content}`;
  }

  function toggleBookmark(docId) {
    if (!session.state.unlocked_documents.has(docId)) {
      return `잠겨 있는 문서는 북마크할 수 없습니다: ${docId}`;
    }
    if (session.state.bookmarks.has(docId)) {
      session.state.bookmarks.delete(docId);
      return `북마크 해제: ${docId}`;
    }
    session.state.bookmarks.add(docId);
    return `북마크 추가: ${docId}`;
  }

  function inferClue(clueId) {
    const clue = session.clues[clueId];
    if (!clue) {
      return `알 수 없는 단서 ID: ${clueId}`;
    }
    if (Object.values(session.tasks).some((task) => task.resolves_clue === clueId && !session.state.solved_tasks.has(task.task_id))) {
      return '이 단서는 현재 조사 과제를 해결해야 확정할 수 있습니다.';
    }
    if (session.state.discovered_clues.has(clueId)) {
      return `이미 확보한 단서입니다: ${clue.name}`;
    }

    const missing = clue.required_documents.filter((docId) => !session.state.opened_documents.has(docId));
    if (missing.length) {
      return `근거 문서 열람이 부족합니다. 먼저 열어야 할 문서: ${missing.join(', ')}`;
    }

    session.state.discovered_clues.add(clueId);
    const unlocked = applyChapterGates();
    const lines = [`단서 확보: ${clue.name}`, `설명: ${clue.description}`];
    if (unlocked.length) {
      lines.push(`해금된 문서: ${unlocked.join(', ')}`);
    }
    if (canSubmit()) {
      lines.push(`재검토 권장: ${reportReviewDocuments().join(', ')}`);
      lines.push('지금 필요한 건 범인을 급히 적는 일보다, 내가 누구의 설명을 믿고 여기까지 왔는지 다시 읽는 일이다.');
    }
    return lines.join('\n');
  }

  function submitTaskAnswer(taskId, optionId) {
    const task = session.tasks[taskId];
    if (!task) {
      return `알 수 없는 조사 과제 ID: ${taskId}`;
    }
    if (session.state.solved_tasks.has(taskId)) {
      return `이미 해결한 조사 과제입니다: ${task.title}`;
    }
    if (!task.prerequisite_tasks.every((requiredId) => session.state.solved_tasks.has(requiredId))) {
      return `아직 잠겨 있는 조사 과제입니다: ${task.title}`;
    }

    const missingDocuments = task.required_opened_documents.filter((docId) => !session.state.opened_documents.has(docId));
    if (missingDocuments.length) {
      return `근거 문서 열람이 부족합니다. 먼저 열어야 할 문서: ${missingDocuments.join(', ')}`;
    }

    if (optionId !== task.correct_option) {
      return task.failure_message;
    }

    session.state.solved_tasks.add(taskId);
    const newlyUnlocked = [];
    task.unlock_targets.forEach((docId) => {
      if (!session.state.unlocked_documents.has(docId)) {
        session.state.unlocked_documents.add(docId);
        newlyUnlocked.push(docId);
      }
    });

    const lines = [`조사 과제 해결: ${task.title}`, task.success_message];
    if (task.resolves_clue && !session.state.discovered_clues.has(task.resolves_clue)) {
      const clue = session.clues[task.resolves_clue];
      session.state.discovered_clues.add(task.resolves_clue);
      if (clue) {
        lines.push(`단서 확보: ${clue.name}`);
        lines.push(`설명: ${clue.description}`);
      }
      const gateUnlocks = applyChapterGates();
      newlyUnlocked.push(...gateUnlocks);
    }

    if (newlyUnlocked.length) {
      lines.push(`해금된 문서: ${[...new Set(newlyUnlocked)].join(', ')}`);
    }

    return lines.join('\n');
  }

  function submitReport(culprit, motive, method) {
    if (!canSubmit()) {
      const remaining = listClues()
        .filter((clue) => !session.state.discovered_clues.has(clue.clue_id))
        .map((clue) => clue.name);
      return `아직 최종 보고서를 제출할 수 없습니다. 먼저 남은 단서를 확보하세요: ${remaining.join(', ')}`;
    }
    if (!culprit.trim() || !motive.trim() || !method.trim()) {
      return [
        '범인 / 동기 / 방법을 모두 입력해야 합니다.',
        '범인: 누가 기록의 방향을 통제했는가',
        '동기: 왜 진실을 감추거나 비틀었는가',
        '방법: 어떤 로그/타임라인 조작이 있었는가',
      ].join('\n');
    }
    return ending(culprit, motive, method);
  }

  function save() {
    const payload = {
      case_id: session.state.case_id,
      current_chapter: session.state.current_chapter,
      unlocked_documents: [...session.state.unlocked_documents].sort(),
      opened_documents: [...session.state.opened_documents].sort(),
      bookmarks: [...session.state.bookmarks].sort(),
      discovered_clues: [...session.state.discovered_clues].sort(),
      solved_tasks: [...session.state.solved_tasks].sort(),
      active_doc_id: session.activeDocId,
      last_report_message: session.lastReportMessage,
    };
    localStorage.setItem(STATIC_SAVE_KEY, JSON.stringify(payload));
    return '브라우저 저장 완료';
  }

  function load() {
    const raw = localStorage.getItem(STATIC_SAVE_KEY);
    if (!raw) {
      return '브라우저 저장 데이터가 없습니다.';
    }
    const payload = JSON.parse(raw);
    session.state.current_chapter = payload.current_chapter;
    session.state.unlocked_documents = new Set(payload.unlocked_documents);
    session.state.opened_documents = new Set(payload.opened_documents);
    session.state.bookmarks = new Set(payload.bookmarks);
    session.state.discovered_clues = new Set(payload.discovered_clues);
    session.state.solved_tasks = new Set(payload.solved_tasks || []);
    session.activeDocId = payload.active_doc_id || null;
    session.lastReportMessage = payload.last_report_message || session.lastReportMessage;
    return '브라우저 저장 데이터 불러오기 완료';
  }

  function dispatch(action, payload, sourceType, searchKeyword) {
    let message = '알 수 없는 작업';

    if (action === 'open') {
      const docId = payload.doc_id || '';
      message = openDocument(docId);
      session.lastMessage = message;
      recordActivity(`문서 열람: ${docId}`);
      return snapshotResponse(sourceType, searchKeyword, message);
    }

    if (action === 'bookmark') {
      message = toggleBookmark(payload.doc_id || '');
      session.lastMessage = message;
      recordActivity(message);
      return snapshotResponse(sourceType, searchKeyword, message);
    }

    if (action === 'infer') {
      message = inferClue(payload.clue_id || '');
      session.lastMessage = message;
      recordActivity(message);
      if ((payload.clue_id || '') === 'clue_alice_tampered_truth' && canSubmit()) {
        recordActivity('재독 필요: 누구의 설명을 믿고 여기까지 왔는지 다시 확인');
      }
      return snapshotResponse(sourceType, searchKeyword, message);
    }

    if (action === 'task') {
      message = submitTaskAnswer(payload.task_id || '', payload.option_id || '');
      session.lastMessage = message;
      recordActivity(message);
      return snapshotResponse(sourceType, searchKeyword, message);
    }

    if (action === 'save') {
      message = save();
      session.lastMessage = message;
      recordActivity('브라우저 저장');
      return snapshotResponse(sourceType, searchKeyword, message);
    }

    if (action === 'load') {
      message = load();
      session.lastMessage = message;
      recordActivity('브라우저 저장 데이터 복원');
      if (session.activeDocId && !session.state.unlocked_documents.has(session.activeDocId)) {
        session.activeDocId = null;
      }
      return snapshotResponse(sourceType, searchKeyword, message);
    }

    if (action === 'submit') {
      message = submitReport(payload.culprit || '', payload.motive || '', payload.method || '');
      session.lastMessage = message;
      session.lastReportMessage = message;
      recordActivity('최종 보고서 제출 시도');
      return snapshotResponse(sourceType, searchKeyword, message);
    }

    return snapshotResponse(sourceType, searchKeyword, message);
  }

  return {
    snapshotResponse,
    dispatch,
  };
}

async function initializeRuntime() {
  const params = new URLSearchParams({
    source_type: stateStore.sourceType,
    search: stateStore.search,
  });

  try {
    const response = await fetch(`api/state?${params.toString()}`);
    if (!response.ok) {
      throw new Error(`Server mode unavailable: ${response.status}`);
    }
    const payload = await response.json();
    stateStore.runtimeMode = 'server';
    applyPayload(payload);
    return;
  } catch (error) {
    const data = await loadStaticData();
    stateStore.runtimeMode = 'static';
    stateStore.staticSession = createStaticSession(data);
    applyPayload(stateStore.staticSession.snapshotResponse(stateStore.sourceType, stateStore.search, '정적 조사 모드 초기화 완료'));
  }
}

function applyPayload(payload) {
  stateStore.payload = payload.state;
  if (Object.prototype.hasOwnProperty.call(payload.state, 'active_document')) {
    stateStore.activeDocId = payload.state.active_document ? payload.state.active_document.doc_id : null;
  }
  render();
  setStatus(payload.message);
}

async function fetchState() {
  if (!stateStore.runtimeMode) {
    await initializeRuntime();
    return;
  }

  if (stateStore.runtimeMode === 'server') {
    const params = new URLSearchParams({
      source_type: stateStore.sourceType,
      search: stateStore.search,
    });
    const response = await fetch(`api/state?${params.toString()}`);
    const payload = await response.json();
    applyPayload(payload);
    return;
  }

  applyPayload(stateStore.staticSession.snapshotResponse(stateStore.sourceType, stateStore.search, '정적 조사 상태 갱신 완료'));
}

async function postAction(path, body = {}) {
  if (stateStore.runtimeMode === 'server') {
    const response = await fetch(normalizeApiPath(path), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ...body,
        source_type: stateStore.sourceType,
        search: stateStore.search,
      }),
    });
    const payload = await response.json();
    applyPayload(payload);
    return;
  }

  const action = normalizeApiPath(path).replace(/^api\//, '');
  applyPayload(
    stateStore.staticSession.dispatch(
      action,
      body,
      stateStore.sourceType,
      stateStore.search
    )
  );
}

function render() {
  const state = stateStore.payload;
  if (!state) return;

  document.body.dataset.chapter = String(state.chapter);
  document.body.dataset.reportReady = state.can_submit ? 'true' : 'false';
  document.body.dataset.runtimeMode = stateStore.runtimeMode || 'unknown';
  els.objective.textContent = `${state.case_title} / ${state.objective}`;
  els.stageBadge.textContent = state.stage_label;
  els.progress.textContent = `챕터 ${state.chapter}/3 · 열람 ${state.opened_count} · 단서 ${state.clue_count}/${state.total_clue_count} · 북마크 ${state.bookmark_count}`;
  els.nextStep.textContent = state.next_step;
  els.reportGuide.textContent = state.report_guidance;
  els.reportResult.textContent = state.last_report_message;
  els.submitButton.disabled = !state.can_submit;
  syncSourceTypes(state.source_types);

  renderStoryBrief(state.story_brief, state.report_review_documents, state.can_submit);
  renderSuspects(state.suspects);
  renderDocuments(state.documents, state.active_document);
  renderInvestigations(state.active_tasks, state.clues);
  renderBookmarks(state.bookmarks);
  renderOpsRail(state);
  renderDocumentViewer(state.active_document);
  renderActivityLog(state.activity_log);
  renderReportPresets(state.report_presets);
  setStatus(state.last_message);
}

function syncSourceTypes(sourceTypes) {
  const options = ['all', ...sourceTypes];
  const current = stateStore.sourceType;
  els.sourceFilter.innerHTML = options.map((value) => `
    <option value="${value}" ${value === current ? 'selected' : ''}>${value}</option>
  `).join('');
}

function formatStoryScreen(screen) {
  const labels = {
    dashboard: '대시보드',
    workspace: '워크스페이스',
    evidence_board: '증거 보드',
    report: '최종 보고',
    login: '로그인',
  };
  return labels[screen] || screen;
}

function renderStoryBrief(storyBrief, reviewDocuments = [], canSubmit = false) {
  const current = storyBrief?.current;
  if (!current) {
    els.storyCurrentTitle.textContent = '챕터 브리핑을 불러오지 못했습니다.';
    els.storyGoal.textContent = '';
    els.storyQuestion.textContent = '';
    els.storyBeats.innerHTML = '<div class="empty compact">서사 브리프 데이터가 없습니다.</div>';
    els.storyRoadmap.innerHTML = '';
    return;
  }

  els.storyCurrentTitle.textContent = `챕터 ${current.chapter}. ${current.title}`;
  els.storyGoal.textContent = current.story_goal;
  els.storyQuestion.textContent = current.chapter_question;

  els.storyBeats.innerHTML = (current.screen_beats || []).map((beat) => `
    <article class="story-beat">
      <div class="story-beat-screen">${escapeHtml(formatStoryScreen(beat.screen))}</div>
      <div>${escapeHtml(beat.beat)}</div>
    </article>
  `).join('');

  if (canSubmit) {
    els.storyRoadmap.innerHTML = `
      <article class="story-roadmap-item primary">
        <div class="story-roadmap-label">재검토 포인트</div>
        <strong>누가 범인인가보다, 누구의 설명을 믿고 여기까지 왔는가</strong>
        <p>보고서를 쓰기 전에 아래 기록을 다시 읽고 판단 순서를 재구성하세요.</p>
        <div class="story-roadmap-meta">재독 문서: ${escapeHtml((reviewDocuments || []).join(' / '))}</div>
      </article>
    `;
    return;
  }

  const roadmap = storyBrief.roadmap || [];
  if (!roadmap.length) {
    els.storyRoadmap.innerHTML = '<div class="empty compact">현재 MVP 범위의 마지막 챕터입니다.</div>';
    return;
  }

  els.storyRoadmap.innerHTML = roadmap.map((entry, index) => `
    <article class="story-roadmap-item ${index === 0 ? 'primary' : ''}">
      <div class="story-roadmap-label">${index === 0 ? '다음' : '다다음'}</div>
      <strong>챕터 ${entry.chapter}. ${escapeHtml(entry.title)}</strong>
      <p>${escapeHtml(entry.hook)}</p>
      ${(entry.feelings || []).length ? `<div class="story-roadmap-meta">감정 축: ${escapeHtml(entry.feelings.join(' / '))}</div>` : ''}
    </article>
  `).join('');
}

function renderOpsRail(state) {
  const runtimeLabel = stateStore.runtimeMode === 'static' ? 'Pages / Static' : 'Local Server';
  els.opsRail.innerHTML = `
    <div class="ops-chip">
      <span class="ops-chip-label">런타임</span>
      <strong>${escapeHtml(runtimeLabel)}</strong>
    </div>
    <div class="ops-chip">
      <span class="ops-chip-label">단계</span>
      <strong>${escapeHtml(state.stage_label)}</strong>
    </div>
    <div class="ops-chip">
      <span class="ops-chip-label">열람</span>
      <strong>${state.opened_count}</strong>
    </div>
    <div class="ops-chip">
      <span class="ops-chip-label">단서</span>
      <strong>${state.clue_count}/${state.total_clue_count}</strong>
    </div>
    <div class="ops-chip">
      <span class="ops-chip-label">북마크</span>
      <strong>${state.bookmark_count}</strong>
    </div>
  `;
}

function renderDocuments(documents, activeDocument) {
  if (!documents.length) {
    els.documentList.innerHTML = '<div class="empty">표시할 문서가 없습니다.</div>';
    return;
  }

  els.documentList.innerHTML = documents.map((doc) => {
    const isActive = activeDocument && activeDocument.doc_id === doc.doc_id;
    return `
      <article class="document-item ${isActive ? 'active' : ''}">
        <header>
          <strong>${escapeHtml(doc.title)}</strong>
          <span class="doc-meta">${doc.bookmarked ? '★' : '☆'} ${doc.opened ? '열람' : '미열람'}</span>
        </header>
        <div class="doc-meta">${escapeHtml(doc.doc_id)} · ${escapeHtml(doc.source_type)} · 챕터 ${doc.chapter}</div>
        <div class="document-actions">
          <button data-open-doc="${doc.doc_id}" class="accent">열기</button>
          <button data-bookmark-doc="${doc.doc_id}">${doc.bookmarked ? '북마크 해제' : '북마크'}</button>
        </div>
      </article>
    `;
  }).join('');

  els.documentList.querySelectorAll('[data-open-doc]').forEach((button) => {
    button.addEventListener('click', () => {
      stateStore.activeDocId = button.dataset.openDoc;
      postAction('/api/open', { doc_id: button.dataset.openDoc });
    });
  });

  els.documentList.querySelectorAll('[data-bookmark-doc]').forEach((button) => {
    button.addEventListener('click', () => postAction('/api/bookmark', { doc_id: button.dataset.bookmarkDoc }));
  });
}

function renderInvestigations(activeTasks, clues) {
  if (activeTasks.length) {
    els.investigationPanelTitle.textContent = '현재 조사 과제';
    els.clueList.innerHTML = activeTasks.map((task) => `
      <article class="clue-item active">
        <div class="clue-header">
          <strong>${escapeHtml(task.title)}</strong>
          <span class="clue-readiness ${task.ready_to_submit ? 'ready' : ''}">${task.ready_to_submit ? '제출 가능' : '조사 중'}</span>
        </div>
        <div class="clue-meta">${escapeHtml(task.task_id)} · 챕터 ${task.chapter}</div>
        <p>${escapeHtml(task.prompt)}</p>
        <div class="clue-progress">
          <div class="clue-progress-fill" style="width: ${(task.opened_required_count / task.required_count) * 100}%"></div>
        </div>
        <div class="clue-meta">필수 기록 ${task.opened_required_count}/${task.required_count}</div>
        ${task.missing_documents.length ? `<div class="clue-missing">먼저 열어야 할 문서: ${escapeHtml(task.missing_documents.join(', '))}</div>` : ''}
        <div class="document-actions">
          ${task.options.map((option) => `
            <button data-task-answer="${task.task_id}" data-task-option="${option.option_id}" class="${task.ready_to_submit ? 'accent' : ''}" ${task.ready_to_submit ? '' : 'disabled'}>
              ${escapeHtml(option.label)}
            </button>
          `).join('')}
        </div>
      </article>
    `).join('');

    els.clueList.querySelectorAll('[data-task-answer]').forEach((button) => {
      button.addEventListener('click', () => postAction('/api/task', {
        task_id: button.dataset.taskAnswer,
        option_id: button.dataset.taskOption,
      }));
    });
    return;
  }

  els.investigationPanelTitle.textContent = '확정 가능한 단서';
  els.clueList.innerHTML = clues.map((clue) => `
    <article class="clue-item ${clue.solved ? 'active' : ''}">
      <div class="clue-header">
        <strong>${escapeHtml(clue.name)}</strong>
        <span class="clue-readiness ${clue.ready_to_infer ? 'ready' : ''}">${clue.solved ? '확보 완료' : clue.ready_to_infer ? '추론 가능' : '조사 중'}</span>
      </div>
      <div class="clue-meta">${escapeHtml(clue.clue_id)} · 챕터 ${clue.chapter} · ${clue.solved ? '확보' : '미확보'}</div>
      <p>${escapeHtml(clue.description)}</p>
      ${clue.story_prompt ? `<div class="clue-missing">${escapeHtml(clue.story_prompt)}</div>` : ''}
      <div class="clue-progress">
        <div class="clue-progress-fill" style="width: ${(clue.opened_required_count / clue.required_count) * 100}%"></div>
      </div>
      <div class="clue-meta">필수 근거 ${clue.opened_required_count}/${clue.required_count}</div>
      ${clue.missing_documents.length ? `<div class="clue-missing">남은 문서: ${escapeHtml(clue.missing_documents.join(', '))}</div>` : ''}
      <div class="clue-actions">
        <button data-infer-clue="${clue.clue_id}" class="accent">${clue.solved ? '다시 확인' : '추론'}</button>
      </div>
    </article>
  `).join('');

  els.clueList.querySelectorAll('[data-infer-clue]').forEach((button) => {
    button.addEventListener('click', () => postAction('/api/infer', { clue_id: button.dataset.inferClue }));
  });
}

function renderSuspects(suspects) {
  els.suspectBoard.innerHTML = suspects.map((suspect) => `
    <article class="suspect-card score-${suspect.score}">
      <header>
        <div>
          <strong>${escapeHtml(suspect.name)}</strong>
          <div class="suspect-role">${escapeHtml(suspect.role)}</div>
        </div>
        <span class="suspect-score">의심 ${suspect.score}/5</span>
      </header>
      <div class="suspect-status">${escapeHtml(suspect.status)}</div>
      <p>${escapeHtml(suspect.note)}</p>
    </article>
  `).join('');
}

function renderBookmarks(bookmarks) {
  if (!bookmarks.length) {
    els.bookmarkList.innerHTML = '<div class="empty">북마크된 문서가 없습니다.</div>';
    return;
  }

  els.bookmarkList.innerHTML = bookmarks.map((doc) => `
    <article class="bookmark-item ${stateStore.activeDocId === doc.doc_id ? 'active' : ''}">
      <header>
        <strong>${escapeHtml(doc.title)}</strong>
        <span class="bookmark-meta">${escapeHtml(doc.source_type)}</span>
      </header>
      <div class="bookmark-actions">
        <button data-open-bookmark="${doc.doc_id}" class="accent">열기</button>
      </div>
    </article>
  `).join('');

  els.bookmarkList.querySelectorAll('[data-open-bookmark]').forEach((button) => {
    button.addEventListener('click', () => {
      stateStore.activeDocId = button.dataset.openBookmark;
      postAction('/api/open', { doc_id: button.dataset.openBookmark });
    });
  });
}

function renderDocumentViewer(documentData) {
  if (!documentData) {
    els.documentTitle.textContent = '문서를 선택하세요';
    els.documentMetaTags.innerHTML = '<span class="tag">열람 대기</span>';
    els.documentContent.textContent = '좌측 문서를 클릭하면 기록 전문이 여기에 표시됩니다.';
    return;
  }
  stateStore.activeDocId = documentData.doc_id;
  els.documentTitle.textContent = `${documentData.title} / ${documentData.doc_id}`;
  els.documentMetaTags.innerHTML = `
    <span class="tag alert-tag">Evidence Focus</span>
    <span class="tag">${escapeHtml(documentData.source_type)}</span>
    <span class="tag">챕터 ${documentData.chapter}</span>
    <span class="tag">${documentData.bookmarked ? '북마크됨' : '추적 가능'}</span>
  `;
  els.documentContent.textContent = documentData.content;
}

function renderActivityLog(activityLog) {
  els.activityLog.innerHTML = activityLog.map((entry) => `
    <div class="activity-entry">${escapeHtml(entry)}</div>
  `).join('');
}

function renderReportPresets(reportPresets) {
  if (!reportPresets.length) {
    els.reportPresets.innerHTML = '<div class="empty compact">세 단서를 모두 모으면 보고서 힌트 버튼이 열립니다.</div>';
    return;
  }

  els.reportPresets.innerHTML = reportPresets.map((preset) => `
    <button class="preset-chip" data-report-field="${preset.field}" data-report-value="${escapeHtml(preset.value)}">${escapeHtml(preset.label)}</button>
  `).join('');

  els.reportPresets.querySelectorAll('[data-report-field]').forEach((button) => {
    button.addEventListener('click', () => {
      const { reportField, reportValue } = button.dataset;
      if (reportField === 'culprit') els.culpritInput.value = reportValue;
      if (reportField === 'motive') els.motiveInput.value = reportValue;
      if (reportField === 'method') els.methodInput.value = reportValue;
    });
  });
}

els.sourceFilter.addEventListener('change', () => {
  stateStore.sourceType = els.sourceFilter.value;
  fetchState();
});

els.searchButton.addEventListener('click', () => {
  stateStore.search = els.searchInput.value.trim();
  fetchState();
});

els.searchInput.addEventListener('keydown', (event) => {
  if (event.key === 'Enter') {
    stateStore.search = els.searchInput.value.trim();
    fetchState();
  }
});

els.resetButton.addEventListener('click', () => {
  stateStore.search = '';
  els.searchInput.value = '';
  fetchState();
});

els.saveButton.addEventListener('click', () => postAction('/api/save'));
els.loadButton.addEventListener('click', () => postAction('/api/load'));
els.submitButton.addEventListener('click', () => {
  postAction('/api/submit', {
    culprit: els.culpritInput.value.trim(),
    motive: els.motiveInput.value.trim(),
    method: els.methodInput.value.trim(),
  });
});

initializeRuntime();
