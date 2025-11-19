export interface Reel {
  reelId: string;
  userId: string;
  username: string;
  userPhotoUrl?: string;
  videoUrl: string;
  thumbnailUrl?: string;
  caption?: string;
  audioUrl?: string;
  audioName?: string;
  hashtags: string[];
  likes: number;
  comments: number;
  shares: number;
  views: number;
  createdAt: Date;
  updatedAt?: Date;
}

export interface CreateReelDto {
  videoUrl: string;
  thumbnailUrl?: string;
  caption?: string;
  audioUrl?: string;
  audioName?: string;
}

export interface UpdateReelDto {
  caption?: string;
}
