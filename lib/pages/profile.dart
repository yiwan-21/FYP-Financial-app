import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/user_service.dart';
import '../utils/gallery_utils.dart';
import '../constants/route_name.dart';
import '../providers/user_provider.dart';
import '../services/auth.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _loading = false;

  Future<void> signout() async {
    setState(() {
      _loading = true;
    });
    await Auth.signout(context).then((_) {
      setState(() {
        _loading = false;
      });
    });
  }

  // Pick from gallery
  void galleryImage() async {
    try{
      var pickedImage = await pickFromGallery();
      if (pickedImage != null) {
        await UserService.setProfileImage(pickedImage).then((String url) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.updateProfileImage(url);
          Navigator.pop(context);
        });
      }
    } catch (e) {
      debugPrint("Error in galleryImage: $e");
    }
  }

  // Pick from camera
  void cameraImage() async {
    try{
      var pickedImage = await pickFromCamera();
      if (pickedImage != null) {
        await UserService.setProfileImage(pickedImage).then((String url) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          userProvider.updateProfileImage(url);
            Navigator.pop(context);
        });
      }
    } catch (e) {
      debugPrint("Error in cameraImage: $e");
    }
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
              Consumer<UserProvider>(builder: (context, userProvider, _) {
                String image = userProvider.profileImage;
                if (image.isNotEmpty) {
                  return CircleAvatar(
                    radius: 70.0,
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(image),
                  );
                } else {
                  return const CircleAvatar(
                    radius: 70.0,
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: 140.0,
                    ),
                  );
                }
              }),
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
                                if (!kIsWeb)
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
                                  onPressed: galleryImage,
                                  label: const Text(
                                    kIsWeb ? 'Picture' : 'Gallery',
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
                Navigator.pushNamed(context, RouteName.editProfile);
              },
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              return Text(
                userProvider.name,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 30),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              return Text(
                userProvider.email,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 100),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(180, 40)),
              onPressed: _loading ? null : () async => await signout(),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }
}
