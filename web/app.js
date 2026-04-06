
const stateStore = {
  sourceType: 'all',
  search: '',
  activeDocId: null,
  payload: null,
};

const els = {
  objective: document.getElementById('objective'),
  progress: document.getElementById('progress'),
  documentList: document.getElementById('documentList'),
  documentTitle: document.getElementById('documentTitle'),
  documentContent: document.getElementById('documentContent'),
  clueList: document.getElementById('clueList'),
  bookmarkList: document.getElementById('bookmarkList'),
  statusLine: document.getElementById('statusLine'),
  sourceFilter: document.getElementById('sourceFilter'),
  searchInput: document.getElementById('searchInput'),
  culpritInput: document.getElementById('culpritInput'),
  motiveInput: document.getElementById('motiveInput'),
  methodInput: document.getElementById('methodInput'),
  submitButton: document.getElementById('submitButton'),
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

  els.objective.textContent = `${state.case_title} / ${state.objective}`;
  els.progress.textContent = `챕터 ${state.chapter}/3 · 열람 ${state.opened_count} · 단서 ${state.clue_count}/3 · 북마크 ${state.bookmark_count}`;
  els.submitButton.disabled = !state.can_submit;

  renderDocuments(state.documents, state.active_document);
  renderClues(state.clues);
  renderBookmarks(state.bookmarks);
  renderDocumentViewer(state.active_document);
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
      <div><strong>${escapeHtml(clue.name)}</strong></div>
      <div class="clue-meta">${escapeHtml(clue.clue_id)} · 챕터 ${clue.chapter} · ${clue.solved ? '확보' : '미확보'}</div>
      <p>${escapeHtml(clue.description)}</p>
      <div class="clue-actions">
        <button data-infer-clue="${clue.clue_id}" class="accent">추론</button>
      </div>
    </article>
  `).join('');

  els.clueList.querySelectorAll('[data-infer-clue]').forEach((button) => {
    button.addEventListener('click', () => postAction('/api/infer', { clue_id: button.dataset.inferClue }));
  });
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
    els.documentContent.textContent = '좌측에서 문서를 클릭하면 내용이 여기에 표시됩니다.';
    return;
  }
  stateStore.activeDocId = documentData.doc_id;
  els.documentTitle.textContent = `${documentData.title} / ${documentData.doc_id}`;
  els.documentContent.textContent = documentData.content;
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
