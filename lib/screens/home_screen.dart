import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/screens/create_post_screen.dart';
import 'package:instagram/screens/feed_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/screens/search_screen.dart';
import 'package:instagram/services/auth_service.dart';
import 'package:provider/provider.dart';

import 'activity_screen.dart';

class HomeScreen extends StatefulWidget {
  static final String id = "HomeScreen";

  HomeScreen();
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  PageController _pageController = new PageController();
  changeTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });

    _pageController.animateToPage(
      _selectedTabIndex,
      duration: Duration(milliseconds: 10),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          FeedScreen(),
          SearchScreen(),
          CreatePostScreen(),
          ActivityScreen(),
          ProfileScreen(
            //both currentUserId and userId are the same when going from
            //this screen but differs when going from search screen
            currentUserId: Provider.of<UserData>(context).currentUserId,
            userId: Provider.of<UserData>(context).currentUserId,
          ),
        ],
        onPageChanged: (int index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
          ),
        ],
        currentIndex: _selectedTabIndex,
        onTap: changeTab,
        activeColor: Colors.black,
      ),
    );
  }
}
