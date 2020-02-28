import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/services/auth_service.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/widgets/feed_view.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  final String currentUserId;
  FeedScreen({this.currentUserId});
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> _postsList = [];

  @override
  void initState() {
    super.initState();
    _setupPostsList();
  }

  _setupPostsList() async {
    List<Post> postsList =
        await DatabaseService.getUserFeed(widget.currentUserId);
    if (mounted) {
      setState(() {
        _postsList = postsList;
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
      body: _postsList.length == 0
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.black),
                strokeWidth: 1,
              ),
            )
          : RefreshIndicator(
              onRefresh: () => _setupPostsList(),
              child: ListView.builder(
                itemCount: _postsList.length,
                itemBuilder: (BuildContext context, int index) {
                  Post post = _postsList[index];
                  return FutureBuilder(
                    future: DatabaseService.getUser(post.authorId),
                    builder: (context, snapshot) {
                      User author = snapshot.data;
                      if (!snapshot.hasData) {
                        return SizedBox.shrink();
                      }
                      return FeedView(
                          currentUserId: widget.currentUserId,
                          author: author,
                          post: post);
                    },
                  );
                },
              ),
            ),
    );
  }

//   _buildFeed(User author, Post post) {
//     return Column(
//       children: <Widget>[
//         GestureDetector(
//           onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => ProfileScreen(
//                       currentUserId:
//                           Provider.of<UserData>(context).currentUserId,
//                       userId: post.authorId))),
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: Row(
//               children: <Widget>[
//                 CircleAvatar(
//                   radius: 25,
//                   backgroundColor: Colors.grey,
//                   backgroundImage: author.profileImageUrl.isEmpty
//                       ? AssetImage("assets/images/person_placeholder.png")
//                       : CachedNetworkImageProvider(author.profileImageUrl),
//                 ),
//                 SizedBox(
//                   width: 8,
//                 ),
//                 Text(
//                   author.name,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Container(
//           height: MediaQuery.of(context).size.width,
//           child: Image(
//             fit: BoxFit.cover,
//             image: CachedNetworkImageProvider(post.imageUrl),
//           ),
//         ),
//         SizedBox(height: 5),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Row(
//                 children: <Widget>[
//                   IconButton(
//                     icon: Icon(Icons.favorite_border),
//                     iconSize: 30,
//                     onPressed: () {},
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.comment),
//                     iconSize: 30,
//                     onPressed: () {},
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 child: Text(
//                   "0 likes",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//               SizedBox(
//                 height: 4,
//               ),
//               Row(
//                 children: <Widget>[
//                   Container(
//                     margin: EdgeInsets.only(
//                       left: 12,
//                       right: 6,
//                     ),
//                     child: Text(author.name,
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                   ),
//                   Expanded(
//                     child: Text(
//                       post.caption,
//                       style: TextStyle(fontSize: 16),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
}

// Center(
//   child: GestureDetector(
//     onTap: () {
//       AuthService.logout();
//     },
//     child: Text("Logout"),
//   ),
// )
