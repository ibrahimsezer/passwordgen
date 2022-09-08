import 'package:flutter/material.dart';
import 'package:flutter_application_2/master_key_page.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'helper/random_password.dart';

Widget PopupDialog(BuildContext context) {
  AlertDialog popUpDialog() {
    var myController = TextEditingController();

    final TextEditingController password = TextEditingController();
    final TextEditingController url = TextEditingController();
    final TextEditingController name = TextEditingController();

    List<Map<String, dynamic>> items = [];
    //final dataBox = Hive.box("data_box");

    // Get all items from the database

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
                controller: password,
                decoration: InputDecoration(
                    hintText: "Password create",
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          splashRadius: 20,
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            var passwordd = generatePassword();

                            password.text = passwordd!;
                          },
                        ),
                        IconButton(
                          splashRadius: 20,
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            context
                                .read<MasterKeyPage>()
                                .copyPassword(context, password.text);
                          },
                        ),
                      ],
                    )),
              ),
              TextFormField(
                  controller: url,
                  decoration: const InputDecoration(
                    hintText: "Enter url",
                  )),
              TextFormField(
                  controller: name,
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
                          //passwordCreate(context, _items);
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
