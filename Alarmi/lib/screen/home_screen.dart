import 'package:alarmi/common/fire_store.dart';
import 'package:alarmi/widget/item_site.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/site.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Stream<QuerySnapshot> _siteStream =
      FirebaseFirestore.instance.collection(DB.site.name).orderBy(("id")).snapshots();

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

  Widget _buildBody(
      BuildContext context, List<DocumentSnapshot> snapshot) {
    List<Site> sites = snapshot.map((d) => Site.fromSnapshot(d)).toList();
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ItemSite(sites: sites)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 1,
        child: Scaffold(
            appBar: AppBar(title: const Text("알림 설정")),
            body: _fetchData(context)));
  }
}
