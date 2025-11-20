// Portfolio
export interface Portfolio {
  portfolioId: string;
  userId: string;
  name: string;
  description?: string;
  isPublic: boolean;
  totalValue: number;
  totalCost: number;
  totalProfit: number;
  totalProfitRate: number;
  currency: string;
  followers: number;
  createdAt: Date;
  updatedAt?: Date;
}

export interface CreatePortfolioDto {
  name: string;
  description?: string;
  isPublic: boolean;
  currency?: string;
}

export interface UpdatePortfolioDto {
  name?: string;
  description?: string;
  isPublic?: boolean;
}

// Holding (보유 종목)
export interface Holding {
  holdingId: string;
  portfolioId: string;
  symbol: string;
  assetName: string;
  assetType: 'stock' | 'crypto' | 'etf' | 'bond' | 'other';
  quantity: number;
  averagePrice: number;
  currentPrice: number;
  totalCost: number;
  totalValue: number;
  profit: number;
  profitRate: number;
  currency: string;
  createdAt: Date;
  updatedAt?: Date;
}

export interface CreateHoldingDto {
  symbol: string;
  assetName: string;
  assetType: 'stock' | 'crypto' | 'etf' | 'bond' | 'other';
  quantity: number;
  averagePrice: number;
  currency?: string;
}

export interface UpdateHoldingDto {
  quantity?: number;
  averagePrice?: number;
}

// Trade (거래)
export interface Trade {
  tradeId: string;
  portfolioId: string;
  symbol: string;
  assetName: string;
  assetType: 'stock' | 'crypto' | 'etf' | 'bond' | 'other';
  type: 'buy' | 'sell';
  quantity: number;
  price: number;
  totalAmount: number;
  fee?: number;
  currency: string;
  note?: string;
  tradedAt: Date;
  createdAt: Date;
}

export interface CreateTradeDto {
  portfolioId: string;
  symbol: string;
  assetName: string;
  assetType: 'stock' | 'crypto' | 'etf' | 'bond' | 'other';
  type: 'buy' | 'sell';
  quantity: number;
  price: number;
  fee?: number;
  currency?: string;
  note?: string;
  tradedAt?: Date;
}

// Watchlist
export interface WatchlistItem {
  watchlistId: string;
  userId: string;
  symbol: string;
  assetName: string;
  assetType: 'stock' | 'crypto' | 'etf' | 'bond' | 'other';
  currentPrice?: number;
  priceChange?: number;
  priceChangeRate?: number;
  targetPrice?: number;
  note?: string;
  createdAt: Date;
}

export interface CreateWatchlistItemDto {
  symbol: string;
  assetName: string;
  assetType: 'stock' | 'crypto' | 'etf' | 'bond' | 'other';
  targetPrice?: number;
  note?: string;
}

export interface UpdateWatchlistItemDto {
  targetPrice?: number;
  note?: string;
}

// Investment Post
export interface InvestmentPost {
  postId: string;
  userId: string;
  username: string;
  userPhotoUrl?: string;
  content: string;
  symbols: string[];
  sentiment?: 'bullish' | 'bearish' | 'neutral';
  portfolioId?: string;
  imageUrls?: string[];
  likes: number;
  comments: number;
  shares: number;
  votes?: {
    bullish: number;
    bearish: number;
  };
  createdAt: Date;
  updatedAt?: Date;
}

export interface CreateInvestmentPostDto {
  content: string;
  symbols?: string[];
  sentiment?: 'bullish' | 'bearish' | 'neutral';
  portfolioId?: string;
  imageUrls?: string[];
}

export interface UpdateInvestmentPostDto {
  content?: string;
  symbols?: string[];
  sentiment?: 'bullish' | 'bearish' | 'neutral';
}

// Portfolio Analytics
export interface PortfolioAnalytics {
  portfolioId: string;
  totalValue: number;
  totalCost: number;
  totalProfit: number;
  totalProfitRate: number;
  dailyChange: number;
  dailyChangeRate: number;
  assetAllocation: {
    assetType: string;
    value: number;
    percentage: number;
  }[];
  topHoldings: Holding[];
  performanceHistory: {
    date: Date;
    value: number;
  }[];
}

// Asset Price
export interface AssetPrice {
  symbol: string;
  name: string;
  price: number;
  change: number;
  changeRate: number;
  volume?: number;
  marketCap?: number;
  currency: string;
  updatedAt: Date;
}
