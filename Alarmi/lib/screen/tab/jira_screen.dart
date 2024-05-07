import 'package:alarmi/common/fire_store.dart';
import 'package:alarmi/model/site.dart';
import 'package:alarmi/widget/item_site.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JiraScreen extends StatefulWidget {
  const JiraScreen({super.key});

  @override
  State<StatefulWidget> createState() => _JiraScreen();
}

class _JiraScreen extends State<JiraScreen> {
  final Stream<QuerySnapshot> _siteStream =
  FirebaseFirestore.instance.collection(DB.site.name)
      .orderBy(("id"))
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _siteStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Object error = snapshot.error ?? Exception("Something went wrong");
            return ErrorWidget(error);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator(); //로딩 화면
          }

          List<Site> sitesHome = snapshot.data!.docs.map((d) => Site.fromSnapshot(d)).toList();
          return ItemSite(sites: sitesHome, subscriptionType: DB.subscription);
        }
    );
  }
}