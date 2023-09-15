import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao_user;

class User {
  final String? id;
  final String? nickname;
  final String? image;
  final String? email;
  final SocialType? type;
  final Timestamp? created;
  List<int>? subscriptions;
  final DocumentReference? reference;

  User({
    this.id,
    this.nickname,
    this.image,
    this.email,
    this.type,
    this.created,
    this.subscriptions,
    this.reference,
  });

  User.fromMap(Map<String, dynamic> map, {required this.reference})
      : id = map['id'],
        nickname = map['nickname'],
        image = map['image'],
        email = map['email'],
        type = map['type'] == "kakao" ? SocialType.kakao : SocialType.google,
        created = map['created'],
        subscriptions = map['subscriptions'];

  User.fromKakao(kakao_user.User user)
      : id = user.id.toString(),
        nickname = user.kakaoAccount?.profile?.nickname,
        image = user.kakaoAccount?.profile?.thumbnailImageUrl ?? "https://d2u3dcdbebyaiu.cloudfront.net/uploads/atch_img/309/59932b0eb046f9fa3e063b8875032edd_crop.jpeg",
        email = user.kakaoAccount?.email,
        type = SocialType.kakao,
        created = Timestamp.fromMicrosecondsSinceEpoch(DateTime.now().microsecondsSinceEpoch),
        subscriptions = null,
        reference = null;

  User.fromGoogle(GoogleSignInAccount user)
      : id = user.id,
        nickname = user.displayName,
        image = user.photoUrl ?? "https://static-00.iconduck.com/assets.00/google-icon-2048x2048-czn3g8x8.png",
        email = user.email,
        type = SocialType.google,
        created = Timestamp.fromMicrosecondsSinceEpoch(DateTime.now().microsecondsSinceEpoch),
        subscriptions = null,
        reference = null;
  //https://play-lh.googleusercontent.com/38AGKCqmbjZ9OuWx4YjssAz3Y0DTWbiM5HB0ove1pNBq_o9mtWfGszjZNxZdwt_vgHo

  User.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data() as Map<String, dynamic>, reference: snapshot.reference);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (image != null) 'image': image,
      if (email != null) 'email': email,
      if (type != null) 'type': type?.name,
      'created': created ?? DateTime.now(),
      'subscriptions': subscriptions
    };
  }

  Map<String, dynamic> toMapForSubscription() {
   return {
     'subscriptions': subscriptions
   };
  }

  bool isLogin() {
    return id != null || nickname != null || image != null;
    // return true;
  }

  toggleSubscribe(bool flag, int siteId) {
    if (subscriptions == null) {
      if (flag) subscriptions = [siteId];
    } else {
      flag ? subscriptions!.add(siteId) : subscriptions!.remove(siteId);
    }
    print(subscriptions.toString());
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
