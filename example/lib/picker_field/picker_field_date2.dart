import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:linkage_picker/linkage_picker.dart';
import 'package:intl/intl.dart';

class PickerFieldDate2 extends StatefulWidget {
  const PickerFieldDate2({
    super.key,
  });

  @override
  State<PickerFieldDate2> createState() => _PickerFieldDate2State();
}

class _PickerFieldDate2State extends State<PickerFieldDate2> {
  final ValueNotifier<String> content = ValueNotifier('');
  final ValueNotifier<bool> showPicker = ValueNotifier(false);
  late DatePickerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border:
            Border.all(color: Theme.of(context).colorScheme.secondaryContainer),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () async {
              showPicker.value = !showPicker.value;
            },
            child: Row(
              children: [
                ValueListenableBuilder<String>(
                    valueListenable: content,
                    builder: (context, value, _) {
                      final shouldShowHint = value.isEmpty;
                      return shouldShowHint
                          ? Expanded(
                              child: Text(
                                'Select date',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.4),
                                ),
                              ),
                            )
                          : Expanded(
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            );
                    }),
                const SizedBox(width: 16),
                ValueListenableBuilder<bool>(
                    valueListenable: showPicker,
                    builder: (context, value, _) {
                      return Icon(
                        value
                            ? Icons.keyboard_arrow_up_outlined
                            : Icons.keyboard_arrow_down_rounded,
                      );
                    }),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: ValueListenableBuilder<bool>(
                valueListenable: showPicker,
                builder: (context, value, _) {
                  return value
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DatePicker(
                              start: DateTime(2000),
                              end: DateTime(2050),
                              date: content.value.isEmpty
                                  ? null
                                  : DateFormat('yyyy-MM-dd')
                                      .parse(content.value),
                              onControllerCreated: (controller) {
                                this.controller = controller;
                              },
                            ),
                            TextButton(
                                onPressed: () {
                                  showPicker.value = false;
                                  final result = controller.result;
                                  if (result != null) {
                                    content.value =
                                        DateFormat('yyyy-MM-dd').format(result);
                                  }
                                },
                                child: const Text('Confirm')),
                          ],
                        )
                      : const SizedBox.shrink();
                }),
          )
        ],
      ),
    );
  }
}
