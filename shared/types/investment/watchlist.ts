import { AssetType } from './asset';

export type AlertCondition = 'above' | 'below' | 'change';

export interface Watchlist {
  watchlistId: string;
  userId: string;
  assetSymbol: string;
  assetName: string;
  assetType: AssetType;
  addedPrice: number;
  targetPrice?: number;
  alertEnabled: boolean;
  alertCondition?: AlertCondition;
  alertTriggered: boolean;
  alertTriggeredAt?: Date;
  alertTriggeredPrice?: number;
  addedAt: Date;
  updatedAt: Date;
}

export interface CreateWatchlistDto {
  assetSymbol: string;
  assetName: string;
  assetType: AssetType;
  targetPrice?: number;
  alertEnabled?: boolean;
  alertCondition?: AlertCondition;
}

export interface UpdateWatchlistDto {
  targetPrice?: number;
  alertEnabled?: boolean;
  alertCondition?: AlertCondition;
}
