import 'package:flutter/material.dart';

class PickerField<T> extends StatefulWidget {
  final Future<T?> Function(BuildContext, T?) onTap;
  final Widget Function(T data) converter;
  final String hintText;

  const PickerField({
    super.key,
    required this.onTap,
    required this.hintText,
    required this.converter,
  });

  @override
  State<PickerField<T>> createState() => _PickerFieldState<T>();
}

class _PickerFieldState<T> extends State<PickerField<T>> {
  final ValueNotifier<T?> data = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await widget.onTap.call(context, data.value);
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
                  return shouldShowHint
                      ? Expanded(
                          child: Text(
                            widget.hintText,
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                            ),
                          ),
                        )
                      : widget.converter.call(value);
                }),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}
