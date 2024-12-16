import 'package:flutter/material.dart';

class InventoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.inventory),
            title: Text('Item 1'),
            subtitle: Text('Description of Item 1'),
          ),
          ListTile(
            leading: Icon(Icons.inventory),
            title: Text('Item 2'),
            subtitle: Text('Description of Item 2'),
          ),
          ListTile(
            leading: Icon(Icons.inventory),
            title: Text('Item 3'),
            subtitle: Text('Description of Item 3'),
          ),
        ],
      ),
    );
  }
}
