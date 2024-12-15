import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/google_data_source.dart';
import '../services/google_calendar_service.dart';
import 'package:googleapis/calendar/v3.dart'; // Import Event class

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: 'YOUR_WEB_OAUTH_CLIENT_ID', // Thay clientId tại đây
    scopes: <String>[
      'https://www.googleapis.com/auth/calendar',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Calendar Events'),
      ),
      body: FutureBuilder<List>(
        future: GoogleCalendarService(_googleSignIn).getGoogleEventsData(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text('Failed to fetch calendar events.'),
            );
          }

          return SfCalendar(
            view: CalendarView.month,
            initialDisplayDate: DateTime.now(),
            dataSource: GoogleDataSource(events: snapshot.data!.cast<Event>()),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await GoogleCalendarService(_googleSignIn).addEvent();
          setState(() {});
        },
        child: const Icon(Icons.add),
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
