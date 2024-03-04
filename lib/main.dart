import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/data/workout_data.dart';

import 'pages/home_page.dart';

void main() async {
  // initialize Hive
  await Hive.initFlutter();
  // open hive box
  await Hive.openBox("workout_database");
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => WorkoutData(),
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),);
  }
}


