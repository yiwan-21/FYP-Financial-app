import 'package:financial_app/utils/gallery_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/message_constant.dart';
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
  var pickedImage = null;
  bool setGroupImage = false;

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

      await SplitMoneyService.addGroup(_groupName).then((docRef) async {
        if (setGroupImage && pickedImage != null) {
          await SplitMoneyService.setGroupImage(pickedImage, docRef.id);
        }
        if (mounted && context.mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> _editGroup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      SplitMoneyProvider splitMoneyProvider = Provider.of<SplitMoneyProvider>(context, listen: false);
      splitMoneyProvider.updateName(_groupName);
      if (setGroupImage && pickedImage != null) {
        await SplitMoneyService.setGroupImage(pickedImage, splitMoneyProvider.id!).then((String url) {
          splitMoneyProvider.setImage(url);
        });
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _setGroupImage() async {
    pickedImage = await pickFromGallery();
    if (pickedImage != null) {
      setState(() {
        setGroupImage = true;
      });
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
                widget.isEditing && !setGroupImage
                    ? Consumer<SplitMoneyProvider>(
                        builder: (context, splitMoneyProvider, _) {
                          if (splitMoneyProvider.image != null) {
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: _setGroupImage,
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage:
                                        NetworkImage(splitMoneyProvider.image!),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Text('Click the image to edit the Group Photo', style: TextStyle(fontSize: 12, color: Colors.grey[600]))
                              ],
                            );
                          } else {
                            return Container(
                              margin: kIsWeb? const EdgeInsets.symmetric(horizontal: 30): const EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Material(
                                child: InkWell(
                                  onTap: _setGroupImage,
                                  child: const Icon(
                                    Icons.add_a_photo,
                                    size: 60,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      )
                    : setGroupImage
                        ? kIsWeb
                            ? CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.transparent,
                                backgroundImage: MemoryImage(pickedImage),
                              )
                            : CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.transparent,
                                backgroundImage: FileImage(pickedImage),
                              )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Material(
                              child: InkWell(
                                onTap: _setGroupImage,
                                child: const Icon(
                                  Icons.add_a_photo,
                                  size: 60,
                                ),
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
