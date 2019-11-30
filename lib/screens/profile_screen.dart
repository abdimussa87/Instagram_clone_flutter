import 'package:flutter/material.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/utitlities/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  ProfileScreen({this.userId});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                backgroundImage: AssetImage("assets/images/game.png"),
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
                        Column(
                          children: <Widget>[
                            Text(
                              "386",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Followers",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              "345",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Following",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 18),
                      width: 200,
                      child: FlatButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Text(
                          "EditProfile",
                        ),
                        onPressed: () => _showEditProfileDialog(context, user),
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

  _showEditProfileDialog(BuildContext context, User user) {
    final _formKey = GlobalKey<FormState>();
    String _name;
    String _bio;
    String _profileImageUrl = '';
    return Alert(
        context: context,
        title: "Edit Profile",
        style: AlertStyle(isCloseButton: false),
        content: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    initialValue: user.name,
                    decoration: InputDecoration(
                      labelText: "Name",
                    ),
                    validator: (input) =>
                        input.trim().length < 1 ? "Please enter a name" : null,
                    onSaved: (input) => _name = input,
                  ),
                  TextFormField(
                    initialValue: user.bio,
                    decoration: InputDecoration(
                      labelText: "Bio",
                    ),
                    validator: (input) => input.trim().length > 150
                        ? "Bio's can't be greater than 150 characters"
                        : null,
                    onSaved: (input) => _bio = input,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: (){},
                    child: Text(
                      "Change Profile Picture",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            radius: BorderRadius.circular(25),
            height: 35,
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                User user = User(
                    name: _name,
                    bio: _bio,
                    profileImageUrl: _profileImageUrl,
                    id: widget.userId);
                DatabaseService.updateUser(user);
                Navigator.pop(context);
              }
            },
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            radius: BorderRadius.circular(25),
            height: 35,
            color: Colors.red,
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}
