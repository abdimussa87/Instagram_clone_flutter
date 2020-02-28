import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/activity_model.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/comment_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends StatefulWidget {
  final String currentUserId;

  const ActivityScreen({Key key, this.currentUserId}) : super(key: key);
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Activity> _activities = [];

  _setupActivitiesList() async {
    List<Activity> activities =
        await DatabaseService.getActivities(widget.currentUserId);

    if (mounted) {
      setState(() {
        _activities = activities;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Instagram",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Billabong",
            fontSize: 35,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _setupActivitiesList(),
        child: StreamBuilder(
            stream:
                DatabaseService.getActivities(widget.currentUserId).asStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    valueColor: AlwaysStoppedAnimation(Colors.black),
                  ),
                );
              }

              if (snapshot.data.length == 0) {
                return Center(
                  child: Text("No activity currently"),
                );
              }
              _activities = snapshot.data;
              return ListView.builder(
                  itemCount: _activities.length,
                  itemBuilder: (context, int index) {
                    return FutureBuilder(
                      future: DatabaseService.getUser(
                          _activities[index].fromUserId),
                      builder: (context, snapshot) {
                        Activity activity = _activities[index];
                        if (!snapshot.hasData) {
                          return SizedBox.shrink();
                        }
                        User user = snapshot.data;
                        return GestureDetector(
                          onTap: () async {
                            Post post = await DatabaseService.getSinglePost(widget.currentUserId, activity.postId);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        CommentScreen(post, post.likeCount)));
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage: user.profileImageUrl.isEmpty
                                  ? AssetImage(
                                      "assets/images/person_placeholder.png")
                                  : CachedNetworkImageProvider(
                                      user.profileImageUrl),
                            ),
                            title: activity.comment != null
                                ? Text(
                                    "${user.name} commented ${activity.comment}")
                                : Text("${user.name} liked your post"),
                            subtitle: Text(
                              DateFormat.yMd()
                                  .add_jm()
                                  .format(activity.timestamp.toDate()),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: CircleAvatar(
                              radius: 25,
                              backgroundImage: CachedNetworkImageProvider(
                                  activity.postImageUrl),
                            ),
                          ),
                        );
                      },
                    );
                  });
            }),
      ),
    );
  }
}
