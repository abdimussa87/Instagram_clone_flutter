import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/services/database_service.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot> _users;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            filled: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: 15,
            ),
            border: InputBorder.none,
            hintText: "Search",
            prefixIcon: Icon(
              Icons.search,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
          ),
          onSubmitted: (input) {
            setState(() {
              if(input.isNotEmpty){
              _users = DatabaseService.searchUsers(input);
              }
            });
          },
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _users == null
            ? Center(
                child: Text("Search for users"),
              )
            : FutureBuilder(
                future: _users,
                builder: (BuildContext context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data.documents.length == 0) {
                    return Center(child: Text("No users found "));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, int index) {
                      User user = User.fromDoc(snapshot.data.documents[index]);
                      return _buildUserTile(user);
                    },
                  );
                },
              ),
      ),
    );
  }

  _buildUserTile(User user) {
    return GestureDetector(
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: user.profileImageUrl.isEmpty
              ? AssetImage("assets/images/person_placeholder.png")
              : CachedNetworkImageProvider(
                  user.profileImageUrl,
                ),
        ),
        title: Text(user.name),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProfileScreen(
                      currentUserId: Provider.of<UserData>(context).currentUserId,
                      userId: user.id,
                    )));
      },
    );
  }

  _clearSearch() {
    setState(() {
      _users = null;
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
  }
}
