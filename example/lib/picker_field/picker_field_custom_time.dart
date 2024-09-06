import 'package:example/picker_field/picker_field.dart';
import 'package:flutter/material.dart';
import 'package:linkage_picker/linkage_picker.dart';

class PickerFieldCustomTime extends PickerField<String> {
  PickerFieldCustomTime(
    BuildContext context, {
    super.key,
  }) : super(
          hintText: 'Select time',
          onTap: (ctx, color) {
            return _TimePicker(color).showAsBottomSheet(
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
                'Time',
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
          converter: (String data) {
            return Expanded(
              child: Text(
                data,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          },
        );
}

class _TimePicker extends LinkagePickerWidget<int, String> {
  _TimePicker(String? time)
      : super(
          maxLevel: LinkagePickerLevel.second,
          unLinkage: true,
          dataBuilder: (level, parent) {
            return switch (level) {
              LinkagePickerLevel.first => List.generate(
                  24,
                  (index) => LinkagePickerData(
                    title: '$index'.padLeft(2, '0'),
                    value: index,
                  ),
                ),
              LinkagePickerLevel.second => List.generate(
                  60 ~/ 5 + 1,
                  (index) => LinkagePickerData(
                    title: '${index * 5}'.padLeft(2, '0'),
                    value: index * 5,
                  ),
                ),
              _ => throw UnimplementedError(),
            };
          },
          equalizer: (level, value1, value2) {
            return value1 == value2;
          },
          resultConverter: (selection) {
            return '${selection.first.toString().padLeft(2, '0')}:${selection.last.toString().padLeft(2, '0')}';
          },
          initialValue: time?.split(":").map((e) => int.parse(e)).toList(),
          pickerStyle: LinkagePickerStyle(
            heightRatio: 3,
            itemExtent: 56,
            itemBuilder: (level, data, selected) {
              return Builder(builder: (context) {
                return Center(
                  child: Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 22,
                      color: selected
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                    ),
                  ),
                );
              });
            },
          ),
        );
}
