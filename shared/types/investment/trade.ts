export type TradeType = 'buy' | 'sell';

export interface TradeHistory {
  tradeId: string;
  portfolioId: string;
  userId: string;
  assetSymbol: string;
  assetName: string;
  tradeType: TradeType;
  quantity: number;
  price: number;
  totalAmount: number;
  fee: number;
  notes?: string;
  executedAt: Date;
  createdAt: Date;
}

export interface CreateTradeDto {
  portfolioId: string;
  assetSymbol: string;
  assetName: string;
  tradeType: TradeType;
  quantity: number;
  price: number;
  fee?: number;
  notes?: string;
  executedAt?: Date;
}
