import 'package:flutter/material.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({Key? key}) : super(key: key);

  @override
  _EditProfileFormState createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = 'test';
  String _newPassword = '';
  String _currentPassword = '';
  String _confirmPassword = '';

  bool _showPasswordFields = false;
  bool _currentPasswordError = false;
  bool _newPasswordError = false;

  void _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _currentPasswordError = true;
      });
    } else if (value != _password) {
      setState(() {
        _currentPasswordError = true;
      });
    } else {
      setState(() {
        _currentPasswordError = false;
        _showPasswordFields = true;
      });
    }
  }

  void _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _newPasswordError = true;
      });
    } else if (value != _newPassword) {
      setState(() {
        _newPasswordError = true;
      });
    } else {
      setState(() {
        _newPasswordError = false;
        _showPasswordFields = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 18, 12, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
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
                    initialValue: _email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
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
                  const SizedBox(height: 18.0),
                  if (!_showPasswordFields)
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Enter Current Password to Change Password',
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
                      obscureText: true,
                      validator: (value) {
                        if (_currentPasswordError) {
                          return 'Incorrect current password';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _validateCurrentPassword(value);
                        _currentPassword = value;
                      },
                    ),
                  if (!_showPasswordFields) const SizedBox(height: 18.0),
                  if (_showPasswordFields)
                    Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'New Password',
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
                              borderSide:
                                  BorderSide(width: 1.5, color: Colors.red),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _newPassword = value;
                          },
                        ),
                        const SizedBox(height: 18.0),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Confirm New Password',
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
                              borderSide:
                                  BorderSide(width: 1.5, color: Colors.red),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please re-enter your new password';
                            } else if (_newPasswordError) {
                              return 'new password does not match';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _validateConfirmPassword(value);
                            _confirmPassword = value;
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 18.0),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: Color.fromRGBO(0, 0, 0, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                      child: const Text('Save'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Submit form data to server or database
                          _formKey.currentState!.save();
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
