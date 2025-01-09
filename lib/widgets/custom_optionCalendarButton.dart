import 'package:calendar_of_life/controllers/calendar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomOptionCalendarButton extends GetView<CalendarController> {
  final String option;

  const CustomOptionCalendarButton({Key? key, required this.option})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isSelected = controller.optionCalendar[option] ?? false;

      return Expanded(
        child: ElevatedButton(
          onPressed: () {
            controller.changeOption(option);
          },
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(vertical: 20), // Chỉ padding dọc
            backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
            foregroundColor: isSelected ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            option.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    });
  }
}
