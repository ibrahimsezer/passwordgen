import 'package:flutter/material.dart';
import 'alert_dialog.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.small(
          backgroundColor: Colors.grey,
          child: const Icon(Icons.add,
            size: 36,),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => PopupDialog(context));
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      ),
    );
  }
}
