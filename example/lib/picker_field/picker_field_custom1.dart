import 'package:example/picker_field/picker_field.dart';
import 'package:flutter/material.dart';
import 'package:linkage_picker/linkage_picker.dart';

class PickerFieldCustom1 extends PickerField<Color> {
  PickerFieldCustom1(
    BuildContext context, {
    super.key,
  }) : super(
          hintText: 'Custom1',
          onTap: (ctx, color) {
            return _ColorPalettePicker(color).showAsBottomSheet(
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
                'Color Palette',
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
          converter: (Color data) {
            return Expanded(
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: data,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          },
        );
}

class _ColorPalettePicker extends LinkagePickerWidget<_PaletteData, Color> {
  _ColorPalettePicker(Color? initialColor)
      : super(
          maxLevel: LinkagePickerLevel.second,
          dataBuilder: (level, parent) {
            return switch (level) {
              LinkagePickerLevel.first => [
                  LinkagePickerData(value: _PaletteFirstData(Colors.red)),
                  LinkagePickerData(value: _PaletteFirstData(Colors.orange)),
                  LinkagePickerData(value: _PaletteFirstData(Colors.amber)),
                  LinkagePickerData(value: _PaletteFirstData(Colors.green)),
                  LinkagePickerData(value: _PaletteFirstData(Colors.teal)),
                  LinkagePickerData(value: _PaletteFirstData(Colors.indigo)),
                  LinkagePickerData(value: _PaletteFirstData(Colors.purple)),
                ],
              LinkagePickerLevel.second => List.generate(
                  10,
                  (index) => LinkagePickerData(
                    value: _PaletteSecondData(
                      originColor: (parent.first as _PaletteFirstData).color,
                      opacity: (index + 1) * 10,
                    ),
                  ),
                ),
              _ => throw UnimplementedError(),
            };
          },
          equalizer: (level, value1, value2) {
            return switch (level) {
              LinkagePickerLevel.first => (value1 as _PaletteFirstData).color.value ==
                  (value2 as _PaletteFirstData).color.value,
              LinkagePickerLevel.second =>
                (value1 as _PaletteSecondData).opacity ==
                    (value2 as _PaletteSecondData).opacity,
              _ => throw UnimplementedError(),
            };
          },
          resultConverter: (selection) {
            final secondData = selection.last as _PaletteSecondData;
            return secondData.originColor.withOpacity(
              secondData.opacity / 100,
            );
          },
          conflictResolver: (level, previous, currents) {
            return switch (level) {
              LinkagePickerLevel.first => null,
              LinkagePickerLevel.second =>
                (currents.first as _PaletteSecondData).copyWith(
                  opacity: (previous as _PaletteSecondData).opacity,
                ),
              _ => throw UnimplementedError(),
            };
          },
          initialValue: initialColor == null
              ? null
              : [
                  _PaletteFirstData(Color.fromRGBO(
                    initialColor.red,
                    initialColor.green,
                    initialColor.blue,
                    1,
                  )),
                  _PaletteSecondData(
                    originColor: Color.fromRGBO(
                      initialColor.red,
                      initialColor.green,
                      initialColor.blue,
                      1,
                    ),
                    opacity: (initialColor.opacity * 100).toInt(),
                  ),
                ],
          pickerStyle: LinkagePickerStyle(
            itemBuilder: (level, data, selected) {
              switch (level) {
                case LinkagePickerLevel.first:
                  final paletteData = data.value as _PaletteFirstData;
                  return Center(
                    child: Icon(
                      Icons.rectangle_rounded,
                      color: paletteData.color,
                      size: 36,
                    ),
                  );
                case LinkagePickerLevel.second:
                  final paletteData = data.value as _PaletteSecondData;
                  return Center(
                    child: Text(
                      '${paletteData.opacity}%',
                      style: TextStyle(
                        color: paletteData.originColor
                            .withOpacity(paletteData.opacity / 100),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                default:
                  throw UnimplementedError();
              }
            },
          ),
        );
}

class _PaletteData {}

class _PaletteFirstData extends _PaletteData {
  final Color color;

  _PaletteFirstData(this.color);

  @override
  String toString() {
    return '$_PaletteFirstData{color: $color}';
  }
}

class _PaletteSecondData extends _PaletteData {
  final Color originColor;
  final int opacity;

  _PaletteSecondData({
    required this.originColor,
    required this.opacity,
  });

  @override
  String toString() {
    return '$_PaletteSecondData{originColor: $originColor, opacity: $opacity}';
  }

  copyWith({
    Color? originColor,
    int? opacity,
  }) {
    return _PaletteSecondData(
      originColor: originColor ?? this.originColor,
      opacity: opacity ?? this.opacity,
    );
  }
}
