import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/message_constant.dart';
import '../firebase_instance.dart';
import '../providers/split_money_provider.dart';

class EditGroup extends StatefulWidget {
  const EditGroup({super.key});

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  String _groupName = '';

  void _editGroup() {
    Provider.of<SplitMoneyProvider>(context, listen: false).updateName(_groupName);
    Navigator.pop(context);
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
      title: const Text('Edit Group'),
      content: SizedBox(
        width: Constant.isMobile(context) ? null : 500,
        child: Flex(
          direction: Constant.isMobile(context) ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                child: InkWell(
                  onTap: _groupImage,
                  child: const Icon(
                    Icons.add_a_photo,
                    size: 100,
                  ), // to be changed to read the group image from firebase
                ),
              ),
            ),
            const SizedBox(width: 20, height: 20),
            Flexible(
              child: TextFormField(
                initialValue: _groupName,
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
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(100, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          onPressed: _editGroup,
          child: const Text('Save'),
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
