import 'package:flutter/material.dart';
import 'package:flutter_application_2/master_key_page.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'helper/random_password.dart';

Widget PopupDialog(BuildContext context) {
  AlertDialog popUpDialog() {
    var myController = TextEditingController();
    final bool _obscureText = true;

    final TextEditingController _password = TextEditingController();
    final TextEditingController _url = TextEditingController();
    final TextEditingController _name = TextEditingController();
    TextEditingController password = _password;
    TextEditingController url = _url;
    TextEditingController name = _name;

    List<Map<String, dynamic>> _items = [];
    final _dataBox = Hive.box("data_box");

    // Get all items from the database

    void _refreshItems() {
      final data = _dataBox.keys.map((key) {
        final value = _dataBox.get(key);
        return {
          "key": key,
          "name": value["name".toLowerCase()],
          "quantity": value['quantity']
        };
      }).toList();
      // we use "reversed" to sort items in order from the latest to the oldest
      _items = data.reversed.toList();
    }

    // Load data when app starts

    //Create new item1
    Future<void> _createItem(Map<String, dynamic> newItem) async {
      await _dataBox.add(newItem);
      _refreshItems();
    }

    //Update a single item
    Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
      await _dataBox.put(itemKey, item);
      _refreshItems(); //Update the UI
    }

    //Deleta a single item
    Future<void> _deleteItem(BuildContext context, int itemKey) async {
      await _dataBox.delete(itemKey);
      _refreshItems();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An item has been deleted.")));
    }

    void _showForm(BuildContext ctx, int? itemKey) async {
      if (itemKey != null) {
        final existingItem =
            _items.firstWhere((element) => element['key'] == itemKey);
        name = existingItem['name'];
        url = existingItem['quantity'];
      }
    }

    void passwordCreate(BuildContext context, itemKey) {
      bool control() {
        final data = _dataBox.keys.map((key) {
          final value = _dataBox.get(key);
          return {
            "key": key,
            "name": value["name".toLowerCase()],
            "quantity": value['quantity']
          };
        }).toList();
        for (var element in data) {
          if (element['name'] == name.text.toLowerCase()) {
            return false;
          }
        }
        return name.text.isNotEmpty;
      }

      // Save new item
      if (itemKey == null && control()) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ALERT!!!!!!!!'),
            content: const Text('Wrong Name'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ); //yeni item
        _createItem({"name": name.text, "quantity": url.text});
      } else {}
      // update an existing item
      if (itemKey != null) {
        _updateItem(
            itemKey, {'name': name.text.trim(), 'quantity': url.text.trim()});
      }

      // Clear the text fields
      name.text = '';
      url.text = '';

      Navigator.of(context).pop(); // Close the bottom sheet
    }

    return AlertDialog(
      title: Center(
        child: Container(
          width: 325,
          height: 350,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 30),
                child: Text(
                  "Create Password",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              TextFormField(
                readOnly: true,
                controller: _password,
                decoration: InputDecoration(
                    hintText: "Password create",
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          splashRadius: 20,
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            final password = generatePassword();

                            _password.text = password!;
                          },
                        ),
                        IconButton(
                          splashRadius: 20,
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            context
                                .read<MasterKeyPage>()
                                .copyPassword(context, _password.text);
                          },
                        ),
                      ],
                    )),
              ),
              TextFormField(
                  controller: _url,
                  decoration: const InputDecoration(
                    hintText: "Enter url",
                  )),
              TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    hintText: "Enter name",
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          passwordCreate(context, _items);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: const Icon(Icons.add)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  return popUpDialog();
}
