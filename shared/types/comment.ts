export interface Comment {
  commentId: string;
  postId: string;
  userId: string;
  username: string;
  userPhotoUrl?: string;
  text: string;
  likes: number;
  parentCommentId?: string;
  repliesCount: number;
  createdAt: Date;
  updatedAt?: Date;
}

export interface CreateCommentDto {
  postId: string;
  text: string;
  parentCommentId?: string;
}

export interface UpdateCommentDto {
  text: string;
}
