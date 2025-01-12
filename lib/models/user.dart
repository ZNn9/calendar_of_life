import 'package:calendar_of_life/controllers/calendar_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class User {
  User({
    required this.id,
    required this.name,
    this.age,
    this.ageStop,
    required this.birthDate,
  });

  final int? id;
  final String? name;
  int? age;
  final int? ageStop;
  final String? birthDate;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"],
      age: json["age"],
      ageStop: json["ageStop"],
      birthDate: json["birthDate"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "age": age,
        "ageStop": ageStop,
        "birthDate": birthDate,
      };
}

class UserInfoController extends GetxController {
  // Lưu trữ một đối tượng User
  final user = User(
    id: null,
    name: "",
    age: null,
    birthDate: "",
  ).obs;

  // Tham chiếu đến CalendarController
  final CalendarController calendarController = Get.find();

  // Cập nhật thông tin người dùng
  void updateUserInfo({
    required int id,
    required String name,
    required String birthDate,
  }) {
    user.value = User(
      id: id,
      name: name,
      birthDate: birthDate,
    );

    // Cập nhật ngày sinh vào CalendarController và tính tuổi
    DateTime parsedBirthDate = DateFormat("yyyy-MM-dd")
        .parse(birthDate); // Giả sử định dạng ngày tháng là yyyy-MM-dd
    calendarController.setBirthDate(parsedBirthDate);

    var currentage = calendarController.updateCurrentAge();
    user.value.age = currentage;
  }

  // Lấy dữ liệu dạng JSON
  Map<String, dynamic> get userJson => user.value.toJson();

  // Cập nhật từ JSON
  void updateFromJson(Map<String, dynamic> json) {
    user.value = User.fromJson(json);
  }
}
