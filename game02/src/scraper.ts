export interface WebBookScrapResult {
  title: string;
  author: string;
  coverUrl: string;
  publishedDate?: string;
  description?: string;
  isbn?: string;
}

export const parseGoogleBooksItem = (item: any): WebBookScrapResult => {
  const volumeInfo = item.volumeInfo || {};
  let cover = (volumeInfo.imageLinks && (volumeInfo.imageLinks.thumbnail || volumeInfo.imageLinks.smallThumbnail)) || '';
  if (cover.startsWith('http://')) {
    cover = cover.replace('http://', 'https://');
  }

  const authors = volumeInfo.authors && volumeInfo.authors.length > 0 
    ? volumeInfo.authors.join(', ') 
    : '작가 미상';

  return {
    title: volumeInfo.title || '제목 없음',
    author: authors,
    coverUrl: cover,
    publishedDate: volumeInfo.publishedDate || '',
    description: volumeInfo.description || '',
    isbn: volumeInfo.industryIdentifiers?.[0]?.identifier || ''
  };
};

export const buildGoogleBooksApiUrl = (query: string): string => {
  const clean = encodeURIComponent(query.trim());
  return `https://www.googleapis.com/books/v1/volumes?q=${clean}&maxResults=6`;
};

export const validateImageUrl = (url: string): boolean => {
  if (!url) return false;
  try {
    const parsed = new URL(url);
    return parsed.protocol === 'http:' || parsed.protocol === 'https:';
  } catch {
    return false;
  }
};

