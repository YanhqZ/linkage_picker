import 'dart:math';

import 'package:linkage_picker/src/base/picker.dart';

/// A date picker widget.
class TWDatePicker extends LinkagePickerWidget<int, DateTime> {
  final DateTime start;
  final DateTime end;
  final DateTime? date;

  TWDatePicker({
    super.key,
    super.title,
    required this.start,
    required this.end,
    this.date,
    String yearSuffix = '',
    String monthSuffix = '',
    String daySuffix = '',
  }) : super(
          maxLevel: LinkagePickerLevel.third,
          equalizer: (value1, value2) => value1 == value2,
          initialValue: [
            date?.year ?? DateTime.now().year,
            date?.month ?? DateTime.now().month,
            date?.day ?? DateTime.now().day,
          ],
          dataBuilder: (order, parent) {
            switch (order) {
              case LinkagePickerLevel.first:
                final years = <int>[];
                for (var i = start.year; i <= end.year; i++) {
                  years.add(i);
                }
                return years
                    .map((e) =>
                        LinkagePickerData(title: '$e$yearSuffix', value: e))
                    .toList();
              case LinkagePickerLevel.second:
                final months =
                    List.generate(DateTime.monthsPerYear, (index) => index + 1);
                final year = parent.first;
                if (year == start.year) {
                  months.removeWhere((element) => element < start.month);
                }
                if (year == end.year) {
                  months.removeWhere((element) => element > end.month);
                }
                return months
                    .map((e) =>
                        LinkagePickerData(title: '$e$monthSuffix', value: e))
                    .toList();
              case LinkagePickerLevel.third:
                final year = parent.first;
                final month = parent.last;
                final dayInMonth = getDaysInMonth(year, month);
                final days = List.generate(dayInMonth, (index) => index + 1);
                if (year == start.year && month == start.month) {
                  days.removeWhere((element) => element < start.day);
                }
                if (year == end.year && month == end.month) {
                  days.removeWhere((element) => element > end.day);
                }
                return days
                    .map((e) =>
                        LinkagePickerData(title: '$e$daySuffix', value: e))
                    .toList();
              default:
                return [];
            }
          },
          resultConverter: (value) {
            return DateTime(
              value[0],
              value[1],
              value[2],
            );
          },
          conflictResolver: (order, previous, currents) {
            switch (order) {
              case LinkagePickerLevel.first:
                return null;
              case LinkagePickerLevel.second:
                return max(min(previous, currents.last), currents.first);
              case LinkagePickerLevel.third:
                return max(min(previous, currents.last), currents.first);
              default:
                return null;
            }
          },
        );

  static int getDaysInMonth(int year, int month) {
    int nextYear = month == DateTime.december ? year + 1 : year;
    int nextMonth = month == DateTime.december ? 1 : month + 1;
    DateTime firstDayOfNextMonth = DateTime(nextYear, nextMonth, 1);
    return firstDayOfNextMonth.subtract(const Duration(days: 1)).day;
  }
}
