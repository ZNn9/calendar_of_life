import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LifeCalendar extends StatelessWidget {
  final int ageStop;
  final int currentAge;
  final double maxWidth;

  const LifeCalendar({
    Key? key,
    required this.ageStop,
    required this.currentAge,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<int>>>(
      future: compute(_calculateLifeCalendar,
          {'ageStop': ageStop, 'currentAge': currentAge}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Hiển thị trạng thái đang tải
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Lỗi: ${snapshot.error}')); // Hiển thị lỗi nếu có
        } else if (snapshot.hasData) {
          return _buildLifeGrid(snapshot.data!); // Hiển thị GridView
        } else {
          return const Center(
              child: Text('Không có dữ liệu')); // Trường hợp không có dữ liệu
        }
      },
    );
  }

  Widget _buildLifeGrid(List<List<int>> lifeCalendar) {
    double circleSize = maxWidth / 54;
    if (circleSize > 20) circleSize = 20;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 52,
        childAspectRatio: 1,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: ageStop * 52,
      itemBuilder: (context, index) {
        int y = index ~/ 52;
        int x = index % 52;

        return Tooltip(
          message: 'Năm: ${y + 1}, Tuần: ${x + 1}',
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getColorForWeek(lifeCalendar[y][x]),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
        );
      },
    );
  }

  static Future<List<List<int>>> _calculateLifeCalendar(
      Map<String, int> params) async {
    developer.log('Bắt đầu xây dựng Girdview Life Calendar',
        name: 'LifeCalendar');
    int ageStop = params['ageStop']!;
    int currentAge = params['currentAge']!;

    List<List<int>> lifeCalendar =
        List.generate(ageStop, (y) => List.generate(52, (x) => 0));

    int currentWeek = _calculateCurrentWeek(DateTime.now());

    for (int y = 0; y < ageStop; y++) {
      for (int x = 0; x < 52; x++) {
        if (y < currentAge || (y == currentAge && x <= currentWeek)) {
          lifeCalendar[y][x] = 1;
        }
        if (y == currentAge && x == currentWeek) {
          lifeCalendar[y][x] = 2;
        }
      }
    }

    developer.log('Kết thúc xây dựng Girdview Life Calendar',
        name: 'LifeCalendar');
    return lifeCalendar;
  }

  static int _calculateCurrentWeek(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  Color _getColorForWeek(int status) {
    switch (status) {
      case 1:
        return Colors.blue[300]!;
      case 2:
        return Colors.green[400]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
