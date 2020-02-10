import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:provider/provider.dart';

class FollowersScreen extends StatefulWidget {
  final String userId;
  FollowersScreen({@required this.userId});
  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  Future<QuerySnapshot> userFollowers;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupUserFollowers();
  }

  _setupUserFollowers() {
    setState(() {
      userFollowers = DatabaseService.userFollowers(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Followers",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: userFollowers,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data.documents.length == 0) {
            return Center(
              child: Text("This user has no followers"),
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