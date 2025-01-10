import 'package:calendar_of_life/widgets/custom_option_calendar_button.dart';
import 'package:flutter/material.dart';

// Giả sử đây là widget OptionCalendar của bạn
class OptionCalendar extends StatelessWidget {
  const OptionCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // CustomOptionCalendarButton(option: 'day'),
              // CustomOptionCalendarButton(option: 'week'),
              CustomOptionCalendarButton(option: 'month'),
              CustomOptionCalendarButton(option: 'year'),
              CustomOptionCalendarButton(option: 'life'),
            ],
          ),
        ),
      ],
    );
  }
}
