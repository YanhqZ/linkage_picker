import 'package:flutter/widgets.dart';

abstract class LinkagePickerController<R> {
  BuildContext? context;

  R? get result;
}
