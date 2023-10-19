import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao_user;
import 'package:shared_preferences/shared_preferences.dart';

class User {
  static const String prefId = "pref_id";
  static const String prefNickname = "pref_nickname";
  static const String prefImage = "pref_image";
  static const String prefEmail = "pref_email";
  static const String prefType = "pref_type";
  static const String prefCreated = "pref_created";
  static const String prefToken = "pref_token";
  static const String prefReference = "pref_reference";

  final String? id;
  final String? nickname;
  final String? image;
  final String? email;
  final SocialType? type;
  final Timestamp? created;
  String? token;
  late final DocumentReference? reference;

  User({
    this.id,
    this.nickname,
    this.image,
    this.email,
    this.type,
    this.created,
    this.token,
    this.reference,
  });

  User.fromMap(Map<String, dynamic> map, {required this.reference})
      : id = map['id'],
        nickname = map['nickname'],
        image = map['image'],
        email = map['email'],
        type = map['type'] == "kakao" ? SocialType.kakao : SocialType.google,
        token = map['token'],
        created = map['created'];

  User.fromKakao(kakao_user.User user)
      : id = user.id.toString(),
        nickname = user.kakaoAccount?.profile?.nickname,
        image = user.kakaoAccount?.profile?.thumbnailImageUrl ?? "https://d2u3dcdbebyaiu.cloudfront.net/uploads/atch_img/309/59932b0eb046f9fa3e063b8875032edd_crop.jpeg",
        email = user.kakaoAccount?.email,
        type = SocialType.kakao,
        created = Timestamp.fromMicrosecondsSinceEpoch(DateTime.now().microsecondsSinceEpoch);

  User.fromGoogle(GoogleSignInAccount user)
      : id = user.id,
        nickname = user.displayName,
        image = user.photoUrl ?? "https://static-00.iconduck.com/assets.00/google-icon-2048x2048-czn3g8x8.png",
        email = user.email,
        type = SocialType.google,
        created = Timestamp.fromMicrosecondsSinceEpoch(DateTime.now().microsecondsSinceEpoch);
  //https://play-lh.googleusercontent.com/38AGKCqmbjZ9OuWx4YjssAz3Y0DTWbiM5HB0ove1pNBq_o9mtWfGszjZNxZdwt_vgHo

  User.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data() as Map<String, dynamic>, reference: snapshot.reference);
  
  Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return User(
        id: prefs.getString(prefId),
        email: prefs.getString(prefEmail),
        nickname: prefs.getString(prefNickname),
        image: prefs.getString(prefImage),
        token: prefs.getString(prefToken),
        type: prefs.getString(prefType) == SocialType.kakao.name ? SocialType.kakao : SocialType.google
    );
  }

  saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null || type == null) return;

    print("hjh not null");
    prefs.setString(prefId, id!);
    prefs.setString(prefType, type!.name);

    if (email != null) {
      prefs.setString(prefEmail, email!);
    }
    if (nickname != null) {
      prefs.setString(prefNickname, email!);
    }
    if (image != null) {
      prefs.setString(prefImage, email!);
    }
  }

  Map<String, dynamic> toMapForToken() {
    return {
      'token': token
    };
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (image != null) 'image': image,
      if (email != null) 'email': email,
      if (type != null) 'type': type?.name,
      if (token != null) 'token': token,
      'created': created ?? DateTime.now(),
    };
  }

  bool isLogin() {
    return id != null || nickname != null || image != null;
    // return true;
  }

  // deleteSubscribe(int siteId) {
  //   subscriptions?.remove(siteId);
  // }

  @override
  String toString() {
    return 'User{id: $id, nickname: $nickname, image: $image, email: $email, type: $type, created: $created, reference: $reference}';
  }
}

enum SocialType {
  google("google"),
  kakao("kakao");

  const SocialType(this.name);
  final String name;
}
