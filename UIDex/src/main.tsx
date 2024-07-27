import React from 'react';
import { createRoot } from 'react-dom/client';  
import { BrowserRouter } from 'react-router-dom';
import App from './App';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { WagmiProvider } from 'wagmi';
import { config } from '../src/hooks/config'; 

const queryClient = new QueryClient();

const rootElement = document.getElementById('root');
if (rootElement) {
  createRoot(rootElement).render(
    <React.StrictMode>
      <BrowserRouter>
      
        <WagmiProvider config={config}>
          <QueryClientProvider client={queryClient}> 
          <App />
          </QueryClientProvider> 
        </WagmiProvider>
      </BrowserRouter>
    </React.StrictMode>
  );
} else {
  console.error("Root element not found");
}
