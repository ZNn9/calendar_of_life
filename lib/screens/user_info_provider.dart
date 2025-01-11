import 'package:flutter/material.dart';

class UserInfoProvider with ChangeNotifier {
  String _name = "";
  String _phone = "";
  String _address = "";
  String _birthDate = "";  // Thêm trường ngày tháng năm sinh

  String get name => _name;
  String get phone => _phone;
  String get address => _address;
  String get birthDate => _birthDate;  // Thêm getter cho ngày sinh

  void updateUserInfo({
    required String name,
    required String phone,
    required String address,
    required String birthDate,  // Thêm tham số ngày sinh
  }) {
    _name = name;
    _phone = phone;
    _address = address;
    _birthDate = birthDate;  // Cập nhật ngày sinh
    notifyListeners();
  }
}
