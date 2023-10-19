import 'package:alarmi/common/fire_store.dart';
import 'package:alarmi/model/model_user.dart';
import 'package:alarmi/screen/bottom_bar.dart';
import 'package:alarmi/widget/item_site.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';

import '../model/site.dart';
import '../model/state_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Stream<QuerySnapshot> _siteStream =
  FirebaseFirestore.instance.collection(DB.site.name)
      .orderBy(("id"))
      .snapshots();

  final Stream<QuerySnapshot> _siteHomeStream =
  FirebaseFirestore.instance.collection(DB.siteHome.name)
      .orderBy(("id"))
      .snapshots();

  Widget _fetchData(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _siteStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Object error = snapshot.error ?? Exception("Something went wrong");
          return ErrorWidget(error);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator(); //로딩 화면
        }

        return _buildBody(context, snapshot.data!.docs);
      },
    );
  }

  Widget _buildBody(BuildContext context, List<DocumentSnapshot> snapshot) {
    List<Site> sites = snapshot.map((d) => Site.fromSnapshot(d)).toList();
    print(sites);
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ItemSite(sites: sites, subscriptionType: DB.subscription),
        StreamBuilder(
          stream: _siteHomeStream,
          builder: (context, snapshot2) {
            if (snapshot2.hasError) {
              Object error = snapshot2.error ?? Exception("Something went wrong");
              return ErrorWidget(error);
            }
            if (snapshot2.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator(); //로딩 화면
            }

            List<Site> sitesHome = snapshot2.data!.docs.map((d) => Site.fromSnapshot(d)).toList();
            return ItemSite(sites: sitesHome, subscriptionType: DB.subscriptionHome,);
          }
        )
        //  widget 하나 추가.
      ],
    );
  }

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
            body: _fetchData(context)));
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
      context.read<UserModel>().remove();
    } catch (error) {
      print('로그아웃 실패, SDK에서 토큰 삭제 $error');
    }
  }
}
