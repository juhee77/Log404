import { describe, it, expect } from 'vitest';
import { parseGoogleBooksItem, buildGoogleBooksApiUrl, validateImageUrl } from '../src/scraper';

describe('Web Cover Scraper & URL Validator', () => {
  it('correctly builds Google Books query URL', () => {
    const url = buildGoogleBooksApiUrl('슬램덩크');
    expect(url).toContain('https://www.googleapis.com/books/v1/volumes?q=');
    expect(url).toContain('maxResults=6');
  });

  it('parses Google Books response item safely and enforces HTTPS thumbnail', () => {
    const mockRawItem = {
      volumeInfo: {
        title: '슬램덩크 1',
        authors: ['이노우에 다케히코'],
        publishedDate: '2023-01-01',
        description: '강백호의 농구 이야기',
        imageLinks: {
          thumbnail: 'http://books.google.com/books/content?id=123&printsec=frontcover'
        }
      }
    };

    const parsed = parseGoogleBooksItem(mockRawItem);
    expect(parsed.title).toBe('슬램덩크 1');
    expect(parsed.author).toBe('이노우에 다케히코');
    expect(parsed.coverUrl.startsWith('https://')).toBe(true);
  });

  it('handles missing thumbnail and authors gracefully', () => {
    const emptyItem = { volumeInfo: {} };
    const parsed = parseGoogleBooksItem(emptyItem);
    expect(parsed.title).toBe('제목 없음');
    expect(parsed.author).toBe('작가 미상');
    expect(parsed.coverUrl).toBe('');
  });

  it('validates image URLs correctly', () => {
    expect(validateImageUrl('https://example.com/cover.jpg')).toBe(true);
    expect(validateImageUrl('http://example.com/cover.png')).toBe(true);
    expect(validateImageUrl('invalid-url')).toBe(false);
    expect(validateImageUrl('')).toBe(false);
  });
});
