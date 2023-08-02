import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/message_constant.dart';
import '../components/alert_confirm_action.dart';
import '../firebase_instance.dart';
import '../components/edit_group.dart';
import '../models/group_user.dart';
import '../models/split_group.dart';
import '../providers/split_money_provider.dart';
import '../services/split_money_service.dart';

class GroupSettings extends StatefulWidget {
  final SplitGroup splitGroup;
  const GroupSettings({required this.splitGroup, super.key});

  @override
  State<GroupSettings> createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {
  final _formKey = GlobalKey<FormState>();
  bool _isOwner = false;
  String _targetEmail = '';
  bool _isAdding = false;
  bool _isRemoving = false;
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    SplitMoneyProvider splitMoneyProvider =
        Provider.of<SplitMoneyProvider>(context, listen: false);
    setState(() {
      _isOwner = _checkIsOwner(
          splitMoneyProvider.ownerId, FirebaseInstance.auth.currentUser!.uid);
    });
  }

  void _openEditGroup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const EditGroup();
      },
    );
  }

  void _toggleRemoveMember() {
    setState(() {
      _isRemoving = !_isRemoving;
    });
  }

  void _addMember() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _isAddingMember(false);

      GroupUser? member = await SplitMoneyService.hasAccount(_targetEmail);
      if (context.mounted) {
        if (member != null) {
          Provider.of<SplitMoneyProvider>(context, listen: false)
              .addMember(member);
        } else {
          SnackBar snackBar =
              SnackBar(content: Text(ExceptionMessage.noSuchUser));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    }
  }

  void _isAddingMember(bool value) {
    setState(() {
      _isAdding = value;
    });
  }

  bool _checkIsOwner(String? ownerId, String memberId) {
    return ownerId != null && ownerId == 'users/$memberId';
  }

  void _removeMember(GroupUser member) async {
    await Provider.of<SplitMoneyProvider>(context, listen: false)
        .removeMember(member);
    if (context.mounted && _isLeaving) {
      // quit to SplitMoneyGroup page
      Navigator.of(context).pop();
      // quit to Group list page
      Navigator.of(context).pop();
    }
  }

  void _removeMemberConfirmation(GroupUser member) {
    _isLeaving
        ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertConfirmAction(
                title: 'Leave Group',
                content:
                    'Are you sure you want to leave the group?\n\nThis action cannot be undone.',
                cancelText: 'Cancel',
                confirmText: 'Leave',
                confirmAction: () {
                  _removeMember(member);
                  Navigator.of(context).pop();
                },
              );
            },
          )
        : showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertConfirmAction(
                title: 'Remove ${member.name}',
                content:
                    'Are you sure you want to remove this member?\n\nThis action cannot be undone.',
                cancelText: 'Cancel',
                confirmText: 'Remove',
                confirmAction: () {
                  _removeMember(member);
                  Navigator.of(context).pop();
                },
              );
            },
          );
  }

  void _deleteGroup() async {
    SplitMoneyProvider splitMoneyProvider =
        Provider.of<SplitMoneyProvider>(context, listen: false);
    await SplitMoneyService.deleteGroup(splitMoneyProvider.id);
    if (context.mounted) {
      // quit to SplitMoneyGroup page
      Navigator.of(context).pop();
      // quit to Group list page
      Navigator.of(context).pop();
    }
  }

  void _deleteGroupConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertConfirmAction(
          title: 'Delete Group',
          content: 'Are you sure you want to delete this group?',
          cancelText: 'Cancel',
          confirmText: 'Delete',
          confirmAction: () {
            _deleteGroup();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _previousPage() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Settings'),
        actions: [
          IconButton(
            onPressed: _openEditGroup,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.diversity_3,
                    size: 60,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 20),
                  Consumer<SplitMoneyProvider>(
                    builder: (context, splitMoneyProvider, _) {
                      return Text(
                        splitMoneyProvider.name ?? 'Loading',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 28),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(
                thickness: 1.5,
              ),
              const SizedBox(height: 20),
              const Text(
                'Group Members',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    fixedSize: const Size(200, 50),
                  ),
                  onPressed: () {
                    _isAddingMember(true);
                  },
                  child: const ListTile(
                    iconColor: Colors.pink,
                    textColor: Colors.pink,
                    leading: Icon(Icons.group_add_outlined, size: 30),
                    title: Text('Add Member'),
                  ),
                ),
              ),
              if (_isAdding)
                Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.black),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _targetEmail = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return ValidatorMessage.emptyEmail;
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return ValidatorMessage.invalidEmail;
                              }
                              return null;
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _isAddingMember(false);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: _addMember,
                                child: const Text('Add'),
                              )
                            ],
                          )
                        ],
                      ),
                    )),
              const SizedBox(height: 10),
              Consumer<SplitMoneyProvider>(
                builder: (context, splitMoneyProvider, _) {
                  if (splitMoneyProvider.members == null) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('No group member yet'),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: splitMoneyProvider.members!.length,
                      itemBuilder: (context, index) {
                        GroupUser member = splitMoneyProvider.members![index];
                        return ListTile(
                          iconColor: Colors.black,
                          textColor: Colors.black,
                          leading: const Icon(Icons.account_circle_outlined,
                              size: 30),
                          title: Text(member.name),
                          subtitle: _checkIsOwner(
                                  splitMoneyProvider.ownerId, member.id)
                              ? const Text('Admin')
                              : null,
                          trailing: _isRemoving &&
                                  !_checkIsOwner(
                                      splitMoneyProvider.ownerId, member.id)
                              ? IconButton(
                                  onPressed: () {
                                    _removeMemberConfirmation(member);
                                  },
                                  icon: const Icon(Icons.delete,
                                      color: Colors.pink),
                                )
                              : null,
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!Constant.isMobile(context) && !_isRemoving)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(80, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      onPressed: _previousPage,
                      child: const Text('Back'),
                    ),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      if (_isOwner)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: _isRemoving
                                ? const Size(120, 40)
                                : const Size(150, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          onPressed: _toggleRemoveMember,
                          child: Text(_isRemoving ? 'Done' : 'Remove Member'),
                        ),
                      if (_isOwner) const SizedBox(width: 20),
                      if (!_isRemoving)
                        _isOwner
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(120, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                ),
                                onPressed: _deleteGroupConfirmation,
                                child: const Text('Delete Group'),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(120, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                ),
                                onPressed: () {
                                  _isLeaving = true;
                                  _removeMemberConfirmation(
                                      Provider.of<SplitMoneyProvider>(context,
                                              listen: false)
                                          .members!
                                          .firstWhere((member) =>
                                              member.id ==
                                              FirebaseInstance
                                                  .auth.currentUser!.uid));
                                },
                                child: const Text('Leave Group'),
                              )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
