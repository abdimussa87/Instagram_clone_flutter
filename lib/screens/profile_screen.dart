import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/comment_screen.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/following_screen.dart';
import 'package:instagram/services/auth_service.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utitlities/constants.dart';
import 'package:instagram/widgets/feed_view.dart';
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
  List<Post> _postsList = [];
  int _toggleDisplayPosts = 0; // 0 - grid, 1- column

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //we are creating multiple functions that are async because
    //init state can't have async in its declaration
    _setUpIsFollowingUser();
    _setUpFollowingCount();
    _setUpFollowersCount();
    _setupPosts();
  }

  _setupPosts() async {
    List<Post> postsList = await DatabaseService.getUserPost(widget.userId);
    if (mounted) {
      setState(() {
        _postsList = postsList;
      });
    }
  }

  _setUpIsFollowingUser() async {
    bool isFollowing = await DatabaseService.isFollowingUser(
        widget.currentUserId, widget.userId);
    if (mounted) {
      setState(() {
        _isFollowing = isFollowing;
      });
    }
  }

  _setUpFollowingCount() async {
    int followingCount = await DatabaseService.numFollowing(widget.userId);
    if (mounted) {
      setState(() {
        _following = followingCount;
      });
    }
  }

  _setUpFollowersCount() async {
    int followersCount = await DatabaseService.numFollowers(widget.userId);
    if (mounted) {
      setState(() {
        _followers = followersCount;
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
        actions: <Widget>[
          widget.currentUserId == widget.userId
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: AuthService.logout,
                )
              : SizedBox.shrink()
        ],
      ),
      body: FutureBuilder(
        future: usersRef.document(widget.userId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.black),
                strokeWidth: 1,
              ),
            );
          }
          User user = User.fromDoc(snapshot.data);
          return ListView(
            children: <Widget>[
              _upperHalf(user),
              _buildToggleButtons(),
              _postsList.length > 0 ? _lowerHalf(user) : SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }

  Row _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          iconSize: 30,
          color: _toggleDisplayPosts == 0 ? Colors.blueAccent : Colors.grey,
          onPressed: () {
            setState(() {
              _toggleDisplayPosts = 0;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.list),
          iconSize: 30,
          color: _toggleDisplayPosts == 1 ? Colors.blueAccent : Colors.grey,
          onPressed: () {
            setState(() {
              _toggleDisplayPosts = 1;
            });
          },
        ),
      ],
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
                              _postsList.length.toString(),
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
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FollowersScreen(
                                        userId: widget.userId,
                                      ))),
                          child: Column(
                            children: <Widget>[
                              Text(
                                _followers == null
                                    ? "..."
                                    : _followers.toString(),
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

  Widget _lowerHalf(User author) {
    if (_toggleDisplayPosts == 1) {
      List<FeedView> posts = [];
      _postsList.forEach((post) => posts.add(FeedView(
            author: author,
            post: post,
            currentUserId: widget.currentUserId,
          )));
      return ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: posts,
      );
    } else {
      List<GridTile> tiles = [];
      _postsList.forEach((post) => tiles.add(_buildGridTile(post)));

      return GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        childAspectRatio: 1.0,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisSpacing: 2,
        children: tiles,
      );
    }
  }

  _buildGridTile(Post post) {
    return GridTile(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommentScreen(post, post.likeCount),
          ),
        ),
        child: Image(
          image: CachedNetworkImageProvider(post.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
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
