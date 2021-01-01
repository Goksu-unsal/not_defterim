import 'package:flutter/material.dart';
import 'package:not_sepeti/screens/notes_list_page.dart';
import 'package:not_sepeti/utils/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DatabaseHelper db_helper = DatabaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          textTheme: TextTheme(bodyText1: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey.shade600,
          primaryColor: Colors.grey.shade600,
          scaffoldBackgroundColor: Colors.blueGrey.shade200,
      ),
      home: NotesListPage(),
    );
  }
}
