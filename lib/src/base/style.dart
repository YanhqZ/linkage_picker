import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linkage_picker/linkage_picker.dart';

class LinkagePickerStyle {
  static const double defaultItemExtent = 44.0;
  static const double defaultHeightRatio = 5.0;
  static const double defaultDiameterRatio = 10;
  static const double defaultSqueeze = 1;

  /// See [CupertinoPicker.diameterRatio] for more details.
  final double diameterRatio;

  /// See [CupertinoPicker.backgroundColor] for more details.
  final Color? backgroundColor;

  /// See [CupertinoPicker.offAxisFraction] for more details.
  final double offAxisFraction;

  /// See [CupertinoPicker.useMagnifier] for more details.
  final bool useMagnifier;

  /// See [CupertinoPicker.magnification] for more details.
  final double magnification;

  /// See [CupertinoPicker.itemExtent] for more details.
  final double itemExtent;

  /// See [CupertinoPicker.squeeze] for more details.
  final double squeeze;

  /// See [CupertinoPicker.selectionOverlay] for more details.
  final Widget selectionOverlay;

  /// The radio for picker height to item extent.
  final double heightRatio;

  final Widget Function(
    LinkagePickerLevel level,
    LinkagePickerData data,
    bool isSelected,
  ) itemBuilder;

  const LinkagePickerStyle({
    this.diameterRatio = defaultDiameterRatio,
    this.backgroundColor,
    this.offAxisFraction = 0.0,
    this.useMagnifier = false,
    this.magnification = 1.0,
    this.itemExtent = defaultItemExtent,
    this.squeeze = defaultSqueeze,
    this.selectionOverlay = const LinkagePickerDefaultSelectionOverlay(),
    this.heightRatio = defaultHeightRatio,
    this.itemBuilder = _buildDefaultItem,
  });

  static Widget _buildDefaultItem(LinkagePickerLevel level, LinkagePickerData data, bool isSelected) {
    return Text(
      data.title,
      style: TextStyle(
        color: isSelected ? Colors.black : Colors.grey.withOpacity(0.7),
        fontSize: 16,
      ),
    );
  }
}

class LinkagePickerDefaultSelectionOverlay extends StatelessWidget {
  const LinkagePickerDefaultSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Colors.grey.withOpacity(0.7),
            width: 0.5,
          ),
        ),
      ),
    );
  }
}
