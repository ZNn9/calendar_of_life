import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleAPI;

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
