export interface Message {
  messageId: string;
  conversationId: string;
  senderId: string;
  receiverId: string;
  text?: string;
  imageUrl?: string;
  isRead: boolean;
  createdAt: Date;
}

export interface Conversation {
  conversationId: string;
  participants: string[];
  participantDetails: {
    userId: string;
    username: string;
    photoUrl?: string;
  }[];
  lastMessage?: Message;
  lastMessageAt: Date;
  unreadCount: number;
}

export interface CreateMessageDto {
  receiverId: string;
  text?: string;
  imageUrl?: string;
}
