import * as chains from "viem/chains";

export type ScaffoldConfig = {
  targetNetworks: readonly chains.Chain[];
  pollingInterval: number;
  alchemyApiKey: string;
  walletConnectProjectId: string;
  onlyLocalBurnerWallet: boolean;
};

export const DEFAULT_ALCHEMY_API_KEY = "oKxs-03sij-U_N0iOlrSsZFr29-IqbuF";

const metisSepolia: chains.Chain = {
  id: 59902,
  name: "Metis Sepolia",
  nativeCurrency: {
    name: "tMETIS",
    symbol: "tMETIS",
    decimals: 18,
  },
  rpcUrls: {
    default: { http: ["https://sepolia.metisdevops.link/"] },
  },
  blockExplorers: {
    default: {
      name: "Metis Sepolia Explorer",
      url: "https://sepolia-explorer.metisdevops.link/",
    },
  },
  testnet: true,
};

const scaffoldConfig = {
  targetNetworks: [chains.hardhat, metisSepolia], // Add Metis Sepolia here
  pollingInterval: 30000,
  alchemyApiKey: process.env.NEXT_PUBLIC_ALCHEMY_API_KEY || DEFAULT_ALCHEMY_API_KEY,
  walletConnectProjectId: process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID || "3a8170812b534d0ff9d794f19a901d64",
  onlyLocalBurnerWallet: true,
} as const satisfies ScaffoldConfig;

export default scaffoldConfig;
