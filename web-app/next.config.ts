import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  webpack: (config) => {
    // shared 폴더를 webpack이 해석할 수 있도록 설정
    config.resolve.alias = {
      ...config.resolve.alias,
      '@shared': path.resolve(__dirname, '../shared'),
    };
    return config;
  },
  // Turbopack 설정 (Next.js 16+)
  turbopack: {
    resolveAlias: {
      '@shared': path.resolve(__dirname, '../shared'),
    },
  },
};

export default nextConfig;
