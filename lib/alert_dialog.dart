import 'package:flutter/material.dart';
import 'package:flutter_application_2/master_key_page.dart';
import 'package:provider/provider.dart';

import 'helper/random_password.dart';

Widget PopupDialog(BuildContext context) {
  AlertDialog popUpDialog() {
    final TextEditingController _password = TextEditingController();
    final TextEditingController _url = TextEditingController();
    final TextEditingController _name = TextEditingController();
    TextEditingController password = _password;
    var myController = TextEditingController();
    final bool _obscureText = true;

    return AlertDialog(
      title: Center(
        child: Container(
          width: 325,
          height: 350,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(5)),
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
                        onPressed: () {},
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
