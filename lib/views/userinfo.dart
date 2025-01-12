import 'package:calendar_of_life/models/user.dart';
import 'package:calendar_of_life/views/update_user_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserInfoScreen extends StatelessWidget {
  final UserInfoController userInfoController = Get.put(UserInfoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${userInfoController.user.value.name}",
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              Text("Age: ${userInfoController.user.value.age}",
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              Text("Birth Date: ${userInfoController.user.value.birthDate}",
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => UpdateUserInfoScreen());
                },
                child: Text("Update Information"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
