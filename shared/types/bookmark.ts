export type BookmarkType = 'post' | 'investment_post' | 'reel';

export interface Bookmark {
  bookmarkId: string;
  userId: string;
  contentId: string;
  type: BookmarkType;
  contentPreview?: string;
  contentImageUrl?: string;
  authorUsername?: string;
  authorPhotoUrl?: string;
  createdAt: Date;
}

export interface CreateBookmarkDto {
  contentId: string;
  type: BookmarkType;
}
