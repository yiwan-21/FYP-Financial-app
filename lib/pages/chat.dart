import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../firebase_instance.dart';
import '../constants/style_constant.dart';
import '../providers/notification_provider.dart';
import '../services/chat_service.dart';

class Chat extends StatefulWidget {
  final bool isSettled;

  const Chat({required this.isSettled, super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  final Stream<QuerySnapshot> _stream = ChatService.getChatStream();
  String _sendMessage = '';

  @override
  void initState() {
    super.initState();
    // update read status when chat page is opened
    updateReadStatus();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> updateReadStatus() async {
    await ChatService.updateReadStatus().whenComplete(() {
      Provider.of<NotificationProvider>(context, listen: false)
          .setChatNotification(false);
    });
  }

  Future<void> _send() async {
    if (_sendMessage.isEmpty || _sendMessage.trim().isEmpty) return;
    await ChatService.sendMessage(
            _sendMessage, FirebaseInstance.auth.currentUser!.uid)
        .then((_) {
      _controller.clear();
      _sendMessage = '';
    });
  }

  bool _isMe(String senderID) {
    return senderID == FirebaseInstance.auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (!snapshot.hasData) {
                  const Center(child: Text("No messages yet"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                }
                return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.only(bottom: 70),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, i) {
                      int index = snapshot.data!.docs.length - 1 - i;
                      String senderID = snapshot.data!.docs[index]['senderID'];
                      return Align(
                        alignment: _isMe(senderID)
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // chat with pikachu
                            Stack(
                              children: [
                                IntrinsicWidth(
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 80,
                                      maxWidth: 300,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(20),
                                        topRight: const Radius.circular(20),
                                        bottomLeft: _isMe(senderID)
                                            ? const Radius.circular(20)
                                            : const Radius.circular(0),
                                        bottomRight: _isMe(senderID)
                                            ? const Radius.circular(0)
                                            : const Radius.circular(20),
                                      ),
                                      color: _isMe(senderID)
                                          ? Colors.green[200]
                                          : Colors.grey[200],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isMe(senderID)
                                              ? 'You'
                                              : snapshot.data!.docs[index]
                                                  ['sender'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 2, bottom: 4),
                                          child: Text(snapshot.data!.docs[index]
                                              ['message']),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            snapshot.data!.docs[index]['date']
                                                .toDate()
                                                .toString()
                                                .substring(11, 16),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -2,
                                  left: _isMe(senderID) ? -10 : null,
                                  right: _isMe(senderID) ? null : -10,
                                  child: Transform.scale(
                                    scaleX: _isMe(senderID) ? -1 : 1,
                                    child: Transform.rotate(
                                      angle: 0.8,
                                      child: Container(
                                        width: 40,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/cute.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            //read status
                            if (i == 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Text(
                                  '${snapshot.data!.docs[index]['readStatus'].length} read',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: Colors
                                        .grey, // Set the appropriate color
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    });
              }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: Constant.isMobile(context) ? 0 : 5),
                decoration: BoxDecoration(
                  color: widget.isSettled ? Colors.grey[300] : Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: widget.isSettled
                            ? Colors.transparent
                            : Colors.grey[400] ?? Colors.grey,
                        offset: const Offset(0, -2),
                        blurRadius: 4,
                        blurStyle: BlurStyle.outer),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Send a message...",
                          hintStyle: TextStyle(fontSize: 16),
                          border: InputBorder.none,
                        ),
                        readOnly: widget.isSettled,
                        onChanged: (value) {
                          setState(() {
                            _sendMessage = value;
                          });
                        },
                        onFieldSubmitted: (_) => _send(),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.isSettled ? null : _send,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: widget.isSettled
                              ? Colors.grey[300]
                              : ColorConstant.lightBlue,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          size: 20,
                        ),
                      ),
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }
}
