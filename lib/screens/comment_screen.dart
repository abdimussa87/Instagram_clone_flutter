import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/comment_model.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utitlities/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentScreen extends StatefulWidget {
  final Post post;
  final int likeCount;
  CommentScreen(this.post, this.likeCount);
  @override
  _CommentScreenState createState() => _CommentScreenState();
}



class _CommentScreenState extends State<CommentScreen> {
  TextEditingController _commentController = new TextEditingController();
  bool _isCommenting = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Comments",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.likeCount.toString() + " likes",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          StreamBuilder(
            stream: commentsRef
                .document(widget.post.id)
                .collection("postComments")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, int index) {
                      Comment comment =
                          Comment.fromDoc(snapshot.data.documents[index]);
                      return _buildComment(comment);
                    },
                  ),
                );
              }
            },
          ),
          Divider(
            height: 1.0,
          ),
          _buildTextField(),
        ],
      ),
    );
  }

  _buildComment(Comment comment) {
    return FutureBuilder(
      future: DatabaseService.getUser(comment.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox.shrink(),
          );
        } else {
          User user = snapshot.data;
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: user.profileImageUrl.isEmpty
                  ? AssetImage("assets/images/person_placeholder.png")
                  : CachedNetworkImageProvider(user.profileImageUrl),
            ),
            title: Text(user.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(comment.comment),
                SizedBox(
                  height: 6,
                ),
                Text(
                  DateFormat.yMd().add_jm().format(comment.timestamp.toDate()),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  _buildTextField() {
    return Form(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(hintText: "Comment"),
              onChanged: (input) {
                setState(() {
                  _isCommenting = input.trim().length > 0;
                });
              },
            ),
          ),
          IconButton(
              icon: Icon(Icons.send),
              color: _isCommenting
                  ? Theme.of(context).accentColor
                  : Theme.of(context).disabledColor,
              onPressed: _sendComment)
        ],
      ),
    );
  }

  _sendComment() {
    if (_commentController.text.trim().isNotEmpty) {
      Comment comment = Comment(
          comment: _commentController.text,
          userId: Provider.of<UserData>(context).currentUserId);
      DatabaseService.postComment(widget.post, comment);
     
      setState(() {
        _isCommenting=false;
      });
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }
}
