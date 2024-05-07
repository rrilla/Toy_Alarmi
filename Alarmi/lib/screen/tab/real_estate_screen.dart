import 'package:alarmi/common/fire_store.dart';
import 'package:alarmi/model/condition.dart';
import 'package:alarmi/model/model_user.dart';
import 'package:alarmi/model/site.dart';
import 'package:alarmi/model/state_user.dart';
import 'package:alarmi/util/extension.dart';
import 'package:alarmi/widget/item_site.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RealEstateScreen extends StatefulWidget {
  const RealEstateScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RealEstateScreen();
}

class _RealEstateScreen extends State<RealEstateScreen> {
  late User _user;
  late final CollectionReference _conditionRef;

  @override
  void initState() {
    super.initState();

    _user = context.read<UserModel>().user;
    _conditionRef = FirebaseFirestore.instance
        .collection(DB.condition.name);
  }

  final Stream<QuerySnapshot> _siteHomeStream = FirebaseFirestore.instance
      .collection(DB.siteHome.name)
      .orderBy(("id"))
      .snapshots();

  final TextEditingController _textFieldController1 = TextEditingController();
  final TextEditingController _textFieldController2 = TextEditingController();


  saveCondition() {
    try {
      int deposit = int.parse(_textFieldController1.text);
      int monthlyRent = int.parse(_textFieldController2.text);

      if (deposit >= 1000000) {
        showMsg(context, "보증금은 100억을 넘을 수 없음.");
        return;
      }

      if (monthlyRent >= 10000) {
        showMsg(context, "월세는 억을 넘을 수 없음.");
        return;
      }

      _conditionRef.where("userId", isEqualTo: _user.id)
          .get().then((value) {
        Condition condition = Condition(_user.id, deposit, monthlyRent);
        if (value.docs.isEmpty) {
          _conditionRef.add(condition.toMap()).then(
            (value) => Navigator.pop(context),
          ).catchError((error) {
            showMsg(context, "조건 등록 실패 : $error");
          });
        } else {
          _conditionRef.doc(value.docs.first.id).update(condition.toMap()).then(
              (value) => Navigator.pop(context)
          ).catchError((error) {
            showMsg(context, "조건 등록 실패 : $error");
          });
        }
      }).catchError((error) {
        showMsg(context, "조건 등록 실패 : $error");
      });
    } catch(e) {
      showMsg(context, "에러 발생 : $e");
    }
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    _conditionRef.where("userId", isEqualTo: context.read<UserModel>().user.id)
        .get().then((value) {
      if (value.docs.isNotEmpty) {
        Condition condition = Condition.fromSnapshot(value.docs.first);
        print(condition);
        _textFieldController1.value = TextEditingValue(text: condition.deposit.toString());
        _textFieldController2.value = TextEditingValue(text: condition.monthlyRent.toString());
      }
    });

    return showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('알림 조건 설정'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text("*단위는 만원임.", style: TextStyle(color: Colors.red)),
                  SizedBox(height: 20),
                  Text("보증금"),
                  TextField(
                    onChanged: (value) {
                    },
                    controller: _textFieldController1,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(hintText: "ex) 1억 5000 -> 15000"),
                  ),
                  SizedBox(height: 20),
                  const Text("월세"),
                  TextField(
                    onChanged: (value) {
                    },
                    controller: _textFieldController2,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(hintText: "ex) 30만원 -> 30"),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('CANCEL'),
                onPressed: () {
                    Navigator.pop(context);
                },
              ),
              MaterialButton(
                color: Colors.deepPurpleAccent,
                textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () {
                  saveCondition();
                },
              ),
            ],
          );
        });
  }

  String? valueText;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(20, 10 , 20, 10),
          child: Column(
            children: [
              ElevatedButton(onPressed: () => _displayTextInputDialog(context), child: Text("알림 조건 설정"))
              // Text("조건"),
              // Row(
              //   children: [
              //     Text("보증금"),
              //   ],
              // ),
              // SizedBox(height: 10),
              // Row(
              //   children: [
              //     Text("월세"),
              //   ],
              // ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Expanded(
            child: StreamBuilder(
                stream: _siteHomeStream,
                builder: (context, snapshot2) {
                  if (snapshot2.hasError) {
                    Object error =
                        snapshot2.error ?? Exception("Something went wrong");
                    return ErrorWidget(error);
                  }
                  if (snapshot2.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator(); //로딩 화면
                  }

                  List<Site> sitesHome = snapshot2.data!.docs
                      .map((d) => Site.fromSnapshot(d))
                      .toList();
                  return ItemSite(
                    sites: sitesHome,
                    subscriptionType: DB.subscriptionHome,
                  );
                }))
      ],
    );
  }
}
