import 'package:flutter/material.dart';

class Bottom extends StatelessWidget {
  const Bottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Expanded(
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.transparent,
          tabs: <Widget>[
            Tab(
              icon: Icon(
                Icons.description,
                size: 20,
              ),
              child: Text(
                'Jira',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.map,
                size: 20,
              ),
              child: Text(
                '부동산',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
