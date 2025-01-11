import 'package:calendar_of_life/views/update_user_info.dart';
import 'package:calendar_of_life/views/userinfo.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleAPI;
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleCalendarScreen extends StatefulWidget {
  const GoogleCalendarScreen({Key? key}) : super(key: key);

  @override
  State<GoogleCalendarScreen> createState() => _GoogleCalendarScreenState();
}

class _GoogleCalendarScreenState extends State<GoogleCalendarScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '1001415118047-5vac5u8b7vlns8buin6h2cnq7vukdii3.apps.googleusercontent.com',
    scopes: <String>[GoogleAPI.CalendarApi.calendarScope, 'email'],
  );
  final String _phone = ""; // Giá trị mặc định nếu không có
  final String _address = "";
  final String _fullname = "";
  GoogleSignInAccount? _currentUser;
  GoogleAPI.CalendarApi? _calendarApi;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (account != null) {
        _initializeCalendarApi();
      }
    });

    _googleSignIn.signInSilently().then((account) {
      setState(() {
        _currentUser = account;
      });
      if (account != null) {
        _initializeCalendarApi();
      }
    });
  }

  Future<void> _initializeCalendarApi() async {
    final authHeaders = await _currentUser?.authHeaders;
    if (authHeaders != null) {
      final client = GoogleHttpClient(authHeaders);
      setState(() {
        _calendarApi = GoogleAPI.CalendarApi(client);
      });
    }
  }

  Future<List<GoogleAPI.Event>> _fetchEvents() async {
    if (_calendarApi == null) return [];
    try {
      final events = await _calendarApi!.events.list("primary");
      return events.items ?? [];
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  Future<void> _addEvent() async {
    if (_calendarApi == null) return;

    // Open date picker to select the start date
    final DateTime? startDate = await _selectDate();
    if (startDate == null) return;

    // Open time picker to select the start time
    final TimeOfDay? startTime = await _selectTime();
    if (startTime == null) return;

    final DateTime startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );

    // Open date picker to select the end date
    final DateTime? endDate = await _selectDate();
    if (endDate == null) return;

    // Open time picker to select the end time
    final TimeOfDay? endTime = await _selectTime();
    if (endTime == null) return;

    final DateTime endDateTime = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    // Open dialog to enter event description
    final String? eventDescription = await _showEventDescriptionDialog();
    if (eventDescription == null) return;

    try {
      final event = GoogleAPI.Event(
        summary: eventDescription, // Use eventDescription here
        description: eventDescription,
        start: GoogleAPI.EventDateTime(
          dateTime: startDateTime,
          timeZone: "GMT+00:00",
        ),
        end: GoogleAPI.EventDateTime(
          dateTime: endDateTime,
          timeZone: "GMT+00:00",
        ),
      );

      await _calendarApi!.events.insert(event, "primary");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event added successfully!")),
        );
        setState(() {}); // Refresh the UI
      }
    } catch (e) {
      print("Error adding event: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add event.")),
        );
      }
    }
  }

  Future<DateTime?> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return selectedDate;
  }

  Future<TimeOfDay?> _selectTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    return selectedTime;
  }

  Future<String?> _showEventDescriptionDialog() async {
    String description = '';
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter event description'),
            content: TextField(
              onChanged: (value) {
                description = value;
              },
              decoration: const InputDecoration(hintText: 'Event description'),
              style: const TextStyle(fontSize: 14.0),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(description);
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  Future<void> _logout() async {
    await _googleSignIn.signOut();
    setState(() {
      _currentUser = null;
      _calendarApi = null;
    });
  }

  // void _showUserInfo() {
  //   if (_currentUser != null) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Row(
  //             children: [
  //               CircleAvatar(
  //                 backgroundImage: NetworkImage(_currentUser!.photoUrl ??
  //                     'https://via.placeholder.com/150'), // Default placeholder if photoUrl is null
  //                 radius: 20,
  //               ),
  //               const SizedBox(width: 10),
  //               Text(_currentUser!.displayName ?? 'No Name'),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: const Text('Close'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }
  // Future<void> _showUpdateInfoDialog() async {
  //   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  //   String name = _currentUser?.displayName ?? '';
  //   String phone = ''; // You can pre-fill with actual data if available
  //   String address = ''; // Same here
  //   DateTime? dateOfBirth;

  //   await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Update Personal Info"),
  //         content: SingleChildScrollView(
  //           child: Form(
  //             key: formKey,
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextFormField(
  //                   initialValue: name, // Pre-fill name
  //                   decoration: const InputDecoration(labelText: "Full Name"),
  //                   validator: (value) {
  //                     if (value == null || value.isEmpty) {
  //                       return 'Please enter your full name';
  //                     }
  //                     return null;
  //                   },
  //                   onSaved: (value) => name = value ?? '',
  //                 ),
  //                 TextFormField(
  //                   initialValue: phone, // Pre-fill phone number
  //                   decoration:
  //                       const InputDecoration(labelText: "Phone Number"),
  //                   keyboardType: TextInputType.phone,
  //                   validator: (value) {
  //                     if (value == null || value.isEmpty) {
  //                       return 'Please enter your phone number';
  //                     }
  //                     return null;
  //                   },
  //                   onSaved: (value) => phone = value ?? '',
  //                 ),
  //                 TextFormField(
  //                   initialValue: address, // Pre-fill address
  //                   decoration: const InputDecoration(labelText: "Address"),
  //                   validator: (value) {
  //                     if (value == null || value.isEmpty) {
  //                       return 'Please enter your address';
  //                     }
  //                     return null;
  //                   },
  //                   onSaved: (value) => address = value ?? '',
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Row(
  //                   children: [
  //                     const Text("Date of Birth: "),
  //                     TextButton(
  //                       onPressed: () async {
  //                         final DateTime? selectedDate = await showDatePicker(
  //                           context: context,
  //                           initialDate: dateOfBirth ?? DateTime.now(),
  //                           firstDate: DateTime(1900),
  //                           lastDate: DateTime(2100),
  //                         );
  //                         if (selectedDate != null) {
  //                           setState(() {
  //                             dateOfBirth = selectedDate;
  //                           });
  //                         }
  //                       },
  //                       child: Text(dateOfBirth == null
  //                           ? "Select"
  //                           : "${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}"),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               if (formKey.currentState?.validate() ?? false) {
  //                 formKey.currentState?.save();
  //                 // Handle the update (save to your storage or make API call)
  //                 print("Name: $name");
  //                 print("Phone: $phone");
  //                 print("Address: $address");
  //                 print("Date of Birth: $dateOfBirth");
  //                 Navigator.of(context).pop();
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                       content: Text("Information updated successfully!")),
  //                 );
  //               }
  //             },
  //             child: const Text("Save"),
  //           ),
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text("Cancel"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Calendar")),
      body: FutureBuilder<List<GoogleAPI.Event>>(
        future: _fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Failed to load events."));
          }

          return SfCalendar(
            view: CalendarView.month,
            initialDisplayDate: DateTime.now(),
            dataSource: GoogleDataSource(events: snapshot.data!),
            onTap: (details) {
              if (details.appointments != null &&
                  details.appointments!.isNotEmpty) {
                final GoogleAPI.Event event =
                    details.appointments!.first as GoogleAPI.Event;
                _showEventActionsDialog(event);
              }
            },
            monthViewSettings: MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              showAgenda: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            if (_currentUser != null) ...[
              UserAccountsDrawerHeader(
                accountName: Text(_currentUser!.displayName ?? 'No Name'),
                accountEmail: Text(_currentUser!.email ?? 'No Email'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                    _currentUser!.photoUrl ?? 'https://via.placeholder.com/150',
                  ),
                  radius: 30,
                ),
              ),
              ListTile(
                title: Text('View User Info'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserInfoScreen()),
                  );
                },
              ),
              ListTile(
                title: Text('Update User Info'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UpdateUserInfoScreen()),
                  );
                },
              ),
              ListTile(
                title: const Text("Logout"),
                onTap: _logout,
              ),
            ] else ...[
              ListTile(
                title: const Text("Login"),
                onTap: () async {
                  await _googleSignIn.signIn();
                  setState(() {});
                },
              ),
            ]
          ],
        ),
      ),
    );
  }

  void _showEventActionsDialog(GoogleAPI.Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event.summary ?? 'No Title'),
          content: const Text('What would you like to do with this event?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(
                    event.id!); // Show delete confirmation
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateEvent(event.id!);
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateEvent(String eventId) async {
    if (_calendarApi == null) return;

    try {
      final event = await _calendarApi!.events.get("primary", eventId);

      // Get current event data
      DateTime startDateTime =
          event.start?.dateTime?.toLocal() ?? DateTime.now();
      DateTime endDateTime = event.end?.dateTime?.toLocal() ?? DateTime.now();
      String currentDescription = event.description ?? '';

      // Show dialogs to update the event's start and end time
      final DateTime? startDate = await _selectDate();
      if (startDate == null) return;

      final TimeOfDay? startTime = await _selectTime();
      if (startTime == null) return;

      startDateTime = DateTime(startDate.year, startDate.month, startDate.day,
          startTime.hour, startTime.minute);

      final DateTime? endDate = await _selectDate();
      if (endDate == null) return;

      final TimeOfDay? endTime = await _selectTime();
      if (endTime == null) return;

      endDateTime = DateTime(endDate.year, endDate.month, endDate.day,
          endTime.hour, endTime.minute);

      // Allow user to update the event description
      final String? eventDescription = await _showEventDescriptionDialog();
      if (eventDescription == null) return;

      event.summary = event.summary ?? "Updated Event Title";
      event.description = eventDescription;
      event.start = GoogleAPI.EventDateTime(
        dateTime: startDateTime,
        timeZone: "GMT+00:00",
      );
      event.end = GoogleAPI.EventDateTime(
        dateTime: endDateTime,
        timeZone: "GMT+00:00",
      );

      await _calendarApi!.events.update(event, "primary", eventId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event updated successfully!")),
        );
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      print("Error updating event: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update event.")),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(String eventId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event?'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () async {
                await _calendarApi!.events.delete("primary", eventId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event deleted successfully!')),
                );
                setState(() {});
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}

class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({required List<GoogleAPI.Event> events}) {
    appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    final event = appointments![index] as GoogleAPI.Event;
    return event.start?.dateTime?.toLocal() ?? event.start!.date!.toLocal();
  }

  @override
  DateTime getEndTime(int index) {
    final event = appointments![index] as GoogleAPI.Event;
    return event.end?.dateTime?.toLocal() ?? event.end!.date!.toLocal();
  }

  @override
  String getSubject(int index) {
    final event = appointments![index] as GoogleAPI.Event;
    return event.summary ?? 'No Title';
  }

  @override
  Color getColor(int index) {
    final event = appointments![index] as GoogleAPI.Event;
    if (event.summary?.contains('Yoga') == true) {
      return Colors.green;
    } else if (event.summary?.contains('Meeting') == true) {
      return Colors.blue;
    }
    return super.getColor(index);
  }

  @override
  Widget getViewWidget(int index) {
    final event = appointments![index] as GoogleAPI.Event;
    final startTime = event.start?.dateTime?.toLocal() ?? event.start!.date!;
    final endTime = event.end?.dateTime?.toLocal() ?? event.end!.date!;

    return Container(
      padding: const EdgeInsets.all(4),
      color: getColor(index).withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.summary ?? 'No Title',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10.0,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          Text(
            "${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(
              fontSize: 8.0,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
