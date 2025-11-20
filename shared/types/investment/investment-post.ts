export type InvestmentPostType = 'idea' | 'performance' | 'trade' | 'analysis';
export type Sentiment = 'bullish' | 'bearish' | 'neutral';
export type TimeHorizon = 'short' | 'medium' | 'long';

export interface InvestmentPost {
  postId: string;
  userId: string;
  username: string;
  userPhotoUrl?: string;
  postType: InvestmentPostType;
  content: string;
  relatedAssets: string[];
  sentiment?: Sentiment;
  targetPrice?: number;
  timeHorizon?: TimeHorizon;
  hashtags: string[];
  imageUrls: string[];
  likes: number;
  comments: number;
  bookmarks: number;
  bullishCount: number;
  bearishCount: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateInvestmentPostDto {
  postType: InvestmentPostType;
  content: string;
  relatedAssets?: string[];
  sentiment?: Sentiment;
  targetPrice?: number;
  timeHorizon?: TimeHorizon;
  imageUrls?: string[];
}

export interface UpdateInvestmentPostDto {
  content?: string;
  relatedAssets?: string[];
  sentiment?: Sentiment;
  targetPrice?: number;
  timeHorizon?: TimeHorizon;
}

export interface InvestmentPostVote {
  postId: string;
  userId: string;
  isBullish: boolean;
  votedAt: Date;
}
