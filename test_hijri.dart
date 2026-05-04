import 'package:hijri/hijri_calendar.dart';

void main() {
  HijriCalendar.setLocal('en');
  var h = HijriCalendar.fromDate(DateTime.now());
  print('Today Hijri: ${h.hYear}-${h.hMonth}-${h.hDay}');
}
