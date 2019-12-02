import 'package:flutter/material.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/services/database_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  EditProfileScreen({this.user});
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String _name = "";
  String _bio = "";
  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _bio = widget.user.bio;
  }

  _submit(){
    if(_formKey.currentState.validate())
    _formKey.currentState.save();
    //Update user in the database
    String _profileImageUrl = "";
    User user = User(id: widget.user.id,name: _name,bio:_bio,profileImageUrl: _profileImageUrl);
    DatabaseService.updateUser(user);

    Navigator.pop(context);
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/images/game.png"),
                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Text(
                      "Change Profile Image",
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                  ),
                  TextFormField(
                    initialValue: _name,
                    decoration: InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      labelText: "Name",
                    ),
                    validator: (input) => input.trim().length < 1
                        ? "Please enter a valid name"
                        : null,
                    onSaved: (input) => _name = input,
                  ),
                  TextFormField(
                    initialValue: _bio,
                    decoration: InputDecoration(
                       icon: Icon(
                        Icons.book,
                        color: Colors.blue,
                      ),
                      labelText: "Bio",
                    ),
                    validator: (input) => input.trim().length > 150
                        ? "Bio can't be greater than 150 characters"
                        : null,
                    onSaved: (input) => _bio = input,
                  ),
                  SizedBox(height: 20,),
                  Container(
                      width: 100,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                        ),
                        onPressed: _submit,
                        color: Colors.blue,
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
