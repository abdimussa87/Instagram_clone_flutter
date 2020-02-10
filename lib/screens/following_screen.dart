import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:provider/provider.dart';

class FollowingScreen extends StatefulWidget {
  static final String id = "FollowingScreen";
  final String userId;
  FollowingScreen({this.userId});
  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  Future<QuerySnapshot> followingUsers;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupFollowingUsers();
  }

  _setupFollowingUsers() {
    setState(() {
      followingUsers = DatabaseService.followingUsers(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Following",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: followingUsers,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.documents.length == 0) {
            return Center(
              child: Text("This user doesn't follow anyone"),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              User user = User.fromDoc(snapshot.data.documents[index]);
              return _buildUserTile(user);
            },
          );
        },
      ),
    );
  }

  _buildUserTile(User user) {
    return GestureDetector(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.profileImageUrl.isEmpty
              ? AssetImage("assets/images/person_placeholder.png")
              : CachedNetworkImageProvider(user.profileImageUrl),
        ),
        title: Text(user.name),
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileScreen(
                currentUserId: Provider.of<UserData>(context).currentUserId,
                userId: user.id,
              ))),
    );
  }
}
