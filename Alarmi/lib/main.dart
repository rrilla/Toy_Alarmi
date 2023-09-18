import 'package:alarmi/common/theme.dart';
import 'package:alarmi/model/state_user.dart';
import 'package:alarmi/screen/home_screen.dart';
import 'package:alarmi/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  KakaoSdk.init(
    nativeAppKey: dotenv.env['kakaoNativeAppKey'],
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ChangeNotifierProvider(
    create: (context) => UserModel(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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