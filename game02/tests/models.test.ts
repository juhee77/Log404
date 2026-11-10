import { describe, it, expect } from 'vitest';
import {
  createInitialState,
  filterItems,
  addItem,
  removeItem,
  addVolumeToItem,
  ShelfState
} from '../src/models';

describe('Pocket Archive Data Models & Operations', () => {
  it('creates clean initial state with default items', () => {
    const state = createInitialState();
    expect(state.items.length).toBe(3);
    expect(state.selectedItemId).toBe('m1');
    expect(state.filter).toBe('all');
  });

  it('filters items correctly by category', () => {
    const state = createInitialState();
    const mangas = filterItems(state.items, 'manga', '');
    expect(mangas.length).toBe(2);
    expect(mangas.every(i => i.category === 'manga')).toBe(true);

    const gachas = filterItems(state.items, 'gacha', '');
    expect(gachas.length).toBe(1);
    expect(gachas[0].id).toBe('g1');
  });

  it('filters items correctly by search keyword', () => {
    const state = createInitialState();
    const results = filterItems(state.items, 'all', '슬램덩크');
    expect(results.length).toBe(1);
    expect(results[0].title).toContain('슬램덩크');

    const noResults = filterItems(state.items, 'all', '존재하지않음');
    expect(noResults.length).toBe(0);
  });

  it('adds a new item immutably and sets as selected', () => {
    const state = createInitialState();
    const nextState = addItem(state, {
      category: 'manga',
      title: '체인소 맨',
      authorOrSeries: '후지모토 타츠키',
      coverUrl: '',
      statusTag: '소장중'
    });

    expect(nextState.items.length).toBe(state.items.length + 1);
    expect(nextState.items[0].title).toBe('체인소 맨');
    expect(nextState.selectedItemId).toBe(nextState.items[0].id);
    // original state should remain unchanged
    expect(state.items.length).toBe(3);
  });

  it('removes item and selects the next available item', () => {
    const state = createInitialState();
    const nextState = removeItem(state, 'm1');
    expect(nextState.items.find(i => i.id === 'm1')).toBeUndefined();
    expect(nextState.selectedItemId).toBe('m2');
  });

  it('adds volume to book item cleanly', () => {
    const state = createInitialState();
    const nextState = addVolumeToItem(state, 'm1', { rating: 5, quote: '왼손은 거들 뿐' });
    const updatedBook = nextState.items.find(i => i.id === 'm1');
    expect(updatedBook?.volumes?.length).toBe(4);
    expect(updatedBook?.volumes?.[3].vol).toBe(4);
    expect(updatedBook?.volumes?.[3].quote).toBe('왼손은 거들 뿐');
  });
});

