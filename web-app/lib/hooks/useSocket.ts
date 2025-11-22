import { useEffect, useRef, useState } from 'react';
import { socketService, SocketEvents } from '@shared/services/socketService';

export function useSocket(url?: string, token?: string) {
  const [isConnected, setIsConnected] = useState(false);
  const hasConnected = useRef(false);

  useEffect(() => {
    if (!url || hasConnected.current) return;

    const socketUrl = url || process.env.NEXT_PUBLIC_SOCKET_URL || 'http://localhost:3001';
    
    socketService.connect(socketUrl, token);
    hasConnected.current = true;

    // 연결 상태 리스너
    socketService.on('connect', () => {
      setIsConnected(true);
    });

    socketService.on('disconnect', () => {
      setIsConnected(false);
    });

    return () => {
      if (!url) {
        socketService.disconnect();
        hasConnected.current = false;
      }
    };
  }, [url, token]);

  return {
    socket: socketService,
    isConnected,
  };
}

export function useSocketEvent<K extends keyof SocketEvents>(
  event: K,
  callback: SocketEvents[K]
) {
  useEffect(() => {
    socketService.on(event, callback);

    return () => {
      socketService.off(event, callback);
    };
  }, [event, callback]);
}
