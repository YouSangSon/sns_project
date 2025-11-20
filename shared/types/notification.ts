export type NotificationType =
  | 'like'
  | 'comment'
  | 'follow'
  | 'mention'
  | 'story_view'
  | 'investment_alert';

export interface Notification {
  notificationId: string;
  userId: string;
  type: NotificationType;
  title: string;
  message: string;
  actorId?: string;
  actorUsername?: string;
  actorPhotoUrl?: string;
  relatedPostId?: string;
  relatedCommentId?: string;
  isRead: boolean;
  createdAt: Date;
}

export interface CreateNotificationDto {
  userId: string;
  type: NotificationType;
  title: string;
  message: string;
  actorId?: string;
  relatedPostId?: string;
  relatedCommentId?: string;
}
