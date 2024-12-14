import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleAPI;
import 'package:http/io_client.dart';
import 'package:http/http.dart' show BaseRequest, Response;
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
    clientId: 'YOUR_WEB_OAUTH_CLIENT_ID', // Thay clientId tại đây
    scopes: <String>[
      GoogleAPI.CalendarApi.calendarScope,
      'email',
    ],
  );

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<List<GoogleAPI.Event>> getGoogleEventsData() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception("User not signed in");
      }

      final httpClient = GoogleAPIClient(await googleUser.authHeaders);
      final calendarApi = GoogleAPI.CalendarApi(httpClient);

      // Fetch events
      final events = await calendarApi.events.list("primary");
      final List<GoogleAPI.Event> appointments = events.items ?? [];

      return appointments;
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _googleSignIn.disconnect();
    _googleSignIn.signOut();
    super.dispose();
  }
}

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
