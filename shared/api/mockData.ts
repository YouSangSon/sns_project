import type { User, AuthResponse } from '../types';

// Mock 모드 활성화 여부
export const USE_MOCK_API =
  process.env.USE_MOCK_API === 'true' ||
  process.env.NEXT_PUBLIC_USE_MOCK_API === 'true';

// Mock 테스트 계정들
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
