interface PoolStatsResponse {
  data: Array<{
    currency: string;
    totalSupplied: number;
    totalBorrowed: number;
  }>;
}

export type { PoolStatsResponse };
