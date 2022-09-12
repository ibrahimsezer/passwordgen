import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class MasterKeyPage extends ChangeNotifier {
<<<<<<< Updated upstream
  String _value = "";
=======
<<<<<<<< Updated upstream:lib/master_key_page.dart
  String _value = "";
========
  var _value;
>>>>>>>> Stashed changes:lib/view_model/master_key_page.dart
>>>>>>> Stashed changes
  String _copyText = "";

  String get value => _value;
  String get copyText => _copyText;

  // Toggles the password show status
  void copyPassword(BuildContext context, String text) {
    //sifrenin panoya kopyalandigi yer

    final data = ClipboardData(text: text);
    _copyText = data.text ?? "";
    Clipboard.setData(data);
    print("copytext : $_copyText");
    const snackbar = SnackBar(content: Text("Password Copy"));

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackbar);
  }

<<<<<<< Updated upstream
  bool _obsecureText = true;
  void _showHideText() {
    _obsecureText = !_obsecureText;
  }

=======
>>>>>>> Stashed changes
  void pass(String text) async {
    const secureStorage = FlutterSecureStorage();
    final encrypionKey = await secureStorage.read(key: "key");
    if (encrypionKey == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: "key",
        value: base64UrlEncode(key),
      );
    }
    final key = await secureStorage.read(key: "key");
    final encryptionKey = base64Url.decode(key!);
    final encryptedBox = await Hive.openBox("vaultBox",
        encryptionCipher: HiveAesCipher(encryptionKey));
    await encryptedBox.put("Master", text);
    _value = await encryptedBox.get("Master");

    notifyListeners();
  }
<<<<<<< Updated upstream
=======
<<<<<<<< Updated upstream:lib/master_key_page.dart
========

  Future<String?> passRead() async {
    const secureStorage = FlutterSecureStorage();
    final encrypionKey = await secureStorage.read(key: "key");
    if (encrypionKey == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: "key",
        value: base64UrlEncode(key),
      );
    }
    final key = await secureStorage.read(key: "key");
    final encryptionKey = base64Url.decode(key!);
    final encryptedBox = await Hive.openBox("vaultBox",
        encryptionCipher: HiveAesCipher(encryptionKey));
    _value = await encryptedBox.get("Master");
    print(_value);
    notifyListeners();
    if (_value == null) {
      return "";
    }
    return _value;
  }
>>>>>>>> Stashed changes:lib/view_model/master_key_page.dart
>>>>>>> Stashed changes
}
