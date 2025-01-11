import 'package:calendar_of_life/views/update_user_info.dart';
import 'package:calendar_of_life/views/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserInfoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('User Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${userInfo.name}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Phone: ${userInfo.phone}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Address: ${userInfo.address}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Birth Date: ${userInfo.birthDate}", style: TextStyle(fontSize: 20)),  // Hiển thị ngày sinh
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateUserInfoScreen()),
                );
              },
              child: Text("Update Information"),
            ),
          ],
        ),
      ),
    );
  }
}
