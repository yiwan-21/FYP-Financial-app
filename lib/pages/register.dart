import 'package:flutter/material.dart';

import '../constants/constant.dart';
import '../constants/message_constant.dart';
import '../services/auth.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  bool _loading = false;

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate() && !_loading) {
      setState(() {
        _loading = true;
      });
      await signup().then((_) {
        setState(() {
          _loading = false;
        });
      });
    }
  }

  Future<void> signup() async {
    await Auth.signup(_email, _password, _name, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            if (_loading)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black38,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            Center(
              child: Container(
                width: Constant.isMobile(context) ? null : 500,
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                            errorMaxLines: 3,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _name = value.trim();
                            });
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return ValidatorMessage.emptyUsername;
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) async => await onSubmit(),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                            errorMaxLines: 3,
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
                            errorMaxLines: 3,
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
                            if (value.length < 6) {
                              return ValidatorMessage.invalidPassword;
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) async => await onSubmit(),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                            errorMaxLines: 3,
                          ),
                          validator: (value) {
                            if (value != _password) {
                              return ValidatorMessage.passwordsNotMatch;
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) async => await onSubmit(),
                        ),
                        const SizedBox(height: 32.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(180, 40)),
                          onPressed: _loading ? null : () async => await onSubmit(),
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
