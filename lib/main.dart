import 'package:flutter/material.dart';
import 're_arrange_index_listview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReOrderListView()
      // ListViewAnimation(),
    );
  }
}