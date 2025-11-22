import { useEffect, useRef, useState } from 'react';
import * as Notifications from 'expo-notifications';
import { useNavigation } from '@react-navigation/native';
import { notificationService } from '../services/notificationService';

export function useNotifications() {
  const [pushToken, setPushToken] = useState<string | null>(null);
  const [notification, setNotification] = useState<Notifications.Notification | null>(null);
  const notificationListener = useRef<any>();
  const responseListener = useRef<any>();
  const navigation = useNavigation();

  useEffect(() => {
    // 푸시 알림 등록
    registerForPushNotifications();

    // 알림 수신 리스너
    notificationListener.current = notificationService.addNotificationReceivedListener(
      (notification) => {
        console.log('알림 수신:', notification);
        setNotification(notification);
      }
    );

    // 알림 응답 리스너 (사용자가 알림을 탭했을 때)
    responseListener.current = notificationService.addNotificationResponseReceivedListener(
      (response) => {
        console.log('알림 응답:', response);
        handleNotificationResponse(response);
      }
    );

    return () => {
      if (notificationListener.current) {
        Notifications.removeNotificationSubscription(notificationListener.current);
      }
      if (responseListener.current) {
        Notifications.removeNotificationSubscription(responseListener.current);
      }
    };
  }, []);

  const registerForPushNotifications = async () => {
    const token = await notificationService.registerForPushNotifications();
    setPushToken(token);
  };

  const handleNotificationResponse = (response: Notifications.NotificationResponse) => {
    const data = response.notification.request.content.data;

    // 알림 타입에 따라 적절한 화면으로 이동
    if (data?.type === 'like') {
      // 좋아요 알림 - 게시물 상세 화면으로 이동
      if (data.postId) {
        navigation.navigate('PostDetail' as never, { postId: data.postId } as never);
      }
    } else if (data?.type === 'comment') {
      // 댓글 알림 - 게시물 상세 화면으로 이동
      if (data.postId) {
        navigation.navigate('PostDetail' as never, { postId: data.postId } as never);
      }
    } else if (data?.type === 'follow') {
      // 팔로우 알림 - 프로필 화면으로 이동
      if (data.userId) {
        navigation.navigate('Profile' as never, { userId: data.userId } as never);
      }
    } else if (data?.type === 'message') {
      // 메시지 알림 - 채팅 화면으로 이동
      if (data.conversationId) {
        navigation.navigate('Chat' as never, { conversationId: data.conversationId } as never);
      }
    }

    // 배지 카운트 감소
    notificationService.clearBadgeCount();
  };

  return {
    pushToken,
    notification,
    sendLocalNotification: notificationService.showLocalNotification.bind(notificationService),
    cancelAllNotifications: notificationService.cancelAllNotifications.bind(notificationService),
    setBadgeCount: notificationService.setBadgeCount.bind(notificationService),
    clearBadgeCount: notificationService.clearBadgeCount.bind(notificationService),
  };
}
