import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:instagram/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  static final String id = "SignUp";
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _email, _password, _name;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _signUp() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        AuthService.signUpUser(_scaffoldKey,context, _name, _email, _password);
        
      } catch (e) {
        final snackbar = SnackBar(
          content: Text("Invalid credentials"),
        );
        _scaffoldKey.currentState.showSnackBar(snackbar);
      }
    }
  }

  _backToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Instagram",
                  style: TextStyle(fontFamily: 'Billabong', fontSize: 50),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: TextFormField(
                          validator: (input) => input.trim().isEmpty
                              ? "Please enter a valid name"
                              : null,
                          onSaved: (value) => _name = value,
                          decoration: InputDecoration(
                            labelText: "Name",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: TextFormField(
                          validator: (input) => !input.contains("@")
                              ? "Please enter a valid email"
                              : null,
                          onSaved: (value) => _email = value.trim(),
                          decoration: InputDecoration(
                            labelText: "Email",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: TextFormField(
                          validator: (input) => input.trim().length < 6
                              ? "Password must be at least 6 characters"
                              : null,
                          onSaved: (value) => _password = value,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 250,
                        child: FlatButton(
                          onPressed: _signUp,
                          color: Colors.blue,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "SignUp",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 250,
                        child: FlatButton(
                          onPressed: _backToLogin,
                          color: Colors.blue,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Back To Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
