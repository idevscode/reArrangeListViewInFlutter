import 'dart:async';
import 'package:flutter/material.dart';

class ReOrderListView extends StatefulWidget {
  @override
  _ReOrderListViewState createState() => _ReOrderListViewState();
}

class _ReOrderListViewState extends State<ReOrderListView> {
  List<ItemData> _items;
  StreamController<List<ItemData>> listController =
      StreamController<List<ItemData>>();

  @override
  void initState() {
    super.initState();

    _items = [];
    for (int i = 9; i > 0; --i) {
      String label = "List item $i";
      _items.add(ItemData(label, UniqueKey(), ActionMode.deleteMode,
          color: Colors.deepOrange[100 * i]));
    }
    listController.sink.add(_items);
    didScrollController.sink.add(false);
  }

  void reorderData(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
  }

  Widget textField() {
    return StreamBuilder<bool>(
      stream: didScrollController.stream,
      builder: (context, snapshot) {
        return snapshot.data != null && snapshot.data == true ?
         Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            autocorrect: false,
            decoration: InputDecoration(hintText: 'Add Text'),
            onSubmitted: (text) {
              _items.insert(
                  0,
                  ItemData(text, UniqueKey(), ActionMode.deleteMode,
                      color: Colors.deepOrange[800]));
                  didScrollController.sink.add(false);
              listController.sink.add(_items);
            },
          ),
        ) :  Container();
      }
    );
  }

  Widget dismissibleCard(ItemData data, int pos) {
    return Card(
      key: ValueKey(data.key),
      elevation: 2,
      child: Dismissible(
          key: ValueKey(data.key),
          child: data.mode == ActionMode.deleteMode
              ? ListTile(
                  tileColor: data.color,
                  title: Text(
                    data.title,
                  ),
                )
              : ListTile(
                  tileColor: Colors.white,
                  title: Text(
                    data.title,
                    style: TextStyle(decoration: TextDecoration.lineThrough),
                  ),
                ),
          background: slideRightBackground(),
          secondaryBackground: slideLeftBackground(),
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart) {
              _items.removeAt(pos);
              listController.sink.add(_items);
            } else {
              final item = _items.removeAt(pos);
              _items.insert(_items.length,
                  ItemData(item.title, UniqueKey(), ActionMode.editMode));
              listController.sink.add(_items);
            }
          }),
    );
  }

  
  bool onNotification(ScrollNotification notification) {
    setState(() {
      if (notification.metrics.pixels < -30 && notification.metrics.pixels != 0) {
       didScrollController.sink.add(true);
      }
    });
    return false;
  }



  Widget listView(snapshot) {
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: onNotification,
        child: ReorderableListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, pos) {
            var data = snapshot.data[pos];
            return dismissibleCard(data, pos);
          },
          onReorder: reorderData,
        ),
      ),
    );
  }

  StreamController<bool> didScrollController = StreamController<bool>();


  Widget showTaskList() {
    return StreamBuilder<List<ItemData>>(
        stream: listController.stream,
        builder: (context, snapshot) {
          return snapshot.data != null
              ? Column(
                  children: [
                    textField(),
                    listView(snapshot),
                  ],
                )
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: showTaskList(),
    );
  }


  Widget slideRightBackground() {
    return Container(
      color: Colors.green,
      child: Align(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              " Completed",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget slideLeftBackground() {
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
                child: Text(
                  'x',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                  textAlign: TextAlign.end,
                )),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    listController.close();
    didScrollController.close();
    super.dispose();
  }
}

class ItemData {
  ItemData(this.title, this.key, this.mode, {this.color});

  final String title;
  final Color color;

  // Each item in reorderable list needs stable and unique key
  final UniqueKey key;
  String mode;
}


class ActionMode {
  static String editMode = 'Edit';
  static String deleteMode = 'Delete';
}
