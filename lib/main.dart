import 'package:authentication_app/PhoneVerification.dart';
import 'package:authentication_app/WelcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

 Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){runApp(MyApp());});
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String email;

  @override
  void initState() {
    Login();
    super.initState();
  }

  @override
  Widget build(BuildContext context)  {
    return (MaterialApp(
      debugShowCheckedModeBanner: false,
        home: email == null ? PhoneVerification() : WelcomeScreen()));
  }
  Future Login() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString('Key');
    });
  }
}