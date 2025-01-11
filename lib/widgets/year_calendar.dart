import 'dart:async';
import 'dart:developer' as developer;
import 'package:calendar_of_life/controllers/calendar_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class YearCalendar extends StatelessWidget {
  var calendarController = Get.find<CalendarController>();
  var screenWidth;
  final double maxWidth;

  YearCalendar({
    Key? key,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<List<List<int>>>(
      future: calendarController.calculateYearCalendarAsync(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                  height: screenHeight * 0.7, // Use 70% of screen height
                  child: _buildYearGrid(snapshot.data!),
                ),
              ],
            ),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: screenWidth ~/ 60,
        childAspectRatio: 1,
        mainAxisSpacing: 8,
        crossAxisSpacing: 25,
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
              color:
                  calendarController.getColorForNode(yearCalendar[month][node]),
              border: Border.all(color: seasonColors[seasonIndex], width: 2),
              boxShadow: yearCalendar[month][node] == 2
                  ? [
                      BoxShadow(
                        color: Colors.greenAccent,
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
}
