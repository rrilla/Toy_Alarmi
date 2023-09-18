import 'package:alarmi/common/strings.dart';
import 'package:alarmi/util/extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/fire_store.dart';
import '../model/model_user.dart';
import '../model/site.dart';
import '../model/state_user.dart';
import '../model/subscription.dart';

class ItemSite extends StatefulWidget {
  const ItemSite({Key? key, required this.sites}) : super(key: key);
  final List<Site> sites;

  @override
  State<StatefulWidget> createState() => _ItemSiteState();
}

class _ItemSiteState extends State<ItemSite> {
  late final List<Site> _sites;
  late final User _user;
  late final CollectionReference _subscriptionRef;

  @override
  void initState() {
    super.initState();
    _sites = widget.sites;
    _user = context.read<UserModel>().user;
    _subscriptionRef = FirebaseFirestore.instance.collection(DB.subscription.name);
  }

  @override
  Widget build(BuildContext context) {
    return _fetchData(context);
  }

  toggleSubscribe(bool? flag, int index) {
    if (flag ?? false) {
      Subscription subscription = Subscription(siteId: _sites[index].id, userId: _user.id);
      _subscriptionRef.add(subscription.toMap())
        .then((value) => {
          setState(() {
            subscription.reference = value;
            _sites[index].subscription = subscription;
          }),
          showMsg(context, "'${_sites[index].name}' 알림 설정 완료.")
        }
      ).catchError((error) => showMsg(context, "알림 설정 실패. \n($error)"));
    } else {
      _subscriptionRef.doc(_sites[index].subscription?.reference.id).delete()
        .then((value) => {
        setState(() {
        _sites[index].subscription = null;
        })
      })
        .catchError((error) => showMsg(context, "알림 설정 실패. \n($error)"));
      _subscriptionRef.where("userId", isEqualTo: _user.id).where("siteId", isEqualTo: _sites[index].id).get().then((value) => {
        _subscriptionRef.doc(value.docs.first.reference.id).delete()
      });
    }
  }

  Widget _fetchData(BuildContext context) {
    final Stream<QuerySnapshot> subscriptionStream = _subscriptionRef.where("userId", isEqualTo: _user.id).snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: subscriptionStream,
      builder: (context, snapshot) {

        if (snapshot.data != null) {
          List<Subscription> subscriptions = snapshot.data!.docs.map((e) => Subscription.fromSnapshot(e)).toList();
          _sites.forEach((site) => subscriptions.forEach((subscription) {
            if (subscription.siteId == site.id) site.subscription = subscription;
          }));
        }
        return _buildBody();
      },
    );
  }

  Widget _buildBody() {
    List<Widget> results = [];
    for (var i = 0; i < _sites.length; i++) {
      // 제스쳐 추가 위젯
      results.add(InkWell(
        onTap: () {
          toggleSubscribe(_sites[i].subscription != null, i);
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
                backgroundImage: Image.network(_sites[i].image ?? defaultImage).image,
              ),
              Container(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(_sites[i].name ?? "")
              ),
              Checkbox(
                  value: _sites[i].subscription != null, onChanged: (flag) => toggleSubscribe(flag, i))
            ],
          ),
        ),
      ));
    }

    return ListView(
      children: results,
    );
  }
}

// Widget _fecthData(BuildContext context) {
//   return
// }