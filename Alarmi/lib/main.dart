import 'package:alarmi/common/theme.dart';
import 'package:alarmi/model/state_user.dart';
import 'package:alarmi/screen/home_screen.dart';
import 'package:alarmi/screen/login_screen.dart';
import 'package:alarmi/util/MyNotification.dart';
import 'package:alarmi/util/extension.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  // MyNotification myNoti = MyNotification();
  // await myNoti.setupFlutterNotifications();
  // showFlutterNotification(message, myNoti);

  print("HIHIHIHIHIH");
  //showFlutterNotification(message);  // 로컬노티
}

Future<void> _handleMessage(RemoteMessage message) async {
  // 내가 지정한 그 알람이면? 지정한 화면으로 이동
  // if (message.data['data1'] == 'value1') {
  //   Navigator.pushNamed(context, '/notification'); // main에서는 이동불가 Home에 들어와서 해줘야함
  // }
  print("in handleMessage");
  dynamic url = message.data['url'];
  print("url : $url");
  if (url != null) {
    print(url);
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch ${Uri.parse(url)}');
    }
  }
}

void showFlutterNotification(RemoteMessage message, MyNotification myNoti) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;


  if (notification != null && android != null && !kIsWeb) { // 웹이 아니면서 안드로이드이고, 알림이 있는경우
    myNoti.flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      message.data['url'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          myNoti.channel.id,
          myNoti.channel.name,
          channelDescription: myNoti.channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'launch_background',
        ),
      ),
    );
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  KakaoSdk.init(
    nativeAppKey: dotenv.env['kakaoNativeAppKey'],
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await MyNotification().setupFlutterNotifications();

  runApp(ChangeNotifierProvider(
    create: (context) => UserModel(),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((event) {_handleMessage(event);});
    FirebaseMessaging.onMessage.listen((event) {print("in foreground");});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: appTheme,
      routes: {
        "/login": (_) => const LoginScreen(),
        "/home": (_) => const HomeScreen(),
      },
      // home: Consumer<UserModel>(
      //   builder: (context, user, child) {
      //     return !user.user.isLogin()
      //         ? const LoginScreen()
      //         : const HomeScreen();
      //   },
      // ),
      home: context.watch<UserModel>().user.isLogin() ? const HomeScreen() : const LoginScreen(),
    );
  }
}