import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class YearCalendar extends StatelessWidget {
  final double maxWidth;

  const YearCalendar({
    Key? key,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<int>>>(
      future: compute(_calculateYearCalendar, DateTime.now()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Hiển thị trạng thái đang tải
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Lỗi: ${snapshot.error}')); // Hiển thị lỗi nếu có
        } else if (snapshot.hasData) {
          return _buildYearGrid(snapshot.data!); // Hiển thị GridView
        } else {
          return const Center(
              child: Text('Không có dữ liệu')); // Trường hợp không có dữ liệu
        }
      },
    );
  }

  Widget _buildYearGrid(List<List<int>> yearCalendar) {
    double circleSize =
        maxWidth / 9; // Điều chỉnh kích thước nhỏ hơn để tránh tràn
    if (circleSize > 40) circleSize = 40; // Giới hạn tối đa kích thước

    List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    List<String> seasons = ["Spring", "Summer", "Autumn", "Winter"];
    List<Color> seasonColors = [
      Colors.green[200]!, // Xuân
      Colors.yellow[200]!, // Hạ
      Colors.orange[200]!, // Thu
      Colors.blue[200]!, // Đông
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(30.0),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // 6 cột (6 phần của mỗi tháng)
        childAspectRatio: 1,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 12 * 6, // 12 tháng x 6 phần
      itemBuilder: (context, index) {
        int month = index ~/ 6; // Xác định tháng (0-11)
        int node = index % 6; // Xác định phần của tháng (0-5)
        int seasonIndex = month ~/ 3; // Xác định mùa (0-3)
        String season = seasons[seasonIndex];

        return Tooltip(
          message:
              'Tháng: ${months[month]}\nMùa: $season\nPhần: ${node + 1} / 6',
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getColorForNode(yearCalendar[month][node]),
              border: Border.all(
                  color: seasonColors[seasonIndex],
                  width: 2), // Màu viền theo mùa
              boxShadow: yearCalendar[month][node] == 2
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
            // Không hiển thị tên tháng nữa
            child: null,
          ),
        );
      },
    );
  }

  static Future<List<List<int>>> _calculateYearCalendar(DateTime now) async {
    developer.log('Bắt đầu xây dựng GridView Year Calendar',
        name: 'YearCalendar');

    // Tạo mảng 12x6 (12 tháng x 6 phần)
    List<List<int>> yearCalendar = List.generate(
      12, // 12 tháng
      (month) => List.generate(6, (node) => 0), // 6 phần mỗi tháng
    );

    int currentMonth = now.month - 1; // Chỉ số tháng hiện tại (0-11)
    int currentNode =
        ((now.day - 1) / (getDaysInMonth(now.year, now.month) / 6))
            .floor(); // Phần hiện tại của tháng (0-5)

    for (int month = 0; month < 12; month++) {
      for (int node = 0; node < 6; node++) {
        if (month < currentMonth ||
            (month == currentMonth && node < currentNode)) {
          yearCalendar[month][node] = 1; // Quá khứ
        }
        if (month == currentMonth && node == currentNode) {
          yearCalendar[month][node] = 2; // Phần hiện tại
        }
      }
    }

    developer.log('Kết thúc xây dựng GridView Year Calendar',
        name: 'YearCalendar');
    return yearCalendar;
  }

  // Helper method to calculate the number of days in a month
  static int getDaysInMonth(int year, int month) {
    // Use the next month and subtract 1 day to find the last day of the current month
    DateTime firstDayNextMonth = DateTime(year, month + 1, 1);
    DateTime lastDayThisMonth = firstDayNextMonth.subtract(Duration(days: 1));
    return lastDayThisMonth.day;
  }

  Color _getColorForNode(int status) {
    switch (status) {
      case 1:
        return Colors.blue[300]!; // Quá khứ
      case 2:
        return Colors.green[400]!; // Phần hiện tại
      default:
        return Colors.grey[200]!; // Tương lai
    }
  }
}
