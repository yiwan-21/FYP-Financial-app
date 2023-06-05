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
  String _password = '';
  String _newPassword = '';
  String _currentPassword = '';
  String _confirmPassword = '';

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
      });
    }
  }
  
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
                    const SizedBox(height: 30.0),
                    const Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
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
                    const SizedBox(height: 18.0),
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
                            if (_currentPassword == '') {
                              return null;
                            }
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            if (!RegExp(
                                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                                .hasMatch(value)) {
                              return 'Password must contain at least one uppercase letter,\none lowercase letter, one number and one special character.';
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
                            if (_currentPassword == '') {
                              return null;
                            }
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
                            _password = value;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18.0),
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
