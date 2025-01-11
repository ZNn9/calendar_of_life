import 'package:flutter/material.dart';
import 'package:calendar_of_life/controllers/calendar_controller.dart';
import 'package:get/get.dart';

class LifeCalendar extends StatelessWidget {
  final CalendarController calendarController =
      Get.find<CalendarController>(); // Tìm CalendarController qua GetXs

  final double maxWidth;

  LifeCalendar({
    Key? key,
    required this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var ageStop = calendarController.ageStop.value;

    return FutureBuilder<List<List<int>>>(
      // Sử dụng FutureBuilder để lấy dữ liệu tính toán
      future: calendarController
          .calculateLifeCalendarAsync(), // Tính toán lifeCalendar
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // Hiển thị trạng thái đang tải
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Lỗi: ${snapshot.error}')); // Hiển thị lỗi nếu có
        } else if (snapshot.hasData) {
          return buildLifeGrid(
              snapshot.data!, ageStop, calendarController); // Hiển thị GridView
        } else {
          return const Center(
              child: Text('Không có dữ liệu')); // Trường hợp không có dữ liệu
        }
      },
    );
  }

  // Hàm này xây dựng giao diện Grid cho lịch sống
  Widget buildLifeGrid(
      List<List<int>> lifeCalendar, var ageStop, var calendarController) {
    double circleSize = maxWidth / 54;
    if (circleSize > 20) circleSize = 20;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 52, // 52 tuần trong một năm
        childAspectRatio: 1,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: ageStop * 52, // Tổng số ô (tuần của tất cả các năm)
      itemBuilder: (context, index) {
        int x = index ~/ 52; // Tính số năm
        int y = index % 52; // Tính số tuần trong năm

        return Tooltip(
          message:
              'Năm: ${x}, Tuần: ${y + 1}', // Hiển thị thông tin về năm và tuần
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: calendarController.getColorForNode(lifeCalendar[x]
                  [y]), // Sử dụng phương thức để lấy màu sắc cho tuần
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
        );
      },
    );
  }
}
