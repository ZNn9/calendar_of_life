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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Text(
                  '${DateTime.now().year}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              SizedBox(
                width: maxWidth,
                height: 600,
                child: _buildYearGrid(snapshot.data!),
              ),
            ],
          );
        } else {
          return const Center(child: Text('Không có dữ liệu'));
        }
      },
    );
  }

  Widget _buildYearGrid(List<List<int>> yearCalendar) {
    double circleSize = maxWidth / 9;
    if (circleSize > 40) circleSize = 40;

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
      Colors.green[200]!,
      const Color.fromARGB(255, 205, 90, 90)!,
      Colors.orange[200]!,
      Colors.blue[200]!,
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(15.0),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1,
        mainAxisSpacing: 8,
        crossAxisSpacing: 22,
      ),
      itemCount: 12 * 6,
      itemBuilder: (context, index) {
        int month = index ~/ 6;
        int node = index % 6;
        int seasonIndex = month ~/ 3;
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
              border: Border.all(color: seasonColors[seasonIndex], width: 2),
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
            child: null,
          ),
        );
      },
    );
  }

  static Future<List<List<int>>> _calculateYearCalendar(DateTime now) async {
    developer.log('Bắt đầu xây dựng GridView Year Calendar',
        name: 'YearCalendar');

    List<List<int>> yearCalendar = List.generate(
      12, // 12 tháng
      (month) => List.generate(6, (node) => 0),
    );

    int currentMonth = now.month - 1;
    int currentNode =
        ((now.day - 1) / (getDaysInMonth(now.year, now.month) / 6)).floor();

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

  static int getDaysInMonth(int year, int month) {
    DateTime firstDayNextMonth = DateTime(year, month + 1, 1);
    DateTime lastDayThisMonth = firstDayNextMonth.subtract(Duration(days: 1));
    return lastDayThisMonth.day;
  }

  Color _getColorForNode(int status) {
    switch (status) {
      case 1:
        return Colors.blue[300]!;
      case 2:
        return Colors.green[400]!;
      default:
        return Colors.grey[200]!;
    }
  }
}
