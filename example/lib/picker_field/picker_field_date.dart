import 'package:example/picker_field/picker_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkage_picker/linkage_picker.dart';

class PickerFieldDate extends PickerField<DateTime> {
  PickerFieldDate(BuildContext context, {super.key})
      : super(
          hintText: 'Select date',
          onTap: (ctx, date) {
            final today = DateTime.now();
            return DatePicker(
              start: DateTime(2000, today.month, today.day),
              end: DateTime(2050, today.month, today.day),
              date: date,
            ).showAsBottomSheet(
              context: context,
              topBarPadding: const EdgeInsets.all(16),
              cancel: Text(
                'Cancel',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 18,
                ),
              ),
              title: Text(
                'Select',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              confirm: Text(
                'Confirm',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          converter: (DateTime data) {
            return Expanded(
              child: Text(
                DateFormat('yyyy-MM-dd').format(data),
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          },
        );
}
