import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_data.dart';
import 'package:instagram/services/database_service.dart';
import 'package:instagram/services/storage_service.dart';
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File _image;
  bool _isLoading = false;
  TextEditingController _captionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Create Post",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addPost,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          children: <Widget>[
            _isLoading
                ? LinearProgressIndicator(
                    backgroundColor: Colors.blue[200],
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  )
                : SizedBox.shrink(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              color: Colors.grey[300],
              child: _image == null
                  ? IconButton(
                      iconSize: 150,
                      color: Colors.white70,
                      icon: Icon(Icons.add_a_photo),
                      onPressed: _showSelectImageDialog,
                    )
                  : Image(
                      image: FileImage(_image),
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  labelText: "Caption",
                  labelStyle: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showSelectImageDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidDialog();
  }

  _iosBottomSheet() {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text("Add Photo"),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text("Take Photo"),
                onPressed: () => _handleImage(ImageSource.camera),
              ),
              CupertinoActionSheetAction(
                child: Text("Choose from gallery"),
                onPressed: () => _handleImage(ImageSource.gallery),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
          );
        });
  }

  _androidDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: <Widget>[
          SimpleDialogOption(
            child: Text("Take a photo"),
            onPressed: () => _handleImage(ImageSource.camera),
          ),
          SimpleDialogOption(
            child: Text("Choose from gallery"),
            onPressed: () => _handleImage(ImageSource.gallery),
          ),
          SimpleDialogOption(
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  _handleImage(ImageSource source) async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: source);
    if (imageFile != null) {
      setState(() {
        _image = imageFile;
      });
    }
  }

  _addPost() async {
    if (!_isLoading && _image != null && _captionController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      //Create the post
      String uploadedImageUrl = await StorageService.uploadPost(_image);
      Post post = Post(
        imageUrl: uploadedImageUrl,
        caption: _captionController.text,
        timestamp: Timestamp.now(),
        authorId: Provider.of<UserData>(context).currentUserId,
        likes: {},
      );

      DatabaseService.createPost(post);
      //Reset the data found in the variables
      _captionController.clear();
      setState(() {
        _image = null;
        _isLoading = false;
      });
    }
  }
}
