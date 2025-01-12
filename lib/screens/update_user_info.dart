import 'package:calendar_of_life/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class UpdateUserInfoScreen extends StatefulWidget {
  @override
  _UpdateUserInfoScreenState createState() => _UpdateUserInfoScreenState();
}

class _UpdateUserInfoScreenState extends State<UpdateUserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserInfoController userInfoController = Get.find<UserInfoController>();

  late String _name;
  late int _age;
  late int _ageStop;
  late String _birthDate;

  @override
  void initState() {
    super.initState();
    _name = userInfoController.user.value.name ?? "";
    _age = userInfoController.user.value.age ?? 0;
    _ageStop = userInfoController.user.value.ageStop ?? 0;
    _birthDate = userInfoController.user.value.birthDate ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Information")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Full Name'),
                onSaved: (value) => _name = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _birthDate =
                          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(text: _birthDate),
                    decoration: InputDecoration(
                      labelText: 'Birth Date',
                      hintText: 'Select your birth date',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your birth date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    userInfoController.updateUserInfo(
                      id: userInfoController.user.value.id ?? 0,
                      name: _name,
                      birthDate: _birthDate,
                    );

                    Get.snackbar('Success', 'Information Updated');
                    Get.back();
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
