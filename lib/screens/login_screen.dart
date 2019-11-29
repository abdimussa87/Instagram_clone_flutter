import 'package:flutter/material.dart';
import 'package:instagram/screens/signup_screen.dart';
import 'package:instagram/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  static String id = "LoginScreen";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email, _password;
  _login() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      AuthService.signInuser(_email, _password);
      
    }
  }

  _signUp() {
    Navigator.pushNamed(context, SignUpScreen.id);
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
                        validator: (input) => !input.contains("@")
                            ? "Please enter a valid email"
                            : null,
                        onSaved: (value) => _email = value,
                        decoration: InputDecoration(
                          labelText: "Email",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: TextFormField(
                        validator: (input) => input.length < 6
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
                        onPressed: _login,
                        color: Colors.blue,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Login",
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
