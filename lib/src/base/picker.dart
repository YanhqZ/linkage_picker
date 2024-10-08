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

/// Tell Widget whether [value1] and [value2] are equal in current [level].
typedef _PickerDataEqualizer<T> = bool Function(
    LinkagePickerLevel level, T value1, T value2);

/// Convert picker selected result[selection] to navigation result.
typedef _PickerResultConverter<T, R> = R Function(List<T> selection);

/// Linkage CupertinoPicker
class LinkagePickerWidget<T, R> extends StatefulWidget {
  /// Datasource
  final _PickerDataBuilder<T> _dataBuilder;

  /// Max level
  final LinkagePickerLevel maxLevel;

  /// Equalizer
  final _PickerDataEqualizer<T> _equalizer;

  /// ResultConverter
  final _PickerResultConverter<T, R> _resultConverter;

  /// ConflictResolver
  final _PickerConflictResolver<T>? _conflictResolver;

  /// Initial value
  final List<T?>? initialValue;

  /// Style
  final LinkagePickerStyle pickerStyle;

  /// Controller to access the result
  late final LinkagePickerController<R> controller;

  /// If true, the pickers will not affect each other so You don't need to achieve [_conflictResolver].
  /// Default is false.
  final bool unLinkage;

  final ValueChanged<LinkagePickerController<R>>? _onControllerCreated;

  // ignore: prefer_const_constructors_in_immutables
  LinkagePickerWidget({
    super.key,
    required List<LinkagePickerData<T>> Function(LinkagePickerLevel, List<T>)
        dataBuilder,
    required bool Function(LinkagePickerLevel, T, T) equalizer,
    required this.maxLevel,
    required R Function(List<T>) resultConverter,
    T? Function(LinkagePickerLevel, T, List<T>)? conflictResolver,
    this.initialValue,
    this.pickerStyle = const LinkagePickerStyle(),
    this.unLinkage = false,
    ValueChanged<LinkagePickerController<R>>? onControllerCreated,
  })  : _conflictResolver = conflictResolver,
        _resultConverter = resultConverter,
        _equalizer = equalizer,
        _dataBuilder = dataBuilder,
        _onControllerCreated = onControllerCreated
  ;

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
    widget._onControllerCreated?.call(widget.controller);
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
            : data.indexWhere((element) =>
                widget._equalizer.call(level, element.value, initial)),
      ));
    });

    if (widget.unLinkage == false) {
      for (var i = 0; i < columns - 1; i++) {
        final nextLevel = LinkagePickerLevel.values[i + 1];
        values[i].addListener(() {
          final parent = List.generate(i + 1, (index) => values[index].value)
              .whereType<T>()
              .toList();
          dataSource[i + 1] = widget._dataBuilder.call(nextLevel, parent);
          final previous = values[i + 1].value;
          final resolved = previous == null
              ? null
              : widget._conflictResolver?.call(nextLevel, previous,
                  dataSource[i + 1].map((e) => e.value).toList());

          if (resolved != null) {
            final resolvedIndex = max(
                0,
                dataSource[i + 1].indexWhere((element) => widget._equalizer
                    .call(LinkagePickerLevel.values[i + 1], element.value,
                        resolved)));
            controllers[i + 1].jumpToItem(resolvedIndex);
            values[i + 1].value = resolved;
          }
        });
      }
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
        height: widget.pickerStyle.itemExtent * widget.pickerStyle.heightRatio,
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

  Widget _buildItem(
      LinkagePickerLevel level, LinkagePickerData<T> data, bool isSelected) {
    return Center(
      child: widget.pickerStyle.itemBuilder.call(level, data, isSelected),
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
                      level,
                      e,
                      value == null
                          ? false
                          : widget._equalizer.call(level, value, e.value));
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
  /// Can be displayed in the picker default item
  final String title;
  final T value;

  LinkagePickerData({
    this.title = "",
    required this.value,
  });

  @override
  String toString() {
    return 'title: $title, value: $value';
  }
}
