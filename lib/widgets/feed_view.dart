import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_data.dart';

import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/comment_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:provider/provider.dart';

class FeedView extends StatefulWidget {
  final String currentUserId;
  final Post post;
  final User author;

  FeedView({this.currentUserId, this.post, this.author});

  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  int _likeCount = 0;
  bool _isLiked = false;
  bool _heartAnim = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    initIsPostLiked();
  }

  initIsPostLiked() async {
    bool isLiked =
        await DatabaseService.didLikePost(widget.currentUserId, widget.post);
    setState(() {
      
    _isLiked = isLiked;
    });
  }

  void didUpdateWidget(FeedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.likeCount != widget.post.likeCount) {
      _likeCount = widget.post.likeCount;
    }
  }

  _likeUnlikePost() {
    if (_isLiked) {
      //Do unlike logic
      DatabaseService.unlikePost(widget.currentUserId, widget.post);
      setState(() {
        _isLiked = false;
        _likeCount = _likeCount - 1;
      });
    } else {
      //DO like logic
      DatabaseService.likePost(widget.currentUserId, widget.post);
      setState(() {
        _isLiked = true;
        _heartAnim = true;
        _likeCount = _likeCount + 1;
      });

      Timer(Duration(milliseconds: 350), () {
        setState(() {
          _heartAnim = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                      currentUserId: widget.currentUserId,
                      userId: widget.post.authorId))),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  backgroundImage: widget.author.profileImageUrl.isEmpty
                      ? AssetImage("assets/images/person_placeholder.png")
                      : CachedNetworkImageProvider(
                          widget.author.profileImageUrl),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  widget.author.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onDoubleTap: _likeUnlikePost,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.width,
                child: Image(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(widget.post.imageUrl),
                ),
              ),
              _heartAnim
                  ? Animator(
                      duration: Duration(milliseconds: 300),
                      tween: Tween(begin: 0.5, end: 1.4),
                      curve: Curves.elasticOut,
                      builder: (anim) => Transform.scale(
                          scale: anim.value,
                          child: Icon(
                            Icons.favorite,
                            size: 100,
                            color: Colors.red[400],
                          )),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    icon: _isLiked
                        ? Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : Icon(Icons.favorite_border),
                    iconSize: 30,
                    onPressed: _likeUnlikePost,
                  ),
                  IconButton(
                    icon: Icon(Icons.comment),
                    iconSize: 30,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CommentScreen(widget.post,_likeCount)));
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "${_likeCount.toString()} likes",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      left: 12,
                      right: 6,
                    ),
                    child: Text(widget.author.name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: Text(
                      widget.post.caption,
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
