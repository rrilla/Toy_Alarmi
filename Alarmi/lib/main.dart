import 'package:alarmi/common/theme.dart';
import 'package:alarmi/model/state_user.dart';
import 'package:alarmi/screen/home_screen.dart';
import 'package:alarmi/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  KakaoSdk.init(
    nativeAppKey: '861366959bc224d580eacbca96e41d26',
  );
  WidgetsFlutterBinding.ensureInitialized();
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