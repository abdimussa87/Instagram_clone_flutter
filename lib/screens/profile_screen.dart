import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/following_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utitlities/constants.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'followers_screen.dart';

class ProfileScreen extends StatefulWidget {
  //Added currentUserId to be passed through because we arenot able
  //to get the currentUserId from Provider.of(context).currentUserId
  //in initState because there is no context within init state
  final String currentUserId;
  final String userId;
  ProfileScreen({this.currentUserId, this.userId});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;
  int _followers;
  int _following;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //we are creating multiple functions that are async because
    //init state can't have async in its declaration
    _setUpIsFollowingUser();
    _setUpFollowingCount();
    _setUpFollowersCount();
  }

  _setUpIsFollowingUser() async {
    bool isFollowing = await DatabaseService.isFollowingUser(
        widget.currentUserId, widget.userId);
    setState(() {
      _isFollowing = isFollowing;
    });
  }

  _setUpFollowingCount() async {
    int followingCount = await DatabaseService.numFollowing(widget.userId);
    setState(() {
      _following = followingCount;
    });
  }

  _setUpFollowersCount() async {
    int followersCount = await DatabaseService.numFollowers(widget.userId);
    setState(() {
      _followers = followersCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: FutureBuilder(
        future: usersRef.document(widget.userId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          User user = User.fromDoc(snapshot.data);
          return ListView(
            children: <Widget>[
              _upperHalf(user),
            ],
          );
        },
      ),
    );
  }

  Widget _upperHalf(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 30, 30, 0),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundImage: user.profileImageUrl.isEmpty
                    ? AssetImage("assets/images/person_placeholder.png")
                    : CachedNetworkImageProvider(user.profileImageUrl),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              "12",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "posts",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => FollowersScreen(userId: widget.userId,))),
                          child: Column(
                            children: <Widget>[
                              Text(
                                _followers.toString(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Followers",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => FollowingScreen(
                                      userId: widget.userId,
                                    )));
                          },
                          child: Column(
                            children: <Widget>[
                              Text(
                                _following.toString(),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Following",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Provider.of<UserData>(context).currentUserId ==
                            widget.userId
                        ? Container(
                            padding: EdgeInsets.only(top: 18),
                            width: 200,
                            child: FlatButton(
                              color: Colors.blue,
                              textColor: Colors.white,
                              child: Text(
                                "EditProfile",
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(
                                    user: user,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.only(top: 18),
                            width: 200,
                            child: FlatButton(
                              color: _isFollowing ? Colors.grey : Colors.blue,
                              textColor:
                                  _isFollowing ? Colors.black : Colors.white,
                              child: Text(
                                _isFollowing ? "Unfollow" : "Follow",
                              ),
                              onPressed: _followUnfollowUser,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30.0, bottom: 10),
          child: Text(
            user.name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 80,
          padding: const EdgeInsets.only(left: 30),
          child: Text(
            user.bio,
            style: TextStyle(fontSize: 15),
          ),
        ),
        Divider(),
      ],
    );
  }

  _followUnfollowUser() {
    if (_isFollowing) {
      _unfollowUser();
    } else {
      _followUser();
    }
  }

  _followUser() {
    DatabaseService.followUser(widget.currentUserId, widget.userId);
    setState(() {
      _followers++;
      _isFollowing = true;
    });
  }

  _unfollowUser() {
    DatabaseService.unfollowUser(widget.currentUserId, widget.userId);
    setState(() {
      _followers--;
      _isFollowing = false;
    });
  }
}
