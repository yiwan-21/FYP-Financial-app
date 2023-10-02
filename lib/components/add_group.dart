import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/constant.dart';
import '../constants/message_constant.dart';
import '../firebase_instance.dart';
import '../services/split_money_service.dart';

class AddGroup extends StatefulWidget {
  const AddGroup({super.key});

  @override
  State<AddGroup> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  final _formKey = GlobalKey<FormState>();
  String _groupName = '';

  Future<void> _addGroup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      await SplitMoneyService.addGroup(_groupName).then((_) {
        Navigator.pop(context);
      });
    }
  }

  void _groupImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      final pickedImageFile = File(pickedImage.path);
      final storageRef = FirebaseInstance.storage
          .ref('profile/${FirebaseInstance.auth.currentUser!.uid}');
      await storageRef.putFile(pickedImageFile);
    }
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Group'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: Constant.isMobile(context) ? null : 500,
          child: SingleChildScrollView(
            child: Flex(
              direction: Constant.isMobile(context) ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    iconSize: 60,
                    icon: const Icon(
                      Icons.add_a_photo,
                    ),
                    onPressed: _groupImage,
                  ),
                ),
                const SizedBox(width: 20, height: 20),
                Flexible(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
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
                        return ValidatorMessage.emptyGroupName;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _groupName = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(100, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          onPressed: _addGroup,
          child: const Text('Create'),
        ),
        if (!Constant.isMobile(context)) const SizedBox(width: 12),
        if (!Constant.isMobile(context))
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
          ),
      ],
    );
  }
}
