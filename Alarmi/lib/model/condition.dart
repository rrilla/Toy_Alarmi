import 'package:cloud_firestore/cloud_firestore.dart';

class Condition {
  final String? userId;
  final int? deposit;
  final int? monthlyRent;
  late final Timestamp? created;
  late final DocumentReference reference;

  Condition(
    this.userId,
    this.deposit,
    this.monthlyRent
  );

  Condition.fromMap(Map<String, dynamic> map, {required this.reference})
      : userId = map['userId'],
        deposit = map['deposit'],
        monthlyRent = map['monthly_rent'],
        created = map['created'];

  Condition.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, reference: snapshot.reference);

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'deposit': deposit,
      'monthly_rent': monthlyRent,
      'created': DateTime.now(),
    };
  }

  @override
  String toString() {
    return 'Condition{userId: $userId, deposit: $deposit, monthlyRent: $monthlyRent, created: $created, reference: $reference}';
  }

// String getDateCreated() {
  //   return "${dateCreated.toDate().month} 월 ${dateCreated.toDate().day} 일";
  // }


}
