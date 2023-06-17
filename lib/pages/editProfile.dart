import 'package:financial_app/firebaseInstance.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/userProvider.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({super.key});

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    _name = userProvider.name;
    _email = userProvider.email;
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: Container(
          alignment: Constants.isMobile(context)
              ? Alignment.topCenter
              : Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              decoration: Constants.isMobile(context)
                  ? null
                  : BoxDecoration(
                      border: Border.all(color: Colors.black45, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38.withOpacity(0.2),
                          offset: const Offset(3, 5),
                          blurRadius: 5.0,
                        )
                      ],
                    ),
              width: Constants.isMobile(context) ? null : 500,
              padding: Constants.isMobile(context)
                  ? null
                  : const EdgeInsets.fromLTRB(24, 40, 24, 24),
              margin: Constants.isMobile(context)
                  ? const EdgeInsets.fromLTRB(12, 24, 12, 0)
                  : null,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 18.0),
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Colors.black),
                        fillColor: Colors.white,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1.5, color: Colors.red),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _name = value;
                        });
                      },
                    ),
                    const SizedBox(height: 18.0),
                    TextFormField(
                      enabled: false,
                      initialValue: _email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.black),
                        fillColor: Color.fromARGB(255, 233, 230, 230),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value!;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      child: const Text('Reset Password'),
                      onPressed: () async {
                        await FirebaseInstance.auth.sendPasswordResetEmail(email: _email)
                          .whenComplete(() {
                            SnackBar snackBar = const SnackBar(content: Text('Password reset email sent'));
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          });
                      },
                    ),
                    const SizedBox(height: 60.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          child: const Text('Save'),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Submit form data to server or database
                              _formKey.currentState!.save();
                              userProvider.updateName(_name);
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
