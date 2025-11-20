export interface Story {
  storyId: string;
  userId: string;
  username: string;
  userPhotoUrl?: string;
  mediaUrl: string;
  mediaType: 'image' | 'video';
  duration?: number;
  views: number;
  createdAt: Date;
  expiresAt: Date;
}

export interface CreateStoryDto {
  mediaUrl: string;
  mediaType: 'image' | 'video';
  duration?: number;
}

export interface StoryViewer {
  userId: string;
  username: string;
  userPhotoUrl?: string;
  viewedAt: Date;
}
