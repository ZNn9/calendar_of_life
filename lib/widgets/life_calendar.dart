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
      future: _calculateLifeCalendar(ageStop, currentAge),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoadingIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return _buildLifeGrid(snapshot.data!);
        } else {
          return const Center(child: Text('Không có dữ liệu'));
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

  Future<List<List<int>>> _calculateLifeCalendar(
      int ageStop, int currentAge) async {
    // await Future.delayed(const Duration(milliseconds: 100));
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

    return lifeCalendar;
  }

  int _calculateCurrentWeek(DateTime date) {
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

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}
