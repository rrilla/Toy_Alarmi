import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final int? siteId;
  final String? userId;
  late final Timestamp? created;
  late final DocumentReference reference;

  Subscription({
    this.siteId,
    this.userId
  });

  Subscription.fromMap(Map<String, dynamic> map, {required this.reference})
      : siteId = map['siteId'],
        userId = map['userId'],
        created = map['created'];

  Subscription.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, reference: snapshot.reference);

  Map<String, dynamic> toMap() {
    return {
      'siteId': siteId,
      'userId': userId,
      'created': DateTime.now(),
    };
  }

  @override
  String toString() {
    return 'Subscription{siteId: $siteId, userId: $userId, created: $created, reference: $reference}';
  }

// String getDateCreated() {
  //   return "${dateCreated.toDate().month} 월 ${dateCreated.toDate().day} 일";
  // }


}
