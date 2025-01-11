import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_info_provider.dart';

class UpdateUserInfoScreen extends StatefulWidget {
  @override
  _UpdateUserInfoScreenState createState() => _UpdateUserInfoScreenState();
}

class _UpdateUserInfoScreenState extends State<UpdateUserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _address = '';
  String _birthDate = ''; // Thêm trường ngày sinh

  @override
  void initState() {
    super.initState();
    final userInfo = Provider.of<UserInfoProvider>(context, listen: false);
    _name = userInfo.name;
    _phone = userInfo.phone;
    _address = userInfo.address;
    _birthDate = userInfo.birthDate; // Lấy ngày sinh từ Provider
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
              TextFormField(
                initialValue: _phone,
                decoration: InputDecoration(labelText: 'Phone'),
                onSaved: (value) => _phone = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _address,
                decoration: InputDecoration(labelText: 'Address'),
                onSaved: (value) => _address = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
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
                    Provider.of<UserInfoProvider>(context, listen: false)
                        .updateUserInfo(
                            name: _name,
                            phone: _phone,
                            address: _address,
                            birthDate:
                                _birthDate); // Cập nhật thông tin bao gồm ngày sinh

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Information Updated')),
                    );
                    Navigator.pop(context);
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
