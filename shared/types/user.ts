export interface User {
  uid: string;
  email: string;
  username: string;
  displayName: string;
  photoUrl?: string;
  bio?: string;
  followers: number;
  following: number;
  posts: number;
  createdAt: Date;
  updatedAt?: Date;
}

export interface CreateUserDto {
  email: string;
  password: string;
  username: string;
  displayName: string;
}

export interface UpdateUserDto {
  displayName?: string;
  photoUrl?: string;
  bio?: string;
}

export interface LoginDto {
  email: string;
  password: string;
}

export interface AuthResponse {
  user: User;
  token: string;
  refreshToken?: string;
}
