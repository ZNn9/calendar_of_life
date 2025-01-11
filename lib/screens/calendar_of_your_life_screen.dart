import 'package:calendar_of_life/controllers/calendar_controller.dart';
import 'package:calendar_of_life/widgets/life_calendar.dart'; // Make sure this is implemented
import 'package:calendar_of_life/widgets/month_calendar.dart';
import 'package:calendar_of_life/widgets/option_calendar.dart';
import 'package:calendar_of_life/widgets/week_calendar.dart';
import 'package:calendar_of_life/widgets/year_calendar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum CalendarView { life, year, month, week, day }

class CalendarOfYourLifeScreen extends StatelessWidget {
  const CalendarOfYourLifeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController calendarController = Get.put(CalendarController());

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Calendar Of Life')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: <Widget>[
                  OptionCalendar(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Obx(() {
                      if (calendarController.currentAge.value == 0) {
                        return const Center(
                            child: Text("Please select a birthdate"));
                      }

                      final currentView = calendarController.optionTrue.value;

                      switch (currentView) {
                        case 'life':
                          return LifeCalendar(
                            maxWidth: constraints.maxWidth,
                          );
                        case 'year':
                          return YearCalendar(
                            maxWidth: constraints.maxWidth,
                          );
                        case 'month':
                          return MonthCalendar(
                            maxWidth: MediaQuery.of(context).size.width,
                          ); // Implement this
                        case 'week':
                        // return WeekCalendar(
                        //   weekStartDate: DateTime.now(),
                        //   maxWidth: MediaQuery.of(context).size.width,
                        // );
                        case 'day':
                        // return const DayCalendar(); // Implement this
                        default:
                          return const Center(
                              child: Text("Please select a view mode"));
                      }
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
