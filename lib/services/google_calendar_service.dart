import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleAPI;
import 'package:http/io_client.dart';
import 'package:http/http.dart' show BaseRequest, Response;

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

class GoogleCalendarService {
  final GoogleSignIn googleSignIn;

  GoogleCalendarService(this.googleSignIn);

  Future<List<GoogleAPI.Event>> getGoogleEventsData() async {
    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception("User not signed in");
    }

    final httpClient = GoogleAPIClient(await googleUser.authHeaders);
    final calendarApi = GoogleAPI.CalendarApi(httpClient);

    final events = await calendarApi.events.list("primary");
    return events.items ?? [];
  }

  Future<void> addEvent() async {
    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception("User not signed in");
    }

    final httpClient = GoogleAPIClient(await googleUser.authHeaders);
    final calendarApi = GoogleAPI.CalendarApi(httpClient);

    final event = GoogleAPI.Event(
      summary: "New Event",
      start: GoogleAPI.EventDateTime(
        dateTime: DateTime.now().add(const Duration(days: 1)),
      ),
      end: GoogleAPI.EventDateTime(
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
      ),
    );

    await calendarApi.events.insert(event, "primary");
  }
}
