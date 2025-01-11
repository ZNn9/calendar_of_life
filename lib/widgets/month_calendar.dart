import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/calendar_controller.dart';

class MonthCalendar extends StatelessWidget {
  var calendarController = Get.find<CalendarController>();
  final double maxWidth;

  MonthCalendar({
    Key? key,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<List<DateTime?>> weeks = _generateMonthWeeks(now);

    double circleSize = maxWidth / 9;
    if (circleSize > 50) circleSize = 50;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "${now.month.toString().padLeft(2, '0')}/${now.year}",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildWeekdayHeaders(circleSize),
          ),
        ),
        Column(
          children: weeks.map((week) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: week.map((day) {
                return _buildDayNode(day, circleSize);
              }).toList(),
            );
          }).toList(),
        ),
      ],
    );
  }

  int _getDayStatus(DateTime day) {
    DateTime today = DateTime.now();
    DateTime currentDayOnly = DateTime(today.year, today.month, today.day);

    if (day.isBefore(currentDayOnly)) {
      return 1; // Past
    } else if (day.isAtSameMomentAs(currentDayOnly)) {
      return 2; // Present
    } else {
      return 0; // Future
    }
  }

  Widget _buildDayNode(DateTime? day, double size) {
    if (day == null) {
      return Container(
        width: size,
        height: size,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
        ),
      );
    }

    int status = _getDayStatus(day);

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: calendarController.getColorForNode(status),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        day.day.toString(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  List<List<DateTime?>> _generateMonthWeeks(DateTime month) {
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    int daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    int weekdayOfFirstDay = firstDayOfMonth.weekday;
    int daysToSubtract = (weekdayOfFirstDay == 7) ? 6 : weekdayOfFirstDay - 1;
    DateTime firstMondayOfMonth =
        firstDayOfMonth.subtract(Duration(days: daysToSubtract));

    List<List<DateTime?>> weeks = [];
    List<DateTime?> currentWeek = [];

    for (int i = 0; i < daysToSubtract; i++) {
      currentWeek.add(null);
    }

    // Generate the days of the month
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime currentDay = DateTime(month.year, month.month, i);
      currentWeek.add(currentDay);

      if (currentWeek.length == 7) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }
    }

    while (currentWeek.length < 7) {
      currentWeek.add(null);
    }
    if (currentWeek.isNotEmpty) weeks.add(currentWeek);
    return weeks;
  }

  List<Widget> _buildWeekdayHeaders(double size) {
    const List<String> weekdays = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun"
    ];

    return weekdays
        .map(
          (day) => Container(
            width: size,
            height: size / 2.5,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1)),
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        )
        .toList();
  }
}
