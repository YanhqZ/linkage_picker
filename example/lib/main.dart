import 'package:example/picker_field/picker_field_custom_color_palette.dart';
import 'package:example/picker_field/picker_field_date_bottom_sheet.dart';
import 'package:example/picker_field/picker_field_date.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Linkage Picker Example'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              pickerExampleSegment(
                'DatePicker',
                const PickerFieldDate(),
              ),
              pickerExampleSegment(
                'DatePicker[BottomSheet]',
                PickerFieldDateBottomSheet(context),
              ),
              pickerExampleSegment(
                'CustomPicker[ColorPalette]',
                PickerFieldCustomColorPalette(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pickerExampleSegment(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 20),
      ],
    );
  }
}
