import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('채팅이요')),
        body: Center(child: Text('채팅화면')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // 버튼 클릭 시 동작
          },
          child: Icon(Icons.add),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(child: Text('Drawer Header')),
              ListTile(title: Text('메뉴1'), onTap: () {}),
              ListTile(title: Text('메뉴2'), onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
