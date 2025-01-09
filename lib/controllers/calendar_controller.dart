import 'package:get/get.dart';

class CalendarController extends GetxController {
  Rx<DateTime?> birthDate = Rx<DateTime?>(null);
  var currentAge = 22.obs; //Test
  var optionTrue = "life".obs;
  var isLoading = false.obs; // Thêm biến loading, chưa thành công
  var ageStop = 80.obs;

  var optionCalendar = {
    'day': false,
    'week': false,
    'month': false,
    'year': false,
    'life': true, // 'life' được chọn mặc định
  }.obs;

  @override
  void onInit() {
    super.onInit();
    updateCurrentAge();
  }

  // Sử dụng cho Wiget CustomOptionCalendarButton
  void changeOption(String option) {
    if (optionCalendar.containsKey(option)) {
      optionCalendar.update(option, (val) {
        return !val;
      });
      optionCalendar.update(optionTrue.value, (val) {
        return !val;
      });
      optionTrue.value = option;
    }
  }

  void setBirthDate(DateTime date) {
    birthDate.value = date;
    updateCurrentAge();
  }

  void updateCurrentAge() {
    if (birthDate.value != null) {
      currentAge.value = DateTime.now().year - birthDate.value!.year;
    }
  }
}
