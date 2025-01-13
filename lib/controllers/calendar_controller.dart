import 'package:calendar_of_life/services/api_life_calendar_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class CalendarController extends GetxController {
  final ApiLifeCalendarService apiLifeCalendarService =
      ApiLifeCalendarService();

  Rx<DateTime?> birthDate = Rx<DateTime?>(null);
  var optionTrue = "life".obs;
  var isLoading = false.obs; // Thêm biến loading, chưa thành công
  var ageStop = 100.obs;
  var currentAge = 0.obs; //Test

  var optionCalendar = {
    'day': false,
    'week': false,
    'month': false,
    'year': false,
    'life': true, // 'life' được chọn mặc định
  }.obs;

  @override
  void onInit() {
    super.onInit();
    // updateCurrentAge();
  }

  Color getColorForNode(int status) {
    switch (status) {
      case 1:
        return Colors.blue[300]!; // Màu cho tuần đã sống
      case 2:
        return Colors.green[400]!; // Màu cho tuần hiện tại
      default:
        return Colors.grey[100]!; // Màu cho các tuần chưa sống
    }
  }

  // Sử dụng cho Wiget CustomOptionCalendarButton
  void changeOption(String option) {
    if (optionCalendar.containsKey(option)) {
      optionCalendar.update(option, (val) {
        return !val;
      });
      optionCalendar.update(optionTrue.value, (val) {
        return !val;
      });
      optionTrue.value = option;
    }
  }

  void setBirthDate(DateTime date) {
    birthDate.value = date;
    updateCurrentAge();
  }

  int updateCurrentAge() {
    if (birthDate.value != null) {
      DateTime timeTamp = DateTime.now();

      // Tính tuổi chính xác
      int age = timeTamp.year - birthDate.value!.year;

      // Nếu sinh nhật trong năm chưa qua, trừ 1 tuổi
      if (timeTamp.month < birthDate.value!.month ||
          (timeTamp.month == birthDate.value!.month &&
              timeTamp.day < birthDate.value!.day)) {
        age--;
      }
      currentAge.value = age;
    }
    return currentAge.value; // Trả về giá trị tuổi
  }

  // Life Calendar
  Future<List<List<int>>> calculateLifeCalendarAsync() async {
    try {
      isLoading.value = true;
      return compute(apiLifeCalendarService.generateLifeCalendar, {
        "ageStop": ageStop.value,
        "currentAge": currentAge.value,
        "birthDate": birthDate.value!,
        "now": DateTime.now(),
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to generate life calendar: $e",
          snackPosition: SnackPosition.BOTTOM);
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  // Year Calendar
  // Future<List<List<int>>> calculateYearCalendarAsync() async {
  //   return compute(
  //       apiLifeCalendarService.generateYearCalendar, {"data", false});
  // }

  Future<List<List<int>>> calculateYearCalendarAsync() async {
    return compute(_generateYearCalendarInIsolate, {
      "now": DateTime.now(),
    });
  }

  static List<List<int>> _generateYearCalendarInIsolate(
      Map<String, dynamic> params) {
    DateTime dayNow = params["now"] as DateTime;
    List<List<int>> yearCalendar = List.generate(
      12, // 12 tháng
      (month) => List.generate(6, (node) => 0),
    );

    int currentMonth = dayNow.month - 1;
    int currentNode =
        ((dayNow.day - 1) / (_getDaysInMonth(dayNow.year, dayNow.month) / 6))
            .floor();

    for (int month = 0; month < 12; month++) {
      for (int node = 0; node < 6; node++) {
        if (month < currentMonth ||
            (month == currentMonth && node < currentNode)) {
          yearCalendar[month][node] = 1;
        }
        if (month == currentMonth && node == currentNode) {
          yearCalendar[month][node] = 2;
        }
      }
    }
    return yearCalendar;
  }

  static int _getDaysInMonth(int year, int month) {
    DateTime firstDayNextMonth = DateTime(year, month + 1, 1);
    DateTime lastDayThisMonth = firstDayNextMonth.subtract(Duration(days: 1));
    return lastDayThisMonth.day;
  }

  // Month Calendar
}
