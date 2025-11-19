import { NavigatorScreenParams } from '@react-navigation/native';

// Auth Stack
export type AuthStackParamList = {
  Login: undefined;
  Signup: undefined;
};

// Main Tab
export type MainTabParamList = {
  Home: undefined;
  Search: undefined;
  CreatePost: undefined;
  Notifications: undefined;
  Profile: { userId?: string };
};

// Home Stack
export type HomeStackParamList = {
  Feed: undefined;
  PostDetail: { postId: string };
  UserProfile: { userId: string };
  Comments: { postId: string };
};

// Root Stack
export type RootStackParamList = {
  Auth: NavigatorScreenParams<AuthStackParamList>;
  Main: NavigatorScreenParams<MainTabParamList>;
  PostDetail: { postId: string };
  UserProfile: { userId: string };
  EditProfile: undefined;
  Messages: undefined;
  Chat: { conversationId: string };
  Stories: { userId: string };
  CreateStory: undefined;
};

declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
}
