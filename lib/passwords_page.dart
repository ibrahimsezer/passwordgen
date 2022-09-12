import 'package:flutter/material.dart';
import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/master_key_page.dart';
import 'package:flutter_application_2/view_model/pass_button_visibility.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'helper/random_password.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  List<Map<String, dynamic>> _items = [];
  final _dataBox = Hive.box('data_box');

  bool vall = true;

  @override
  void initState() {
    super.initState();
    _refreshItems(); // Load data when app starts
  }

  // Get all items from the database
  void _refreshItems() {
    final data = _dataBox.keys.map((key) {
      final value = _dataBox.get(key);
      return {
        "key": key,
        "name": value["name".toLowerCase()],
        "url": value['url'],
        "password": value['password'],
      };
    }).toList(); //verileri listede gosterme

    setState(() {
      _items = data.reversed
          .toList(); //en sondan en eskiye dogru siralamak icin reversed
      // we use "reversed" to sort items in order from the latest to the oldest
    });
  }

  // Create new item
  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _dataBox.add(newItem); //yeni veri olusturma
    _refreshItems(); // update the UI
  }

  // Update a single item
  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _dataBox.put(itemKey, item); //tablo icerisine veriyi koyma
    _refreshItems(); // Update the UI
  }

// Delete a single item
  Future<void> _deleteItem(int itemKey) async {
    await _dataBox.delete(itemKey);
    _refreshItems(); // update the UI

    // Display a snackbar
    ScaffoldMessenger.of(context)
        .showSnackBar(//ekranin alt kisminda itemin silindigini belirtme
            const SnackBar(content: Text('An item has been deleted')));
  }

  // TextFields' controllers

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController oldPass = TextEditingController();
  final TextEditingController newPass = TextEditingController();


  void _showForm(
    BuildContext ctx,
    int? itemKey,
  ) async {
    //yeni item eklerken ve butona basildiginda tetiklenen flotingbutton
    // itemKey == null -> create new item
    // itemKey != null -> update an existing item

    if (itemKey != null) {
      //itemi guncelleme
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      nameController.text = existingItem['name'];
      urlController.text = existingItem['url'];
      passwordController.text = existingItem['password'];
    }

    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    top: 15,
                    left: 15,
                    right: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Name',
                        suffixIcon: IconButton(
                          splashRadius: 20,
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            context
                                .read<MasterKeyPage>()
                                .copyPassword(context, nameController.text);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: urlController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Url',
                        suffixIcon: IconButton(
                          splashRadius: 20,
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            context
                                .read<MasterKeyPage>()
                                .copyPassword(context, urlController.text);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Consumer<PassButtonVisibility>(builder: (c, obj, w) {
                      return TextField(
                        controller: passwordController,
                        readOnly: true,
                        obscureText: obj.obsecureText,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Create password -->',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    obj.setObsecureText();
                                  },
                                  icon: Icon(obj.obsecureText
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  splashRadius: 20,
                                ),
                                IconButton(
                                  splashRadius: 20,
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () {
                                    var passwordd = generatePassword();

                                    passwordController.text = passwordd!;
                                  },
                                ),
                                IconButton(
                                  splashRadius: 20,
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    context.read<MasterKeyPage>().copyPassword(
                                        context, passwordController.text);
                                  },
                                ),
                              ],
                            )),
                      );
                    }),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        bool control() {
                          final data = _dataBox.keys.map((key) {
                            final value = _dataBox.get(key);
                            return {
                              "key": key,
                              "name": value["name".toLowerCase()],
                              "url": value['url'],
                              "password": value['password'],
                            };
                          }).toList();
                          for (var element in data) {
                            if (element['name'] ==
                                nameController.text.toLowerCase()) {
                              return false;
                            }
                          }
                          return nameController.text.isNotEmpty;
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
                          _createItem({
                            "name": nameController.text,
                            "url": urlController.text,
                            "password": passwordController.text,
                          });
                        } else {}
                        // update an existing item
                        if (itemKey != null) {
                          _updateItem(itemKey, {
                            'name': nameController.text.trim(),
                            'url': urlController.text.trim(),
                            'password': passwordController.text.trim(),
                          });
                        }

                        // Clear the text fields
                        nameController.text = '';
                        urlController.text = '';
                        passwordController.text = '';

                        Navigator.of(context).pop(); // Close the bottom sheet
                      },
                      child: Text(itemKey == null ? 'Create New' : 'Update'),
                    ),
                    const SizedBox(
                      height: 15,
                    )
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FrescoPass'),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('New Password'),
                          actions: [
                            Column(
                              children: [
                                TextFormField(
                                  controller: oldPass,
                                  decoration:
                                      const InputDecoration(hintText: 'xdxd'),
                                ),
                                TextFormField(
                                  controller: newPass,
                                ),
                              ],
                            ),
                            ElevatedButton(onPressed: () async {
                              var temp = await context.read<MasterKeyPage>().passRead();
                              if(oldPass.text == temp){
                                 context.read<MasterKeyPage>().pass(newPass.text);
                                showDialog(context: context, builder: (BuildContext context){
                                  return const AlertDialog(
                                    title: Text('Success'),
                                    content: Text('Password changed succesfully.'),
                                    backgroundColor: Colors.green,

                                  );
                                });
                              }

                            }, child: Icon(Icons.arrow_right_alt))
                          ],
                        );
                      });
                },
                icon: Icon(Icons.key)),
          ],
        ),
        body: _items.isEmpty
            ? const Center(
                child: Text(
                  'No Data',
                  style: TextStyle(fontSize: 30),
                ),
              )
            : ListView.builder(
                // the list of items
                itemCount: _items.length,
                itemBuilder: (_, index) {
                  final currentItem = _items[index];
                  return Card(
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.all(5),
                    elevation: 3,
                    child: ListTile(
                        title: Text(currentItem['url']),
                        subtitle: Text(currentItem['name'].toString()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit button
                            IconButton(
                                icon: const Icon(Icons.edit),
                                splashRadius: 20, //düzenleme butonu
                                onPressed: () =>
                                    _showForm(context, currentItem['key'])),
                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete),
                              splashRadius: 20,
                              onPressed: () => _deleteItem(currentItem['key']),
                            ),
                          ],
                        )),
                  );
                }),
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: Colors.grey,
          child: const Icon(
            Icons.add,
            size: 36,
          ),
          onPressed: () {
            _showForm(context, null);
          },
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniStartFloat,
      ),
    );
  }
}
