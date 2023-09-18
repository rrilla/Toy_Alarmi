import 'package:alarmi/model/subscription.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Site {
  final int? id;
  final String? name;
  final String? url;
  final String? image;
  // final Timestamp dateCreated;
  Subscription? subscription;
  final DocumentReference reference;

  Site.fromMap(Map<String, dynamic> map, {required this.reference})
      : id = map['id'],
        name = map['name'],
        url = map['url'],
        image = map['image'];

  Site.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>, reference: snapshot.reference);

  @override
  String toString() {
    return 'Site{id: $id, name: $name, url: $url, image: $image, subcription: $subscription, reference: $reference}';
  }

// String getDateCreated() {
  //   return "${dateCreated.toDate().month} 월 ${dateCreated.toDate().day} 일";
  // }


}
