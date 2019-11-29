import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/home_screen.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/screens/signup_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram',
      debugShowCheckedModeBanner: false,
      routes: {
        HomeScreen.id:(context)=>HomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        SignUpScreen.id: (context) => SignUpScreen(),
      },
      home: _displayScreen(),
    );
  }


  Widget _displayScreen(){
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged ,
      builder: (BuildContext context, AsyncSnapshot snapshot){
       if(snapshot.hasData){
         return HomeScreen();
       }else{
         return LoginScreen();
       }
      },
    );
  }
}
