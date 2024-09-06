# linkage_picker
A cupertino-picker-style linkage picker widget. Provided [DatePicker] implement and you can extend [LinkagePickerWidget] to achieve what you want in more scene easily.

<p align="center">
  <img src="https://raw.githubusercontent.com/YanhqZ/img/master/blob/linkage_picker/img1.png" alt="Image 1" width="200" style="margin-right: 30px;"/>
  <img src="https://raw.githubusercontent.com/YanhqZ/img/master/blob/linkage_picker/img2.png" alt="Image 2" width="200" style="margin-right: 30px;"/>
  <img src="https://raw.githubusercontent.com/YanhqZ/img/master/blob/linkage_picker/img3.png" alt="Image 3" width="200" style="margin-right: 30px;"/>
</p>

## DatePicker
DatePicker is a pre-archive linkage picker
```dart
DatePicker(
  start: DateTime(2000, today.month, today.day),
  end: DateTime(2050, today.month, today.day),
  date: date,
)
```
You can use `showAsBottomSheet` to show DatePicker as BottomSheet-Style
```dart
DatePicker(
  ...
).showAsBottomSheet(context)
```
Or wrap it anywhere just like this
```dart
ValueListenableBuilder<bool>(
  valueListenable: showPicker,
  builder: (context, value, _) {
    return value
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DatePicker(
                ...,
                onControllerCreated: (controller) {
                  this.controller = controller;
                },
              ),
              TextButton(
                onPressed: () {
                  showPicker.value = false;
                  final result = controller.result;
                  if (result != null) {
                    content.value = DateFormat('yyyy-MM-dd').format(result);
                  }
                },
                child: const Text('Confirm')),
            ],
          )
        : const SizedBox.shrink();
  })
```
## CustomPicker
You can extend `LinkagePickerWidget` to develop your own linkage picker
```dart
class CustomPicker extends LinkagePickerWidget<CustomData, String> {
  CustomPicker()
      : super(
          maxLevel: LinkagePickerLevel.second,
          dataBuilder: (level, parent) {
            return switch (level) {
              LinkagePickerLevel.first => LinkagePickerData<CustomData>[...],
              LinkagePickerLevel.second => LinkagePickerData<CustomData>[...],
              _ => throw UnimplementedError(),
            };
          },
          equalizer: (level, value1, value2) {
            return switch (level) {
              _ => (value1 as CustomData).equals(value2 as CustomData),
            };
          },
          resultConverter: (selection) {
            final getResultString(selection.first, selection.last);
          },
          conflictResolver: (level, previous, currents) {
            return switch (level) {
              LinkagePickerLevel.first => null,
              LinkagePickerLevel.second =>
                (previous as CustomData).copyWith(...),
              _ => throw UnimplementedError(),
            };
          },
          initialValue: <CustomData>[...],
          pickerStyle: LinkagePickerStyle(
            itemBuilder: (level, data, selected) {
              switch (level) {
                case LinkagePickerLevel.first:
                  return buildFirstPickerItem(data, selected);
                case LinkagePickerLevel.second:
                  return buildSecondPickerItem(data, selected);
                default:
                  throw UnimplementedError();
              }
            },
          ),
        );
}
```
### LinkagePickerWidget<T,R>
- `T`: The type of the data source value
- `R`: The type of the result
- `maxLevel`: The maximum level of the picker
- `dataBuilder`: Return the datasource from current level and parent data.
- `equalizer`: Tell Widget whether two value are equal in current level.
- `resultConverter`: Convert the result to the type you want
- `conflictResolver`: Convert picker selected result to navigation result.
- `initialValue`: The initial value of picker
- `pickerStyle`: Customize the style of the picker
- `onControllerCreated`: Callback when controller created


### LinkagePickerStyle
- `diameterRatio`: Same as [CupertinoPicker.diameterRatio]
- `itemExtent`: Same as [CupertinoPicker.itemExtent]
- `backgroundColor`: Same as [CupertinoPicker.backgroundColor]
- `offAxisFraction`: Same as [CupertinoPicker.offAxisFraction]
- `squeeze`: Same as [CupertinoPicker.squeeze]
- `useMagnifier`: Same as [CupertinoPicker.useMagnifier]
- `magnification`: Same as [CupertinoPicker.magnification]
- `selectionOverlay`: Same as [CupertinoPicker.selectionOverlay]
- `heightRatio`: The ratio of the height of the picker to the height of the item
- `itemBuilder`: Customize the item of the picker
