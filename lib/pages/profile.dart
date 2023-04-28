import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  File? profileImage;
  final Function(File) onImageChange;

  Profile({required this.profileImage, required this.onImageChange, super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _name = 'shock eh';
  final String _email = 'financialAxpp@example.com';

// Pick from gallery
  void gallaryImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      final pickedImageFile = File(pickedImage.path);
      widget.onImageChange(pickedImageFile);
    }
    Navigator.pop(context);
  }

// Pick from camera
  void cameraImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedImage != null) {
      final pickedImageFile = File(pickedImage.path);
      widget.onImageChange(pickedImageFile);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 2,
      child: ListView(
        children: [
          const SizedBox(
            height: 80,
            child: DrawerHeader(
              child: Text(
                "Profile",
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 70.0,
                backgroundImage: widget.profileImage == null
                    ? null
                    : FileImage(widget.profileImage!),
              ),
              Positioned(
                bottom: 0.0,
                right: 75,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            'Choose Option',
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton.icon(
                                  onPressed: cameraImage,
                                  label: const Text(
                                    'Camera',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.add_a_photo,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: gallaryImage,
                                  label: const Text(
                                    'Gallery',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                  icon: const Icon(Icons.image),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pink,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38.withOpacity(0.2),
                          offset:
                              const Offset(2, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 45),
          Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile', arguments: {
                    'name': _name,
                    'email': _email,
                  }).then((name) => {
                        if (name != null && name is String)
                          {
                            setState(() {
                              _name = name;
                            })
                          }
                      });
                },
              )),
          Text(
            _name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Text(
            _email,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
