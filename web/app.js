
const stateStore = {
  sourceType: 'all',
  search: '',
  activeDocId: null,
  payload: null,
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
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

async function fetchState() {
  const params = new URLSearchParams({
    source_type: stateStore.sourceType,
    search: stateStore.search,
  });
  const response = await fetch(`/api/state?${params.toString()}`);
  const payload = await response.json();
  stateStore.payload = payload.state;
  render();
  setStatus(payload.message);
}

async function postAction(path, body = {}) {
  const response = await fetch(path, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      ...body,
      source_type: stateStore.sourceType,
      search: stateStore.search,
    }),
  });
  const payload = await response.json();
  stateStore.payload = payload.state;
  if (stateStore.payload?.active_document?.doc_id) {
    stateStore.activeDocId = stateStore.payload.active_document.doc_id;
  }
  render();
  setStatus(payload.message);
}

function render() {
  const state = stateStore.payload;
  if (!state) return;

  document.body.dataset.chapter = String(state.chapter);
  document.body.dataset.reportReady = state.can_submit ? 'true' : 'false';
  els.objective.textContent = `${state.case_title} / ${state.objective}`;
  els.stageBadge.textContent = state.stage_label;
  els.progress.textContent = `챕터 ${state.chapter}/3 · 열람 ${state.opened_count} · 단서 ${state.clue_count}/${state.total_clue_count} · 북마크 ${state.bookmark_count}`;
  els.nextStep.textContent = state.next_step;
  els.reportGuide.textContent = state.report_guidance;
  els.reportResult.textContent = state.last_report_message;
  els.submitButton.disabled = !state.can_submit;
  syncSourceTypes(state.source_types);

  renderStoryBrief(state.story_brief);
  renderSuspects(state.suspects);
  renderDocuments(state.documents, state.active_document);
  renderClues(state.clues);
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

function renderStoryBrief(storyBrief) {
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
  els.opsRail.innerHTML = `
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

function renderClues(clues) {
  els.clueList.innerHTML = clues.map((clue) => `
    <article class="clue-item ${clue.solved ? 'active' : ''}">
      <div class="clue-header">
        <strong>${escapeHtml(clue.name)}</strong>
        <span class="clue-readiness ${clue.ready_to_infer ? 'ready' : ''}">${clue.solved ? '확보 완료' : clue.ready_to_infer ? '추론 가능' : '조사 중'}</span>
      </div>
      <div class="clue-meta">${escapeHtml(clue.clue_id)} · 챕터 ${clue.chapter} · ${clue.solved ? '확보' : '미확보'}</div>
      <p>${escapeHtml(clue.description)}</p>
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

fetchState();
