import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/message_constant.dart';
import '../firebase_instance.dart';
import '../providers/split_money_provider.dart';
import '../services/split_money_service.dart';

class ManageGroup extends StatefulWidget {
  final bool isEditing;
  const ManageGroup(this.isEditing, {super.key});

  @override
  State<ManageGroup> createState() => _ManageGroupState();
}

class _ManageGroupState extends State<ManageGroup> {
  final _formKey = GlobalKey<FormState>();

  String _groupName = '';

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _groupName = Provider.of<SplitMoneyProvider>(context, listen: false).name ?? '';
    }
  }

  Future<void> _addGroup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await SplitMoneyService.addGroup(_groupName).then((_) {
        Navigator.pop(context);
      });
    }
  }

  void _editGroup() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Provider.of<SplitMoneyProvider>(context, listen: false).updateName(_groupName);
      Navigator.pop(context);
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
      title: widget.isEditing ? const Text('Edit Group') : const Text('Create Group'),
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
                    initialValue: widget.isEditing ? _groupName : '',
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      labelStyle: TextStyle(color: Colors.black),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
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
          onPressed: widget.isEditing ? _editGroup : _addGroup,
          child: const Text('Save'),
        ),
        if (!Constant.isMobile(context)) 
          const SizedBox(width: 12),
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
