import 'package:flutter/material.dart';
import 'package:instagram/services/auth_service.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: Text("Feed"),
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                AuthService.logout();
              },
              child: Text("Logout"),
            ),
          )
        ],
      ),
    );
  }
}
