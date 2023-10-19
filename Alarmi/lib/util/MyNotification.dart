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
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    // 토큰 요청
    getToken();
    // 셋팅flag 설정
    isFlutterLocalNotificationsInitialized = true;
  }
}