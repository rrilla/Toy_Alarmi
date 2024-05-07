import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyNotification {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;
  bool isFlutterLocalNotificationsInitialized = false; // 셋팅여부 판단 flag

  Future<void> getToken() async {
    // ios
    String? token;
    if(defaultTargetPlatform == TargetPlatform.iOS ||defaultTargetPlatform == TargetPlatform.macOS) {
      token = await FirebaseMessaging.instance.getAPNSToken();
    }
    // aos
    else{
      token = await FirebaseMessaging.instance.getToken();
    }
    print("fcmToken : $token");
  }

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);


    // iOS foreground notification 권한
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    // IOS background 권한 체킹 , 요청
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
    /**
     * authorized: 사용자가 권한을 부여했습니다.
     * denied: 용자가 사용 권한을 거부했습니다.
     * notDetermined: 사용자가 권한을 부여할지 여부를 아직 선택하지 않았습니다.
     * provisional: 사용자가 임시 권한을 부여했습니다
     * */


    // 토큰 요청
    getToken();
    // 셋팅flag 설정
    isFlutterLocalNotificationsInitialized = true;
  }
}