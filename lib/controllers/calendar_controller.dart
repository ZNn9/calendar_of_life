import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class CalendarController extends GetxController {
  Rx<DateTime?> birthDate = Rx<DateTime?>(null);
  var optionTrue = "life".obs;
  var isLoading = false.obs; // Thêm biến loading, chưa thành công
  var ageStop = 50.obs;
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
    // Test
    // String dateString = "2002,01,02";
    // DateTime parsedDate = DateFormat("yyyy,MM,dd").parse(dateString);
    // birthDate.value = parsedDate;

    updateCurrentAge();
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

  void updateCurrentAge() {
    if (birthDate.value != null) {
      DateTime timeTamp = DateTime.now();

      // Tính tuổi chính xác
      int age = timeTamp.year - birthDate.value!.year;

      // Nếu sinh nhật trong năm chưa qua, trừ 1 tuổi
      if (timeTamp.month >= birthDate.value!.month) {
        if ((timeTamp.month == birthDate.value!.month &&
            timeTamp.day >= birthDate.value!.day)) {
          currentAge.value = age;
          return;
        }
        age--;
      }
      currentAge.value = age;
    }
  }

  // Life Calendar
  Future<List<List<int>>> calculateLifeCalendarAsync() async {
    return compute(_generateLifeCalendarInIsolate, {
      'ageStop': ageStop.value,
      'currentAge': currentAge.value,
      'birthDate': birthDate.value,
      'now': DateTime.now(),
    });
  }

  static List<List<int>> _generateLifeCalendarInIsolate(
      Map<String, dynamic> params) {
    int ageStopValue = params['ageStop'] as int;
    int currentAgeValue = params['currentAge'] as int;
    DateTime birthDateValue = params['birthDate'] as DateTime;
    DateTime now = params['now'] as DateTime;

    int currentWeek = _calculateCurrentWeek(now, birthDateValue);

    List<List<int>> lifeCalendar =
        List.generate(ageStopValue, (x) => List.generate(52, (y) => 0));

    int weekNow = 0;
    for (int x = 0; x < ageStopValue; x++) {
      for (int y = 0; y < 52; y++) {
        weekNow++;

        if (x < currentAgeValue ||
            (x == currentAgeValue && weekNow <= currentWeek)) {
          lifeCalendar[x][y] = 1;
        }
        if (x == currentAgeValue && weekNow == currentWeek) {
          lifeCalendar[x][y] = 2;
        }
      }
    }

    return lifeCalendar;
  }

  static int _calculateCurrentWeek(DateTime date, DateTime birthDate) {
    int daysLived = date.difference(birthDate).inDays;
    return (daysLived / 7).floor();
  }
  // Calendar Man

  // Year Calendar
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
