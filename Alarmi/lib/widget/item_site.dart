import 'package:alarmi/common/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/fire_store.dart';
import '../model/model_user.dart';
import '../model/site.dart';
import '../model/state_user.dart';

class ItemSite extends StatelessWidget {
  const ItemSite({Key? key, required this.sites}) : super(key: key);
  final List<Site> sites;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _makeBoardItem(context, sites),
    );
  }
}



List<Widget> _makeBoardItem(BuildContext context, List<Site> sites) {
  bool dd = false;
  final CollectionReference userRef = FirebaseFirestore.instance.collection(DB.user.name);
  _toggleSubscribe(flag, siteId) {
    User user = context.read<UserModel>().user;
    user.toggleSubscribe(flag, siteId);
    // user.subscriptions.add(1);
    // userRef.add(user.toMapForSubscription())
    // .get()
  }

  List<Widget> results = [];
  for (var i = 0; i < sites.length; i++) {
    results.add(InkWell(
      // 제스쳐 추가 위젯
      onTap: () {
        // context.read<UserModel>().user = User();
        // _toggleSubscribe();



        // Navigator.of(context).push(MaterialPageRoute(
        //     fullscreenDialog: true,
        //     builder: (BuildContext context) {
        //       return DetailScreen(post: posts[i]);
        //     }));
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
        child: Row(
          // children 정렬 설정
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              backgroundImage: Image.network(sites[i].image ?? defaultImage).image,
            ),
            Container(
                padding: const EdgeInsets.only(left: 15),
                child: Text(sites[i].name ?? "")
            ),
            Checkbox(
                value: true, onChanged: (bool) {
              print("탭클릭$bool");

              _toggleSubscribe(bool, sites[i].id);
            })

          ],
        ),
      ),
    ));
  }
  return results;
}