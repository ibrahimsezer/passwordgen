import 'dart:math';

String? generatePassword({
  bool hasLetters = true,
  bool hasNumbers = true,
  bool hasSpecial = true,
}) {
  const length = 20;
  const lettersLowercase = 'abcdefghijklmnoprstuvyzw';
  const lettersUppercase = 'ABCDEFGHİJKLMNOPRSTUVYZW';
  const numbrs = '0123456789';
  const special = '@#=+!&\$%?(){}€';

  String chars = '';
  if (hasLetters) {
    chars += '$lettersLowercase$lettersUppercase';
  }
  if (hasNumbers) chars += numbrs;
  if (hasSpecial) chars += special;

  return List.generate(length, (index) {
    final indexRandom = Random.secure().nextInt(chars.length);

    return chars[indexRandom];
  }).join('');
}
