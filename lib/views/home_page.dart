import 'package:calendar_of_life/models/google_data_source.dart';
import 'package:calendar_of_life/services/google_calendar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'login_screen.dart';
// Import GoogleDataSource model

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '1001415118047-5vac5u8b7vlns8buin6h2cnq7vukdii3.apps.googleusercontent.com', // Your client ID
    scopes: <String>[
      'https://www.googleapis.com/auth/calendar',
      'email',
    ],
  );
  GoogleSignInAccount? _googleUser;

  @override
  void initState() {
    super.initState();
    _checkFirebaseSignIn();
  }

  // Check if user is signed in via Firebase
  Future<void> _checkFirebaseSignIn() async {
    User? user = _auth.currentUser;
    if (user == null) {
      // User is not logged in, navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // User is logged in, check Google sign-in
      _checkGoogleSignIn();
    }
  }

  // Check if user is signed in via Google
  Future<void> _checkGoogleSignIn() async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) {
        googleUser = await _googleSignIn.signIn();
      }
      setState(() {
        _googleUser = googleUser;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Calendar Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List>(
        future: _getGoogleCalendarEvents(),
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
          if (_googleUser != null) {
            await GoogleCalendarService(_googleSignIn)
                .addEvent(); // Add event using GoogleCalendarService
            setState(() {});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please sign in with Google first.')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Logout user
  Future<void> _logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<List> _getGoogleCalendarEvents() async {
    if (_googleUser != null) {
      return await GoogleCalendarService(_googleSignIn).getGoogleEventsData();
    } else {
      throw Exception("User not signed in");
    }
  }
}