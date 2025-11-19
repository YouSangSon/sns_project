export interface Post {
  postId: string;
  userId: string;
  username: string;
  userPhotoUrl?: string;
  imageUrls: string[];
  caption?: string;
  location?: string;
  hashtags: string[];
  taggedUserIds: string[];
  likes: number;
  comments: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreatePostDto {
  imageUrls: string[];
  caption?: string;
  location?: string;
  taggedUserIds?: string[];
}

export interface UpdatePostDto {
  caption?: string;
  location?: string;
  taggedUserIds?: string[];
}

export interface PostFeed {
  posts: Post[];
  hasMore: boolean;
  nextCursor?: string;
}
