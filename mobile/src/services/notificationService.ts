import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import { Platform } from 'react-native';

// Notification 기본 동작 설정
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

export class NotificationService {
  private pushToken: string | null = null;

  /**
   * 푸시 알림 권한 요청 및 토큰 얻기
   */
  async registerForPushNotifications(): Promise<string | null> {
    try {
      // 실제 디바이스가 아니면 푸시 알림 불가
      if (!Device.isDevice) {
        console.log('푸시 알림은 실제 기기에서만 작동합니다');
        return null;
      }

      // 권한 상태 확인
      const { status: existingStatus } = await Notifications.getPermissionsAsync();
      let finalStatus = existingStatus;

      // 권한이 없으면 요청
      if (existingStatus !== 'granted') {
        const { status } = await Notifications.requestPermissionsAsync();
        finalStatus = status;
      }

      // 권한이 거부되면 종료
      if (finalStatus !== 'granted') {
        console.log('푸시 알림 권한이 거부되었습니다');
        return null;
      }

      // Expo 푸시 토큰 얻기
      const tokenData = await Notifications.getExpoPushTokenAsync({
        projectId: 'your-expo-project-id', // Expo 프로젝트 ID로 변경하세요
      });

      this.pushToken = tokenData.data;
      console.log('푸시 토큰:', this.pushToken);

      // Android용 알림 채널 설정
      if (Platform.OS === 'android') {
        await this.setupAndroidNotificationChannels();
      }

      return this.pushToken;
    } catch (error) {
      console.error('푸시 알림 등록 실패:', error);
      return null;
    }
  }

  /**
   * Android 알림 채널 설정
   */
  private async setupAndroidNotificationChannels() {
    // 기본 채널
    await Notifications.setNotificationChannelAsync('default', {
      name: '기본',
      importance: Notifications.AndroidImportance.MAX,
      vibrationPattern: [0, 250, 250, 250],
      lightColor: '#007AFF',
    });

    // 좋아요 채널
    await Notifications.setNotificationChannelAsync('likes', {
      name: '좋아요',
      importance: Notifications.AndroidImportance.DEFAULT,
      vibrationPattern: [0, 250],
      lightColor: '#FF3B5C',
    });

    // 댓글 채널
    await Notifications.setNotificationChannelAsync('comments', {
      name: '댓글',
      importance: Notifications.AndroidImportance.HIGH,
      vibrationPattern: [0, 250, 250, 250],
      lightColor: '#007AFF',
    });

    // 팔로우 채널
    await Notifications.setNotificationChannelAsync('follows', {
      name: '팔로우',
      importance: Notifications.AndroidImportance.DEFAULT,
      vibrationPattern: [0, 250],
      lightColor: '#34C759',
    });

    // 메시지 채널
    await Notifications.setNotificationChannelAsync('messages', {
      name: '메시지',
      importance: Notifications.AndroidImportance.MAX,
      vibrationPattern: [0, 250, 250, 250],
      lightColor: '#007AFF',
      sound: 'default',
    });
  }

  /**
   * 로컬 알림 예약
   */
  async scheduleLocalNotification(
    title: string,
    body: string,
    data?: any,
    channelId: string = 'default'
  ): Promise<string> {
    const notificationId = await Notifications.scheduleNotificationAsync({
      content: {
        title,
        body,
        data,
        sound: true,
        priority: Notifications.AndroidNotificationPriority.HIGH,
      },
      trigger: null, // 즉시 표시
    });

    return notificationId;
  }

  /**
   * 즉시 로컬 알림 표시
   */
  async showLocalNotification(
    title: string,
    body: string,
    data?: any,
    channelId: string = 'default'
  ) {
    await Notifications.scheduleNotificationAsync({
      content: {
        title,
        body,
        data,
        sound: true,
        priority: Notifications.AndroidNotificationPriority.HIGH,
        ...(Platform.OS === 'android' && { channelId }),
      },
      trigger: null,
    });
  }

  /**
   * 모든 알림 취소
   */
  async cancelAllNotifications() {
    await Notifications.cancelAllScheduledNotificationsAsync();
  }

  /**
   * 특정 알림 취소
   */
  async cancelNotification(notificationId: string) {
    await Notifications.cancelScheduledNotificationAsync(notificationId);
  }

  /**
   * 배지 카운트 설정 (iOS)
   */
  async setBadgeCount(count: number) {
    await Notifications.setBadgeCountAsync(count);
  }

  /**
   * 배지 카운트 증가
   */
  async incrementBadgeCount() {
    const currentCount = await Notifications.getBadgeCountAsync();
    await Notifications.setBadgeCountAsync(currentCount + 1);
  }

  /**
   * 배지 카운트 초기화
   */
  async clearBadgeCount() {
    await Notifications.setBadgeCountAsync(0);
  }

  /**
   * 알림 수신 리스너 등록
   */
  addNotificationReceivedListener(
    callback: (notification: Notifications.Notification) => void
  ) {
    return Notifications.addNotificationReceivedListener(callback);
  }

  /**
   * 알림 응답 리스너 등록 (사용자가 알림을 탭했을 때)
   */
  addNotificationResponseReceivedListener(
    callback: (response: Notifications.NotificationResponse) => void
  ) {
    return Notifications.addNotificationResponseReceivedListener(callback);
  }

  /**
   * 푸시 토큰 가져오기
   */
  getPushToken(): string | null {
    return this.pushToken;
  }
}

export const notificationService = new NotificationService();
