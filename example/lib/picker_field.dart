import 'package:flutter/material.dart';

class PickerField<T> extends StatelessWidget {
  final Future<T?> Function(BuildContext, T?) onTap;
  final String Function(T data) converter;
  final String hintText;
  final ValueNotifier<T?> data = ValueNotifier(null);

  PickerField({
    super.key,
    required this.onTap,
    required this.hintText,
    required this.converter,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await onTap.call(context, data.value);
        if (result != null) {
          data.value = result;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.secondaryContainer),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ValueListenableBuilder<T?>(
                valueListenable: data,
                builder: (context, value, _) {
                  final shouldShowHint = value == null;
                  return Text(
                    shouldShowHint ? hintText : converter.call(value),
                    style: TextStyle(
                      fontSize: 20,
                      color: shouldShowHint
                          ? Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4)
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                }),
            const Spacer(),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}
