import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleAPI;
import 'package:http/io_client.dart';
import 'package:http/http.dart' show BaseRequest, Response;
import 'package:syncfusion_flutter_calendar/calendar.dart';

class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({required List<GoogleAPI.Event> events}) {
    appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    final event = appointments![index] as GoogleAPI.Event;
    return event.start?.date ?? event.start!.dateTime!.toLocal();
  }

  @override
  DateTime getEndTime(int index) {
    final event = appointments![index] as GoogleAPI.Event;
    return event.end?.date ?? event.end!.dateTime!.toLocal();
  }

  @override
  String getSubject(int index) {
    return (appointments![index] as GoogleAPI.Event).summary ?? 'No Title';
  }
}

class GoogleAPIClient extends IOClient {
  final Map<String, String> _headers;

  GoogleAPIClient(this._headers);

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url,
          headers: (headers != null ? (headers..addAll(_headers)) : headers));
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Calendar Integration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '1001415118047-l2bqijq6i1h5673e2q3e4kd9c0okk1kt.apps.googleusercontent.com',
    scopes: <String>[
      GoogleAPI.CalendarApi.calendarScope,
      'email',
    ],
  );

  GoogleSignInAccount? _currentUser;
  bool _isSignedIn = false; // Biến trạng thái đăng nhập

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        _isSignedIn = account != null; // Cập nhật trạng thái đăng nhập
      });
    });
    _googleSignIn.signInSilently(); // Thử đăng nhập ngầm
  }

  Future<void> _ensureSignIn() async {
    if (!_isSignedIn) {
      // Chỉ đăng nhập nếu chưa đăng nhập
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception("User cancelled sign-in");
        }
      } catch (e) {
        print('Error signing in: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign in.')),
        );
        return; // Thoát khỏi hàm nếu đăng nhập thất bại
      }
    }
  }

  Future<List<GoogleAPI.Event>> getGoogleEventsData() async {
    await _ensureSignIn(); // Đảm bảo người dùng đã đăng nhập
    if (!_isSignedIn || _currentUser == null) return [];
    try {
      final httpClient = GoogleAPIClient(await _currentUser!.authHeaders);
      final calendarApi = GoogleAPI.CalendarApi(httpClient);

      final events = await calendarApi.events.list("primary");
      return events.items ?? [];
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  Future<void> addEvent() async {
    await _ensureSignIn(); // Đảm bảo người dùng đã đăng nhập
    if (!_isSignedIn || _currentUser == null) return;

    try {
      final httpClient = GoogleAPIClient(await _currentUser!.authHeaders);
      final calendarApi = GoogleAPI.CalendarApi(httpClient);

      final event = GoogleAPI.Event(
        summary: "New Event",
        description: "Description of the event",
        start: GoogleAPI.EventDateTime(
          dateTime: DateTime.now().add(const Duration(days: 1)),
          timeZone: "GMT+00:00",
        ),
        end: GoogleAPI.EventDateTime(
          dateTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
          timeZone: "GMT+00:00",
        ),
      );

      await calendarApi.events.insert(event, "primary");
      print("Event added successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event added successfully!')),
      );
    } catch (e) {
      print("Error adding event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add event.')),
      );
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception("User not signed in");
      }

      final httpClient = GoogleAPIClient(await googleUser.authHeaders);
      final calendarApi = GoogleAPI.CalendarApi(httpClient);

      await calendarApi.events.delete("primary", eventId);
      print("Event deleted successfully!");
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  Future<void> updateEvent(String eventId) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception("User not signed in");
      }

      final httpClient = GoogleAPIClient(await googleUser.authHeaders);
      final calendarApi = GoogleAPI.CalendarApi(httpClient);

      // Fetch the existing event
      final event = await calendarApi.events.get("primary", eventId);

      // Update details
      event.summary = "Updated Event Title";
      event.description = "Updated Description";
      event.start = GoogleAPI.EventDateTime(
        dateTime: DateTime.now().add(const Duration(days: 2)),
        timeZone: "GMT+00:00",
      );
      event.end = GoogleAPI.EventDateTime(
        dateTime: DateTime.now().add(const Duration(days: 2, hours: 1)),
        timeZone: "GMT+00:00",
      );

      await calendarApi.events.update(event, "primary", eventId);
      print("Event updated successfully!");
    } catch (e) {
      print("Error updating event: $e");
    }
  }

  void _showEventActionsDialog(BuildContext context, GoogleAPI.Event event) {
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
                await deleteEvent(event.id!); // Delete the event
                setState(() {}); // Refresh the UI
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await updateEvent(event.id!); // Update the event
                setState(() {}); // Refresh the UI
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Calendar Events'),
      ),
      body: FutureBuilder<List<GoogleAPI.Event>>(
        future: getGoogleEventsData(),
        builder: (BuildContext context,
            AsyncSnapshot<List<GoogleAPI.Event>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
                child: Text('Failed to fetch calendar events.'));
          }

          return SfCalendar(
            view: CalendarView.month,
            initialDisplayDate: DateTime.now(),
            dataSource: GoogleDataSource(events: snapshot.data!),
            monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            ),
            onTap: (CalendarTapDetails details) {
              if (details.appointments != null &&
                  details.appointments!.isNotEmpty) {
                final GoogleAPI.Event event =
                    details.appointments!.first as GoogleAPI.Event;
                _showEventActionsDialog(context, event);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addEvent(); // Add a new event
          setState(() {}); // Refresh the UI
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    // _googleSignIn.disconnect(); // Không cần thiết phải disconnect mỗi khi dispose, nếu muốn đăng xuất hẳn thì dùng signOut()
    super.dispose();
  }
}
