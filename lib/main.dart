import 'package:calendar_of_life/controllers/calendar_controller.dart';
import 'package:calendar_of_life/firebase_options.dart';
import 'package:calendar_of_life/models/user.dart';
import 'package:calendar_of_life/views/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(CalendarController());
  Get.put(UserInfoController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Google Calendar Integration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // Màn hình login mặc định
    );
  }
}
