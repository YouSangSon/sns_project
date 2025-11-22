import type { User, AuthResponse } from '../types';

// Mock 테스트 계정들 (하드코딩)
export const MOCK_USERS: Record<string, { user: User; password: string }> = {
  'test@example.com': {
    password: 'Test123!@#',
    user: {
      userId: 'mock-user-1',
      email: 'test@example.com',
      username: 'testuser',
      fullName: 'Test User',
      bio: '테스트 계정입니다',
      profileImageUrl: 'https://i.pravatar.cc/300?u=testuser',
      followerCount: 150,
      followingCount: 89,
      postCount: 25,
      isVerified: false,
      createdAt: new Date('2024-01-01').toISOString(),
    },
  },
  'john@example.com': {
    password: 'John123!@#',
    user: {
      userId: 'mock-user-2',
      email: 'john@example.com',
      username: 'johndoe',
      fullName: 'John Doe',
      bio: '사진 찍는 것을 좋아합니다 📸',
      profileImageUrl: 'https://i.pravatar.cc/300?u=johndoe',
      followerCount: 520,
      followingCount: 234,
      postCount: 87,
      isVerified: true,
      createdAt: new Date('2023-06-15').toISOString(),
    },
  },
  'jane@example.com': {
    password: 'Jane123!@#',
    user: {
      userId: 'mock-user-3',
      email: 'jane@example.com',
      username: 'janedoe',
      fullName: 'Jane Doe',
      bio: '여행과 음식을 사랑하는 크리에이터 ✈️🍜',
      profileImageUrl: 'https://i.pravatar.cc/300?u=janedoe',
      followerCount: 1250,
      followingCount: 456,
      postCount: 142,
      isVerified: true,
      createdAt: new Date('2023-03-20').toISOString(),
    },
  },
  'admin@example.com': {
    password: 'Admin123!@#',
    user: {
      userId: 'mock-user-admin',
      email: 'admin@example.com',
      username: 'admin',
      fullName: 'Admin User',
      bio: '관리자 계정',
      profileImageUrl: 'https://i.pravatar.cc/300?u=admin',
      followerCount: 5000,
      followingCount: 100,
      postCount: 10,
      isVerified: true,
      createdAt: new Date('2023-01-01').toISOString(),
    },
  },
};

// Mock 토큰 생성 (실제로는 사용되지 않지만 형식 맞추기 위해)
export const generateMockToken = (userId: string): string => {
  return `mock-jwt-token-${userId}-${Date.now()}`;
};

// Mock 로그인 응답 생성
export const createMockAuthResponse = (user: User): AuthResponse => {
  return {
    token: generateMockToken(user.userId),
    refreshToken: `mock-refresh-token-${user.userId}-${Date.now()}`,
    user,
    expiresIn: 3600, // 1시간
  };
};

// 이메일로 Mock 사용자 찾기
export const findMockUserByEmail = (
  email: string
): { user: User; password: string } | null => {
  return MOCK_USERS[email] || null;
};

// 로그인 검증
export const validateMockLogin = (
  email: string,
  password: string
): AuthResponse | null => {
  const mockUser = findMockUserByEmail(email);

  if (!mockUser) {
    return null;
  }

  if (mockUser.password !== password) {
    return null;
  }

  return createMockAuthResponse(mockUser.user);
};

// Mock 회원가입
export const createMockUser = (
  email: string,
  password: string,
  username: string,
  fullName: string
): AuthResponse => {
  const newUser: User = {
    userId: `mock-user-${Date.now()}`,
    email,
    username,
    fullName,
    bio: '',
    profileImageUrl: `https://i.pravatar.cc/300?u=${username}`,
    followerCount: 0,
    followingCount: 0,
    postCount: 0,
    isVerified: false,
    createdAt: new Date().toISOString(),
  };

  // 메모리에 저장 (실제로는 새로고침하면 사라짐)
  MOCK_USERS[email] = { user: newUser, password };

  return createMockAuthResponse(newUser);
};

// Mock 토큰에서 사용자 ID 추출
export const extractUserIdFromMockToken = (token: string): string | null => {
  const match = token.match(/^mock-jwt-token-([^-]+)-/);
  return match ? match[1] : null;
};

// Mock 토큰으로 사용자 찾기
export const findMockUserByToken = (token: string): User | null => {
  const userId = extractUserIdFromMockToken(token);
  if (!userId) return null;

  const mockUser = Object.values(MOCK_USERS).find(
    (mu) => mu.user.userId === userId
  );

  return mockUser?.user || null;
};

// Mock Posts
import type { Post, Comment, Message, Notification } from '../types';

export const MOCK_POSTS: Post[] = [
  {
    postId: 'mock-post-1',
    userId: 'mock-user-2',
    username: 'johndoe',
    userPhotoUrl: 'https://i.pravatar.cc/300?u=johndoe',
    caption: '멋진 풍경 🌄 #여행 #자연',
    imageUrls: [
      'https://picsum.photos/800/600?random=1',
      'https://picsum.photos/800/600?random=2',
    ],
    likes: 342,
    comments: 28,
    shares: 12,
    isLiked: false,
    isBookmarked: false,
    location: '제주도',
    createdAt: new Date('2025-01-20T10:30:00').toISOString(),
    updatedAt: new Date('2025-01-20T10:30:00').toISOString(),
  },
  {
    postId: 'mock-post-2',
    userId: 'mock-user-3',
    username: 'janedoe',
    userPhotoUrl: 'https://i.pravatar.cc/300?u=janedoe',
    caption: '오늘의 브런치 🥐☕️ #맛집 #브런치',
    imageUrls: [
      'https://picsum.photos/800/600?random=3',
    ],
    likes: 521,
    comments: 45,
    shares: 18,
    isLiked: true,
    isBookmarked: false,
    createdAt: new Date('2025-01-19T14:20:00').toISOString(),
    updatedAt: new Date('2025-01-19T14:20:00').toISOString(),
  },
  {
    postId: 'mock-post-3',
    userId: 'mock-user-1',
    username: 'testuser',
    userPhotoUrl: 'https://i.pravatar.cc/300?u=testuser',
    caption: '새로운 도전! 💪',
    imageUrls: [
      'https://picsum.photos/800/600?random=4',
    ],
    likes: 89,
    comments: 12,
    shares: 3,
    isLiked: false,
    isBookmarked: true,
    createdAt: new Date('2025-01-18T09:15:00').toISOString(),
    updatedAt: new Date('2025-01-18T09:15:00').toISOString(),
  },
];

// Mock Comments
export const MOCK_COMMENTS: Record<string, Comment[]> = {
  'mock-post-1': [
    {
      commentId: 'comment-1',
      postId: 'mock-post-1',
      userId: 'mock-user-3',
      username: 'janedoe',
      userPhotoUrl: 'https://i.pravatar.cc/300?u=janedoe',
      content: '너무 예쁘다! 나도 가고 싶어요',
      likes: 15,
      isLiked: false,
      createdAt: new Date('2025-01-20T11:00:00'),
    },
    {
      commentId: 'comment-2',
      postId: 'mock-post-1',
      userId: 'mock-user-1',
      username: 'testuser',
      userPhotoUrl: 'https://i.pravatar.cc/300?u=testuser',
      content: '제주도 최고!!',
      likes: 8,
      isLiked: true,
      createdAt: new Date('2025-01-20T12:30:00'),
    },
  ],
  'mock-post-2': [
    {
      commentId: 'comment-3',
      postId: 'mock-post-2',
      userId: 'mock-user-2',
      username: 'johndoe',
      userPhotoUrl: 'https://i.pravatar.cc/300?u=johndoe',
      content: '맛있겠다!',
      likes: 12,
      isLiked: false,
      createdAt: new Date('2025-01-19T15:00:00'),
    },
  ],
};

// Mock Notifications
export const MOCK_NOTIFICATIONS: Notification[] = [
  {
    notificationId: 'notif-1',
    userId: 'mock-user-1',
    type: 'like',
    actorId: 'mock-user-2',
    actorUsername: 'johndoe',
    actorPhotoUrl: 'https://i.pravatar.cc/300?u=johndoe',
    postId: 'mock-post-3',
    postImageUrl: 'https://picsum.photos/800/600?random=4',
    content: '님이 회원님의 게시물을 좋아합니다.',
    isRead: false,
    createdAt: new Date('2025-01-20T16:30:00'),
  },
  {
    notificationId: 'notif-2',
    userId: 'mock-user-1',
    type: 'comment',
    actorId: 'mock-user-3',
    actorUsername: 'janedoe',
    actorPhotoUrl: 'https://i.pravatar.cc/300?u=janedoe',
    postId: 'mock-post-3',
    postImageUrl: 'https://picsum.photos/800/600?random=4',
    content: '님이 댓글을 남겼습니다: "멋지네요!"',
    isRead: false,
    createdAt: new Date('2025-01-20T15:00:00'),
  },
  {
    notificationId: 'notif-3',
    userId: 'mock-user-1',
    type: 'follow',
    actorId: 'mock-user-2',
    actorUsername: 'johndoe',
    actorPhotoUrl: 'https://i.pravatar.cc/300?u=johndoe',
    content: '님이 회원님을 팔로우하기 시작했습니다.',
    isRead: true,
    createdAt: new Date('2025-01-19T10:00:00'),
  },
];

// Mock Messages
export const MOCK_CONVERSATIONS = [
  {
    conversationId: 'conv-1',
    userId: 'mock-user-2',
    username: 'johndoe',
    userPhotoUrl: 'https://i.pravatar.cc/300?u=johndoe',
    lastMessage: '사진 정말 잘 나왔어요!',
    lastMessageTime: new Date('2025-01-20T14:30:00'),
    unreadCount: 2,
    isOnline: true,
  },
  {
    conversationId: 'conv-2',
    userId: 'mock-user-3',
    username: 'janedoe',
    userPhotoUrl: 'https://i.pravatar.cc/300?u=janedoe',
    lastMessage: '내일 만날까요?',
    lastMessageTime: new Date('2025-01-20T12:00:00'),
    unreadCount: 0,
    isOnline: false,
  },
];

export const MOCK_MESSAGES: Record<string, Message[]> = {
  'conv-1': [
    {
      messageId: 'msg-1',
      conversationId: 'conv-1',
      senderId: 'mock-user-2',
      receiverId: 'mock-user-1',
      content: '안녕하세요!',
      isRead: true,
      createdAt: new Date('2025-01-20T14:00:00'),
    },
    {
      messageId: 'msg-2',
      conversationId: 'conv-1',
      senderId: 'mock-user-1',
      receiverId: 'mock-user-2',
      content: '네, 안녕하세요!',
      isRead: true,
      createdAt: new Date('2025-01-20T14:05:00'),
    },
    {
      messageId: 'msg-3',
      conversationId: 'conv-1',
      senderId: 'mock-user-2',
      receiverId: 'mock-user-1',
      content: '사진 정말 잘 나왔어요!',
      isRead: false,
      createdAt: new Date('2025-01-20T14:30:00'),
    },
  ],
  'conv-2': [
    {
      messageId: 'msg-4',
      conversationId: 'conv-2',
      senderId: 'mock-user-3',
      receiverId: 'mock-user-1',
      content: '내일 만날까요?',
      isRead: true,
      createdAt: new Date('2025-01-20T12:00:00'),
    },
  ],
};
