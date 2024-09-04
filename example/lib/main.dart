import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkage_picker/linkage_picker.dart';

import 'picker_field.dart';

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
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              PickerField<DateTime>(
                hintText: 'Select date...',
                onTap: (ctx, date) {
                  final today = DateTime.now();
                  return DatePicker(
                    start: DateTime(2000, today.month, today.day),
                    end: DateTime(2050, today.month, today.day),
                    date: date,
                  ).showAsBottomSheet(
                    context: context,
                    topBarPadding: const EdgeInsets.all(16),
                    cancel: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
                        fontSize: 18,
                      ),
                    ),
                    title: Text(
                      'Select',
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
                converter: (DateTime data) {
                  return DateFormat('yyyy-MM-dd').format(data);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
