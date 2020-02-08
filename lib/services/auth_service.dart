import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/models/user_data.dart';
import 'package:provider/provider.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Firestore _firestore = Firestore.instance;
  static void signInuser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print(e);
    }
  }

  static void signUpUser(BuildContext context,String name, String email, String password) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseUser user = authResult.user;
      if (user != null) {
        _firestore.collection("users").document(user.uid).setData({
          "name": name,
          "email": email,
          "profileImageUrl": "",
        });
        Provider.of<UserData>(context).currentUserId = user.uid;
      }
    } catch (e) {
      print(e);
    }
    
  }

  static void logout() {
    _auth.signOut();
  }
}
