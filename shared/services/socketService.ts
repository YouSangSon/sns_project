import { io, Socket } from 'socket.io-client';

export interface SocketEvents {
  // 메시지 이벤트
  'message:new': (message: any) => void;
  'message:read': (data: { conversationId: string; messageId: string }) => void;
  'typing:start': (data: { conversationId: string; userId: string }) => void;
  'typing:stop': (data: { conversationId: string; userId: string }) => void;

  // 알림 이벤트
  'notification:new': (notification: any) => void;

  // 게시물 이벤트
  'post:like': (data: { postId: string; userId: string }) => void;
  'post:unlike': (data: { postId: string; userId: string }) => void;
  'post:comment': (data: { postId: string; comment: any }) => void;

  // 사용자 상태
  'user:online': (userId: string) => void;
  'user:offline': (userId: string) => void;
  'user:status': (data: { userId: string; status: 'online' | 'offline' | 'away' }) => void;

  // 연결 이벤트
  connect: () => void;
  disconnect: () => void;
  error: (error: Error) => void;
}

export class SocketService {
  private socket: Socket | null = null;
  private isConnected = false;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;

  /**
   * Socket.IO 서버에 연결
   */
  connect(url: string, token?: string) {
    if (this.socket) {
      console.log('Socket already connected');
      return this.socket;
    }

    console.log('Connecting to Socket.IO server:', url);

    this.socket = io(url, {
      auth: {
        token,
      },
      transports: ['websocket', 'polling'],
      reconnection: true,
      reconnectionAttempts: this.maxReconnectAttempts,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
      timeout: 20000,
    });

    this.setupEventListeners();

    return this.socket;
  }

  /**
   * 이벤트 리스너 설정
   */
  private setupEventListeners() {
    if (!this.socket) return;

    this.socket.on('connect', () => {
      console.log('Socket connected:', this.socket?.id);
      this.isConnected = true;
      this.reconnectAttempts = 0;
    });

    this.socket.on('disconnect', (reason) => {
      console.log('Socket disconnected:', reason);
      this.isConnected = false;

      if (reason === 'io server disconnect') {
        // 서버가 연결을 끊은 경우 수동으로 재연결
        this.socket?.connect();
      }
    });

    this.socket.on('connect_error', (error) => {
      console.error('Socket connection error:', error);
      this.reconnectAttempts++;

      if (this.reconnectAttempts >= this.maxReconnectAttempts) {
        console.error('Max reconnect attempts reached');
      }
    });

    this.socket.on('error', (error) => {
      console.error('Socket error:', error);
    });
  }

  /**
   * 연결 해제
   */
  disconnect() {
    if (this.socket) {
      console.log('Disconnecting socket');
      this.socket.disconnect();
      this.socket = null;
      this.isConnected = false;
    }
  }

  /**
   * 이벤트 리스너 등록
   */
  on<K extends keyof SocketEvents>(event: K, callback: SocketEvents[K]) {
    if (this.socket) {
      this.socket.on(event as string, callback as any);
    }
  }

  /**
   * 이벤트 리스너 제거
   */
  off<K extends keyof SocketEvents>(event: K, callback?: SocketEvents[K]) {
    if (this.socket) {
      this.socket.off(event as string, callback as any);
    }
  }

  /**
   * 이벤트 발생
   */
  emit<K extends keyof SocketEvents>(event: K, ...args: any[]) {
    if (this.socket && this.isConnected) {
      this.socket.emit(event as string, ...args);
    } else {
      console.warn('Socket not connected, cannot emit event:', event);
    }
  }

  /**
   * 연결 상태 확인
   */
  getConnectionStatus(): boolean {
    return this.isConnected && this.socket?.connected === true;
  }

  /**
   * Socket 인스턴스 가져오기
   */
  getSocket(): Socket | null {
    return this.socket;
  }

  // === 메시지 관련 메서드 ===

  /**
   * 메시지 전송
   */
  sendMessage(conversationId: string, message: string) {
    this.emit('message:send' as any, { conversationId, message });
  }

  /**
   * 메시지 읽음 처리
   */
  markAsRead(conversationId: string, messageId: string) {
    this.emit('message:read', { conversationId, messageId });
  }

  /**
   * 타이핑 시작
   */
  startTyping(conversationId: string) {
    this.emit('typing:start', { conversationId });
  }

  /**
   * 타이핑 중지
   */
  stopTyping(conversationId: string) {
    this.emit('typing:stop', { conversationId });
  }

  // === 사용자 상태 관련 메서드 ===

  /**
   * 온라인 상태로 변경
   */
  setOnline() {
    this.emit('user:status' as any, { status: 'online' });
  }

  /**
   * 오프라인 상태로 변경
   */
  setOffline() {
    this.emit('user:status' as any, { status: 'offline' });
  }

  /**
   * 자리 비움 상태로 변경
   */
  setAway() {
    this.emit('user:status' as any, { status: 'away' });
  }

  // === 게시물 관련 메서드 ===

  /**
   * 게시물 좋아요 알림
   */
  notifyPostLike(postId: string) {
    this.emit('post:like', { postId });
  }

  /**
   * 게시물 좋아요 취소 알림
   */
  notifyPostUnlike(postId: string) {
    this.emit('post:unlike', { postId });
  }

  /**
   * 댓글 작성 알림
   */
  notifyPostComment(postId: string, comment: any) {
    this.emit('post:comment', { postId, comment });
  }

  // === 방 (Room) 관련 메서드 ===

  /**
   * 방 참여
   */
  joinRoom(roomId: string) {
    this.emit('room:join' as any, { roomId });
  }

  /**
   * 방 나가기
   */
  leaveRoom(roomId: string) {
    this.emit('room:leave' as any, { roomId });
  }
}

// Singleton 인스턴스
export const socketService = new SocketService();
