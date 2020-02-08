import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  EditProfileScreen({this.user});
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File _profileImageFile;
  String _name = "";
  String _bio = "";
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _bio = widget.user.bio;
  }

  ImageProvider _displayProfileImage() {
    //No new profile image
    if (_profileImageFile == null) {
      //No existing profile image
      if (widget.user.profileImageUrl.isEmpty) {
        return AssetImage("assets/images/person_placeholder.png");
      } else {
        //user profile already exists
        return CachedNetworkImageProvider(widget.user.profileImageUrl);
      }
    } else {
      //New profile image
      return FileImage(_profileImageFile);
    }
  }

  _handleImageFromGallery() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _profileImageFile = imageFile;
      });
    }
  }

  _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      //Update user in the database
      String _profileImageUrl = "";
      setState(() {
        _isLoading = true;
      });

      if (_profileImageFile == null) {
        _profileImageUrl = widget.user.profileImageUrl;
      } else {
        _profileImageUrl = await StorageService.uploadUserProfileImage(
          widget.user.profileImageUrl,
          _profileImageFile,
        );
      }
      User user = User(
          id: widget.user.id,
          name: _name,
          bio: _bio,
          profileImageUrl: _profileImageUrl);
      DatabaseService.updateUser(user);

      Navigator.pop(context);
    }
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(children: <Widget>[
          _isLoading
              ? LinearProgressIndicator(
                  backgroundColor: Colors.blue[200],
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                )
              : SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _displayProfileImage(),
                  ),
                  FlatButton(
                    onPressed: _handleImageFromGallery,
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
                  SizedBox(
                    height: 20,
                  ),
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
        ]),
      ),
    );
  }
}
