import 'package:alarmi/model/model_user.dart';
import 'package:alarmi/screen/bottom_bar.dart';
import 'package:alarmi/screen/tab/jira_screen.dart';
import 'package:alarmi/screen/tab/real_estate_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';

import '../model/state_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
                title: const Text("알림 설정"),
                actions: [
                  TextButton(
                    onPressed: _logout,
                    child: const Text(
                        "로그아웃", style: TextStyle(color: Colors.white)),
                  )
                ]
            ),
            bottomNavigationBar: const Bottom(),
            body: const TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                JiraScreen(),
                RealEstateScreen()
              ],
            )));
  }

  _logout() async {
    try {
      if (context
          .read<UserModel>()
          .user
          .type == SocialType.kakao) {
        await UserApi.instance.logout();
        print('로그아웃 성공 - 카카오');
      } else {
        await GoogleSignIn().signOut();
        print('로그아웃 성공 - 구글');
      }
      await context.read<UserModel>().user.clearUser();
      context.read<UserModel>().remove();
    } catch (error) {
      await context.read<UserModel>().user.clearUser();
      context.read<UserModel>().remove();
      print('로그아웃 실패, SDK에서 토큰 삭제 $error');
    }
  }
}
