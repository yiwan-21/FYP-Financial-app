import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/constant.dart';
import '../constants/message_constant.dart';
import '../services/auth.dart';

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

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate()) {
      await login();
    }
  }

  Future<void> login() async {
    await Auth.login(_email, _password, context);
  }

  void resetPassword() async {
    if (_resetformKey.currentState!.validate()) {
      try {
        await Auth.resetPassword(_emailReset).then((_) {
          Navigator.pop(context);
          SnackBar snackBar = SnackBar(content: Text(SuccessMessage.resetPassword));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      } on FirebaseAuthException catch (e) {
        String msg = e.message!;
        if (e.code == AuthExceptionMessage.userNotFound.getCode) {
          msg = AuthExceptionMessage.userNotFound.getMessage;
        } else if (e.code == AuthExceptionMessage.invalidEmail.getCode) {
          msg = AuthExceptionMessage.invalidEmail.getMessage;
        }
        if (mounted && context.mounted) {
          Navigator.pop(context);
          SnackBar snackBar = SnackBar(content: Text(msg));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
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
            width: Constant.isMobile(context) ? null : 500,
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
                        return ValidatorMessage.emptyEmail;
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) async => await onSubmit(),
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
                        return ValidatorMessage.emptyPassword;
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) async => await onSubmit(),
                  ),
                  const SizedBox(height: 32.0),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Reset Password'),
                            content: SizedBox(
                              width: Constant.isMobile(context) ? null : 500,
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
                                      return ValidatorMessage.emptyEmail;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: resetPassword,
                                child: const Text('Confirm'),
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
                      onPressed: () async => await onSubmit(),
                      child: const Text('Login'),
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
