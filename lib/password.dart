import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class Password extends ChangeNotifier {
  String _value = "";

  String get value => _value;

  void hive(String text) async {
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
}
