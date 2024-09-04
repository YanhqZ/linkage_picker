import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:linkage_picker/linkage_picker.dart';

enum LinkagePickerLevel {
  first,
  second,
  third,
  fourth,
}

/// Datasource constructor.
/// Return the datasource from current level [level] and parent level data [parent].
typedef _PickerDataBuilder<T> = List<LinkagePickerData<T>> Function(
    LinkagePickerLevel level, List<T> parent);

/// ConflictResolver.
/// Resolve and return the result from current level [level] and previous value [previous]
/// and current datasource[currents].
typedef _PickerConflictResolver<T> = T? Function(
    LinkagePickerLevel level, T previous, List<T> currents);

/// Tell Widget whether [value1] and [value2] are equal
typedef _PickerDataEqualizer<T> = bool Function(T value1, T value2);

/// Convert picker selected result[selection] to navigation result.
typedef _PickerResultConverter<T, R> = R Function(List<T> selection);

/// Linkage CupertinoPicker
class LinkagePickerWidget<T, R> extends StatefulWidget {
  /// Datasource
  final _PickerDataBuilder<T> _dataBuilder;

  /// Max level
  final LinkagePickerLevel maxLevel;

  /// Title
  final String title;

  /// Equalizer
  final _PickerDataEqualizer<T> _equalizer;

  /// ResultConverter
  final _PickerResultConverter<T, R> _resultConverter;

  /// ConflictResolver
  final _PickerConflictResolver<T> _conflictResolver;

  /// Initial value
  final List<T?>? initialValue;

  /// Style
  final LinkagePickerStyle pickerStyle;

  late final LinkagePickerController<R> controller;

  LinkagePickerWidget({
    super.key,
    this.title = 'Select',
    required List<LinkagePickerData<T>> Function(LinkagePickerLevel, List<T>)
        dataBuilder,
    required bool Function(T, T) equalizer,
    required this.maxLevel,
    required R Function(List<T>) resultConverter,
    required T? Function(LinkagePickerLevel, T, List<T>) conflictResolver,
    this.initialValue,
    this.pickerStyle = const LinkagePickerStyle(),
  })  : _conflictResolver = conflictResolver,
        _resultConverter = resultConverter,
        _equalizer = equalizer,
        _dataBuilder = dataBuilder;

  @override
  State<LinkagePickerWidget<T, R>> createState() =>
      _LinkagePickerWidgetState<T, R>();
}

class _LinkagePickerWidgetState<T, R> extends State<LinkagePickerWidget<T, R>> {
  List<ValueNotifier<T?>> values = [];
  List<FixedExtentScrollController> controllers = [];
  List<List<LinkagePickerData<T>>> dataSource = [];
  late final int columns;

  @override
  void initState() {
    super.initState();
    columns = widget.maxLevel.index + 1;
    widget.controller = _LinkagePickerControllerImpl<T, R>();
    List.generate(columns, (index) {
      final level = LinkagePickerLevel.values[index];
      values.add(ValueNotifier(widget.initialValue?[index]));
      final data = widget._dataBuilder.call(level,
          List.generate(index, (i) => values[i].value).whereType<T>().toList());
      final initial = values[index].value ??= data.firstOrNull?.value;
      dataSource.add(data);
      controllers.add(FixedExtentScrollController(
        initialItem: initial == null
            ? 0
            : data.indexWhere(
                (element) => widget._equalizer.call(element.value, initial)),
      ));
    });

    for (var i = 0; i < columns - 1; i++) {
      final nextLevel = LinkagePickerLevel.values[i + 1];
      values[i].addListener(() {
        final parent = List.generate(i + 1, (index) => values[index].value)
            .whereType<T>()
            .toList();
        dataSource[i + 1] = widget._dataBuilder.call(nextLevel, parent);
        final resolved = widget._conflictResolver.call(
            nextLevel,
            values[i + 1].value!,
            dataSource[i + 1].map((e) => e.value).toList());

        if (resolved != null) {
          final resolvedIndex = max(
              0,
              dataSource[i + 1].indexWhere((element) =>
                  widget._equalizer.call(element.value, resolved)));
          controllers[i + 1].jumpToItem(resolvedIndex);
          values[i + 1].value = resolved;
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (var element in controllers) {
      element.dispose();
    }
    for (var element in values) {
      element.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      widget.controller.context = context;
      return Container(
        height: widget.pickerStyle.itemExtent *
            widget.pickerStyle.visibleItemCount.toDouble(),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(columns, (index) {
            return _buildPickerColumn(LinkagePickerLevel.values[index]);
          }).map((e) => Flexible(child: e)).toList(),
        ),
      );
    });
  }

  Widget _buildItem(LinkagePickerData<T> data, bool isSelected) {
    return Center(
      child: widget.pickerStyle.itemBuilder.call(data, isSelected),
    );
  }

  /// build a cupertinoPicker
  Widget _buildPickerColumn(LinkagePickerLevel level) {
    Widget finalChild() {
      final data = dataSource[level.index];
      return _CustomCupertinoPicker(
        style: widget.pickerStyle,
        scrollController: controllers[level.index],
        onSelectedItemChanged: (index) {
          values[level.index].value = data[index].value;
        },
        children: data
            .map((e) => ValueListenableBuilder(
                valueListenable: values[level.index],
                builder: (_, value, __) {
                  return _buildItem(
                      e,
                      value == null
                          ? false
                          : widget._equalizer.call(value, e.value));
                }))
            .toList(),
      );
    }

    return List.generate(level.index, (index) => level.index - index)
        .fold(finalChild(), (previousValue, element) {
      if (element == level.index) {
        return ValueListenableBuilder(
            valueListenable: values[element - 1],
            builder: (ctx, value, _) {
              return finalChild();
            });
      } else {
        return ValueListenableBuilder(
            valueListenable: values[element - 1],
            builder: (ctx, value, _) {
              return previousValue;
            });
      }
    });
  }
}

class _LinkagePickerControllerImpl<T, R> implements LinkagePickerController<R> {
  @override
  BuildContext? context;

  @override
  R? get result {
    final state =
        context?.findAncestorStateOfType<_LinkagePickerWidgetState<T, R>>();
    if (state != null) {
      final values = state.values.map((e) => e.value).whereType<T>().toList();
      return state.widget._resultConverter.call(values) as R?;
    }
    return null;
  }
}

/// Custom-style CupertinoPicker
class _CustomCupertinoPicker extends CupertinoPicker {
  _CustomCupertinoPicker({
    super.scrollController,
    required LinkagePickerStyle style,
    required super.onSelectedItemChanged,
    required super.children,
  }) : super(
          itemExtent: style.itemExtent,
          diameterRatio: style.diameterRatio,
          squeeze: style.squeeze,
          selectionOverlay: style.selectionOverlay,
        );
}

/// UI data model
class LinkagePickerData<T> {
  final String title;
  final T value;

  LinkagePickerData({
    required this.title,
    required this.value,
  });

  @override
  String toString() {
    return 'title: $title, value: $value';
  }
}
