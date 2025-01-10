import 'dart:developer' as developer;
import 'package:flutter/material.dart';

class MonthCalendar extends StatelessWidget {
  final DateTime month; // The first day of the month to display
  final double maxWidth;

  const MonthCalendar({
    Key? key,
    required this.month,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<List<DateTime?>> weeks = _generateMonthWeeks(month);

    double circleSize = maxWidth / 9; // Calculate node size
    if (circleSize > 50) circleSize = 50; // Limit maximum size

    return Column(
      children: [
        // Display Month and Year title in numerical format (e.g., "01/2025")
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "${month.month.toString().padLeft(2, '0')}/${month.year}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        // Display weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildWeekdayHeaders(circleSize),
        ),
        // Display weeks of the month
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

  // Determine the status of the day (past, present, future)
  int _getDayStatus(DateTime day) {
    DateTime today = DateTime.now();
    DateTime currentDayOnly = DateTime(
        today.year, today.month, today.day); // Chỉ lấy ngày, tháng và năm

    if (day.isBefore(currentDayOnly)) {
      return 1; // Past
    } else if (day.isAtSameMomentAs(currentDayOnly)) {
      return 2; // Present
    } else {
      return 0; // Future
    }
  }

  // Get the color for the node based on the status
  Color _getColorForNode(int status) {
    switch (status) {
      case 1:
        return Colors.blue[300]!; // Past
      case 2:
        return Colors.green[400]!; // Present
      default:
        return Colors.grey[200]!; // Future
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
      margin: const EdgeInsets.all(4.0), // Spacing between nodes
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Circular shape
        color: _getColorForNode(status), // Apply color based on status
        border: Border.all(
          color: Colors.black, // Apply border for all nodes
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
    developer.log('Generating weeks for month: ${month.month}',
        name: 'MonthCalendar');

    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    int daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Calculate the first Monday of the month
    int weekdayOfFirstDay = firstDayOfMonth.weekday;
    int daysToSubtract = (weekdayOfFirstDay == 7) ? 6 : weekdayOfFirstDay - 1;
    DateTime firstMondayOfMonth =
        firstDayOfMonth.subtract(Duration(days: daysToSubtract));

    List<List<DateTime?>> weeks = [];
    List<DateTime?> currentWeek = [];

    // Calculate empty nodes before the first Monday of the month if necessary
    for (int i = 0; i < daysToSubtract; i++) {
      currentWeek.add(null); // Add empty nodes for days before the first Monday
    }

    // Generate the days of the month
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime currentDay = DateTime(month.year, month.month, i);
      currentWeek.add(currentDay);

      if (currentWeek.length == 7) {
        weeks.add(List.from(currentWeek)); // Add the week to the weeks list
        currentWeek.clear(); // Reset the current week
      }
    }

    // Fill the remaining empty days in the last week
    while (currentWeek.length < 7) {
      currentWeek
          .add(null); // Fill with null for days after the last day of the month
    }
    if (currentWeek.isNotEmpty) weeks.add(currentWeek); // Add the final week

    developer.log('Completed generating weeks for month: ${month.month}',
        name: 'MonthCalendar');
    return weeks;
  }

  // Create weekday headers (Mon -> Sun)
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
              border: Border.all(
                  color: Colors.black, width: 1), // Add border for headers
            ),
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
