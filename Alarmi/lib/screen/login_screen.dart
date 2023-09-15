import 'package:alarmi/common/fire_store.dart';
import 'package:alarmi/common/theme.dart';
import 'package:alarmi/model/state_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alarmi/model/model_user.dart' as my_user;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = false;
  final CollectionReference userRef = FirebaseFirestore.instance.collection(DB.user.name);

  _checkTokenFromKakao() async {
    try {
      await UserApi.instance.accessTokenInfo();
      setState(() {
        isLogin = true;
      });
    } catch (error) {
      if (error is KakaoException && error.isInvalidTokenError()) {
        print('토큰 만료 $error');
      } else {
        print('토큰 정보 조회 실패 $error');
      }
    }
  }

  _signInWithKakao() async {
    print("login click");
    // 카카오톡 설치 여부 확인
    if (await isKakaoTalkInstalled()) {
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공 ${token.accessToken}');

        User kakaoUser = await UserApi.instance.me();

        print('사용자 정보 요청 성공'
            '\n회원번호: ${kakaoUser.id}'
            '\n이메일: ${kakaoUser.kakaoAccount?.email}'
            '\n이미지: ${kakaoUser.kakaoAccount?.profile?.profileImageUrl}'
            '\n이미지썸넬: ${kakaoUser.kakaoAccount?.profile?.thumbnailImageUrl}'
            '\n닉네임: ${kakaoUser.kakaoAccount?.profile?.nickname}');

        _loginSuccess(my_user.User.fromKakao(kakaoUser));
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {}
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        Fluttertoast.showToast(msg: "카톡 깔려있는데 로그인 안되있음.");
      }
    } else {
      Fluttertoast.showToast(msg: "서버 없다. 카톡 아닐시 카카오 로그인 안됨. 구글 써주세요.");
    }
  }

  _signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // // Obtain the auth details from the request
    // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    if (googleUser != null) {
      print("google : ${googleUser.email} / ${googleUser.displayName} / ${googleUser.id} / ${googleUser.photoUrl} / ${googleUser.serverAuthCode}");
      _loginSuccess(my_user.User.fromGoogle(googleUser));
    } else {
      Fluttertoast.showToast(msg: "googleUser is Null!");
    }
  }

  _loginSuccess(my_user.User user) async {
    if (user.id != null) {
      userRef
          .where('id', isEqualTo: user.id)
          .get().then((value) => {
            if (value.docs.isEmpty) {
              userRef.add(user.toMap()).then((value) {
              print("hjh add id : ${value.id}");
              context.read<UserModel>().user = user;
              }).catchError((error) => print("Failed to add user: $error"))
            } else {
              context.read<UserModel>().user = my_user.User.fromSnapshot(value.docs.first)
            }
    }).catchError((error) => print("Failed to find user: $error"));

    } else {
      Fluttertoast.showToast(msg: "social id 가 없음. \n 다시 해보셈.");
    }
  }

  _loginFailed() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage('images/kakao_logo.png'),
            ),
            Container(
              padding: const EdgeInsets.only(top: 15),
              child: const Text(
                appName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.white),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              width: 130,
              height: 5,
              color: Colors.red,
            ),
            Container(
              width: 240,
              height: 60,
              margin: const EdgeInsets.only(top: 10),
              // padding: const EdgeInsets.fromLTRB(50, 15, 50, 15),
              child: TextButton(
                onPressed: () {
                  _signInWithKakao();
                },
                child:
                Image.asset('images/kakao_login_medium_narrow.png'),
              ),
            ),
            Container(
              width: 240,
              height: 60,
              // padding: const EdgeInsets.fromLTRB(50, 15, 50, 15),
              child: TextButton(
                onPressed: () {
                  _signInWithGoogle();
                },
                child:
                Image.asset('images/google_login.png'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
