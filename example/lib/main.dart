import 'package:flutter/material.dart';

import 'add_food_page.dart';

void main() => runApp(const DirectSelectExampleApp());

class DirectSelectExampleApp extends StatelessWidget {
  const DirectSelectExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Direct Select Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AddFoodPage(),
    );
  }
}
