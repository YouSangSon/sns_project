export interface InvestmentPortfolio {
  portfolioId: string;
  userId: string;
  name: string;
  description?: string;
  totalValue: number;
  totalCost: number;
  totalReturn: number;
  returnPercentage: number;
  isPublic: boolean;
  followers: number;
  copiedCount: number;
  riskScore?: number;
  diversificationScore?: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreatePortfolioDto {
  name: string;
  description?: string;
  isPublic?: boolean;
}

export interface UpdatePortfolioDto {
  name?: string;
  description?: string;
  isPublic?: boolean;
}

export interface PortfolioAnalytics {
  riskScore: number;
  riskLevel: 'low' | 'medium' | 'high' | 'very_high';
  diversificationScore: number;
  sharpeRatio?: number;
  sectorAllocation: {
    sector: string;
    percentage: number;
  }[];
}
