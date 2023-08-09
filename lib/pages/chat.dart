import 'package:flutter/material.dart';

import '../firebase_instance.dart';
import '../constants/style_constant.dart';
import '../services/chat_service.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>>? _messages;
  String _sendMessage = '';

  @override
  void initState() {
    super.initState();
    _getMessages();
  }

  @override
    void dispose() {
      super.dispose();
      _controller.dispose();
    }

  void _getMessages() async {
    await ChatService.getChatMessage().then((messages) {
      setState(() {
        _messages = messages;
      });
    });
  }

  Future<void> _send() async {
    if (_sendMessage.isEmpty || _sendMessage.trim().isEmpty) return;
    await ChatService.sendMessage(_sendMessage, FirebaseInstance.auth.currentUser!.uid).then((_) {
      _controller.clear();
      _sendMessage = '';
      _getMessages();
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
          _messages == null || _messages!.isEmpty
              ? const Center(child: Text("No messages yet"))
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(bottom: 70),
                  shrinkWrap: true,
                  itemCount: _messages!.length,
                  itemBuilder: (context, i) {
                    int index = _messages!.length - 1 - i;
                    String senderID = _messages![index]['senderID'];
                    return Align(
                      alignment: _isMe(senderID)
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: IntrinsicWidth(
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 80,
                            maxWidth: 300,
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isMe(senderID) ? 'You' : _messages![index]['sender'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 2, bottom: 4),
                                child: Text(_messages![index]['message']),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  _messages![index]['date'].toString().substring(11, 16),
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
                    );
                  }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        decoration: const InputDecoration(
                            hintText: "Send a message...",
                            hintStyle: TextStyle(fontSize: 16),
                            border: InputBorder.none),
                        onChanged: (value) {
                          setState(() {
                            _sendMessage = value;
                          });
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            color: ColorConstant.lightBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            size: 20,
                          )),
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }
}
