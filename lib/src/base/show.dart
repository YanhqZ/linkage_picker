import 'package:flutter/material.dart';
import 'package:linkage_picker/linkage_picker.dart';

extension LinkagePickerShowExt<T, R> on LinkagePickerWidget<T, R> {
  /// Show the picker.
  Future<R?> showAsBottomSheet({
    required BuildContext context,
    Widget? cancel,
    Widget? title,
    Widget? confirm,
    Color color = Colors.white,
    EdgeInsets topBarPadding = EdgeInsets.zero,
    ShapeBorder? shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
    ),
  }) {
    return showModalBottomSheet<R>(
      context: context,
      backgroundColor: color,
      shape: shape,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: topBarPadding,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: cancel == null
                            ? const SizedBox.shrink()
                            : InkWell(
                                onTap: Navigator.of(context).pop,
                                child: cancel,
                              ),
                      ),
                    ),
                    if (title != null)
                      Flexible(
                        child: Align(
                          alignment: Alignment.center,
                          child: title,
                        ),
                      ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: confirm == null
                            ? const SizedBox.shrink()
                            : InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .pop<R?>(controller.result);
                                },
                                child: confirm,
                              ),
                      ),
                    )
                  ],
                ),
              ),
              this,
            ],
          ),
        );
      },
    );
  }
}
