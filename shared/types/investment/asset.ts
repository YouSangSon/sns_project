export type AssetType = 'stock' | 'crypto' | 'etf' | 'bond' | 'commodity';

export interface AssetHolding {
  holdingId: string;
  portfolioId: string;
  userId: string;
  assetSymbol: string;
  assetName: string;
  assetType: AssetType;
  quantity: number;
  averagePrice: number;
  currentPrice: number;
  totalValue: number;
  unrealizedGain: number;
  unrealizedGainPercent: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateAssetHoldingDto {
  portfolioId: string;
  assetSymbol: string;
  assetName: string;
  assetType: AssetType;
  quantity: number;
  averagePrice: number;
}

export interface UpdateAssetHoldingDto {
  quantity?: number;
  averagePrice?: number;
  currentPrice?: number;
}

export interface AssetPrice {
  symbol: string;
  price: number;
  change: number;
  changePercent: number;
  high: number;
  low: number;
  volume: number;
  timestamp: Date;
}
