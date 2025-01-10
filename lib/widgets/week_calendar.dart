import 'dart:developer' as developer;
import 'package:flutter/material.dart';

class WeekCalendar extends StatelessWidget {
  final DateTime weekStartDate; // Ngày bắt đầu của tuần
  final double maxWidth;

  const WeekCalendar({
    Key? key,
    required this.weekStartDate,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DateTime> week = _generateWeek(weekStartDate);

    double circleSize = maxWidth / 9; // Cân chỉnh kích thước các node
    if (circleSize > 40) circleSize = 40; // Giới hạn kích thước node

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Hiển thị tuần và năm
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Week ${getWeekOfYear(weekStartDate)} - ${weekStartDate.month}/${weekStartDate.year}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 5, 121, 255),
            ),
          ),
        ),
        // Hiển thị các node cho 7 ngày trong tuần
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: week.map((day) {
            return Flexible(
              flex: 1,
              child: _buildDayNode(day, circleSize),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Tính tuần trong năm (tuần thứ mấy)
  int getWeekOfYear(DateTime date) {
    DateTime firstDayOfYear = DateTime(date.year, 1, 1);
    int firstDayOfYearWeekday = firstDayOfYear.weekday;
    int daysSinceStartOfYear = date.difference(firstDayOfYear).inDays;
    int weekOfYear =
        ((daysSinceStartOfYear + firstDayOfYearWeekday - 1) / 7).floor() + 1;
    return weekOfYear;
  }

  // Tạo danh sách các ngày trong tuần từ ngày bắt đầu
  List<DateTime> _generateWeek(DateTime startDate) {
    developer.log('Generating week starting from: ${startDate}',
        name: 'WeekCalendar');

    List<DateTime> week = [];
    for (int i = 0; i < 7; i++) {
      week.add(startDate.add(Duration(days: i))); // Thêm từng ngày trong tuần
    }

    return week;
  }

  // Tạo node cho từng ngày trong tuần
  Widget _buildDayNode(DateTime day, double size) {
    int status = _getDayStatus(
        day); // Tính trạng thái ngày (quá khứ, hiện tại, tương lai)

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(4.0), // Khoảng cách giữa các node
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Hình tròn cho các node
        color: _getColorForNode(status), // Màu sắc tùy thuộc vào trạng thái
        boxShadow: status == 2
            ? [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            : [],
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

  // Xác định trạng thái của ngày (quá khứ, hiện tại, tương lai)
  int _getDayStatus(DateTime day) {
    DateTime today = DateTime.now();
    DateTime currentDayOnly = DateTime(today.year, today.month, today.day);

    developer.log('Checking day: $day, today: $today', name: 'WeekCalendar');

    if (day.isBefore(currentDayOnly)) {
      return 1; // Quá khứ
    } else if (day.isAtSameMomentAs(currentDayOnly)) {
      return 2; // Hiện tại
    } else {
      return 0; // Tương lai
    }
  }

  // Xác định màu sắc cho node dựa trên trạng thái
  Color _getColorForNode(int status) {
    switch (status) {
      case 1:
        return Colors.blue[300]!; // Quá khứ
      case 2:
        return Colors.green[400]!; // Hiện tại
      default:
        return Colors.grey[200]!; // Tương lai
    }
  }
}
