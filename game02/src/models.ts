// Shelf and Item state models and helper functions
export interface BookVolume {
  vol: number;
  status: 'owned' | 'first' | 'reading' | 'wish';
  rating: number;
  quote?: string;
  note?: string;
  coverUrl?: string;
}

export interface CollectionItem {
  id: string;
  category: 'manga' | 'gacha' | 'goods';
  title: string;
  authorOrSeries: string;
  coverUrl: string;
  statusTag: string; // e.g. '초판소장', '완결', 'SSR'
  note?: string;
  volumes?: BookVolume[];
  createdAt: number;
}

export interface ShelfState {
  roomName: string;
  filter: 'all' | 'manga' | 'gacha';
  searchQuery: string;
  items: CollectionItem[];
  selectedItemId: string | null;
}

export const createInitialState = (): ShelfState => ({
  roomName: '주희의 만화 & 가챠 아카이브',
  filter: 'all',
  searchQuery: '',
  items: [
    {
      id: 'm1',
      category: 'manga',
      title: '슬램덩크 신장재편판',
      authorOrSeries: '이노우에 다케히코',
      coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80',
      statusTag: '전권완결',
      volumes: [
        { vol: 1, status: 'first', rating: 5, quote: '농구 좋아하세요?' },
        { vol: 2, status: 'owned', rating: 5 },
        { vol: 3, status: 'first', rating: 5 }
      ],
      createdAt: Date.now()
    },
    {
      id: 'm2',
      category: 'manga',
      title: '장송의 프리렌',
      authorOrSeries: '야마다 카네히토',
      coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80',
      statusTag: '연재중',
      volumes: [
        { vol: 1, status: 'first', rating: 5, quote: '힘멜이라면 그렇게 했을 거야' },
        { vol: 2, status: 'owned', rating: 4 }
      ],
      createdAt: Date.now() - 1000
    },
    {
      id: 'g1',
      category: 'gacha',
      title: '치이카와 캡슐 토이 피규어',
      authorOrSeries: '반다이 캡슐 vol.2',
      coverUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=400&q=80',
      statusTag: '시크릿 획득',
      note: '국전 가챠샵에서 단번에 뽑은 최애 피규어!',
      createdAt: Date.now() - 2000
    }
  ],
  selectedItemId: 'm1'
});

export const filterItems = (items: CollectionItem[], filter: 'all' | 'manga' | 'gacha', query: string): CollectionItem[] => {
  return items.filter(item => {
    const matchesFilter = filter === 'all' || item.category === filter;
    const q = query.trim().toLowerCase();
    const matchesQuery = !q || item.title.toLowerCase().includes(q) || item.authorOrSeries.toLowerCase().includes(q);
    return matchesFilter && matchesQuery;
  });
};

export const addItem = (state: ShelfState, item: Omit<CollectionItem, 'id' | 'createdAt'>): ShelfState => {
  const newItem: CollectionItem = {
    ...item,
    id: 'item_' + Date.now() + '_' + Math.random().toString(36).substring(2, 6),
    createdAt: Date.now()
  };
  return {
    ...state,
    items: [newItem, ...state.items],
    selectedItemId: newItem.id
  };
};

export const removeItem = (state: ShelfState, id: string): ShelfState => {
  const updated = state.items.filter(i => i.id !== id);
  return {
    ...state,
    items: updated,
    selectedItemId: updated.length > 0 ? updated[0].id : null
  };
};

export const addVolumeToItem = (state: ShelfState, itemId: string, volData?: Partial<BookVolume>): ShelfState => {
  return {
    ...state,
    items: state.items.map(item => {
      if (item.id !== itemId) return item;
      const vols = item.volumes || [];
      const nextNum = vols.length + 1;
      const newVol: BookVolume = {
        vol: nextNum,
        status: 'owned',
        rating: 5,
        ...volData
      };
      return {
        ...item,
        volumes: [...vols, newVol]
      };
    })
  };
};

