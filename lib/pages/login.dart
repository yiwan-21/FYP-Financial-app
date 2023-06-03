import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebaseInstance.dart';
import '../constants.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _resetformKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _emailReset = '';

  void login() async {
    try {
      await FirebaseInstance.auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      ).whenComplete(() => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false));
    } on FirebaseAuthException catch (e) {
      String msg = e.message!;
      if (e.code == 'user-not-found') {
        msg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        msg = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email address.';
      }
      SnackBar snackBar = SnackBar(content: Text(msg));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Container(
            width: Constants.isMobile(context) ? null : 500,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _email = value.trim();
                      });
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32.0),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Reset Password'),
                            content: Container(
                              width: Constants.isMobile(context) ? null : 500,
                              child: Form(
                                key: _resetformKey,
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _emailReset = value.trim();
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Confirm'),
                                onPressed: () async {
                                  if (_resetformKey.currentState!.validate()) {
                                    try {                                 
                                      await FirebaseInstance.auth.sendPasswordResetEmail(email: _emailReset)
                                        .whenComplete(() {
                                          Navigator.pop(context);
                                          SnackBar snackBar = const SnackBar(content: Text('Password reset email sent'));
                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                        });
                                    } on FirebaseAuthException catch (e) {
                                      String msg = e.message!;
                                      if (e.code == 'user-not-found') {
                                        msg = 'No user found for that email.';
                                      } else if (e.code == 'invalid-email') {
                                        msg = 'Invalid email address.';
                                      }
                                      Navigator.pop(context);
                                      SnackBar snackBar = SnackBar(content: Text(msg));
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    }
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ButtonStyle(
                      overlayColor: MaterialStateColor.resolveWith(
                          (states) => const Color.fromARGB(255, 231, 227, 225)),
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  Hero(
                    tag: "login-button",
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(180, 40)),
                      child: const Text('Login'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          login();
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
