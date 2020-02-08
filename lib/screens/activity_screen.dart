import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Instagram",
          style: TextStyle(
            color: Colors.black,
            fontFamily: "Billabong",
            fontSize: 35,
          ),
        ),
      ),
      body: Center(
        child: Text("Activity"),
      ),
    );
  }
}
