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

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate()) {
      await signup();
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
                    child: const Text('Register'),
                    onPressed: () async => await onSubmit(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
