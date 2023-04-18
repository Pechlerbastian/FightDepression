import 'package:flutter/material.dart';
import 'package:projektmodul/page.dart';
import 'package:projektmodul/sentences_util.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Sentences().parseXml();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            debugShowCheckedModeBanner: false, // this removes the debug banner

      theme: ThemeData(
        textTheme: const TextTheme(
          bodyText1: TextStyle(fontSize: 16, fontFamily: 'Open Sans', fontWeight: FontWeight.w400, color: Colors.white),
          bodyText2: TextStyle(fontSize: 14, fontFamily: 'Open Sans', fontWeight: FontWeight.w400, color: Colors.black),
          subtitle1: TextStyle(fontSize: 12, fontFamily: 'Open Sans', fontWeight: FontWeight.w400, color: Colors.black),
          subtitle2: TextStyle(fontSize: 12, fontFamily: 'Open Sans', fontWeight: FontWeight.w700, color: Colors.black),
          headline1: TextStyle(fontSize: 18, fontFamily: 'Open Sans', fontWeight: FontWeight.w400, color: Colors.white),
          headline2: TextStyle(fontSize: 16, fontFamily: 'Open Sans', fontWeight: FontWeight.w400, color: Colors.black),
          headline3: TextStyle(fontSize: 18, fontFamily: 'Open Sans', fontWeight: FontWeight.w400, color: Colors.black),
         
        ),
      
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        secondaryHeaderColor: const Color(0xFF353B3F),
        backgroundColor: const Color(0xFFF2FAFF),
        primaryColorLight: Colors.white,
        primaryColorDark: const Color(0xFFC2E1F3)
    ),
      home: const BasicPage()
    );
  }
}
