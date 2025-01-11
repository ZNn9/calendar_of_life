import 'package:calendar_of_life/screens/calendar_of_your_life_screen.dart';
import 'package:calendar_of_life/screens/google_calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainBottomNavigationBar extends StatelessWidget {
  MainBottomNavigationBar({super.key});

  final MainScreenController controller = Get.put(MainScreenController());

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  // Define your actual widgets here
  static const List<Widget> _widgetOptions = <Widget>[
    GoogleCalendarScreen(),
    CalendarOfYourLifeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _widgetOptions,
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.calendar_month, color: Colors.blue),
              label: 'Calendar',
              backgroundColor: Colors.white,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.calendar_today, color: Colors.blue),
              label: 'Life Calendar',
              backgroundColor: Colors.white,
            ),
          ],
          currentIndex: controller.selectedIndex.value,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          onTap: controller.onItemTapped,
        ),
      ),
    );
  }
}

// Create a GetX Controller to manage the state
class MainScreenController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final PageController pageController = PageController(initialPage: 0);

  void onItemTapped(int index) {
    selectedIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
