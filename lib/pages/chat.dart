import 'package:flutter/material.dart';

import '../constants/style_constant.dart';
import '../services/chat_service.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    Future? _messages;
    TextEditingController _messageController = TextEditingController();

    @override
    void initState() {
      super.initState();

      ChatService.getChatMessage().then((val) {
        setState(() {
          _messages = val;
        });
      });
    }

    void _send() {}

    bool _isMe(String sender) {
      return sender == 'A';
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Stack(
        children: [
          FutureBuilder(
            future: ChatService.getChatMessage(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.only(bottom: 70),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, i) {
                      int index = snapshot.data!.length - 1 - i;
                      String sender = snapshot.data![index]['sender'];
                      return Align(
                        alignment: _isMe(sender)
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(
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
                              bottomLeft: _isMe(sender)
                                  ? const Radius.circular(20)
                                  : const Radius.circular(0),
                              bottomRight: _isMe(sender)
                                  ? const Radius.circular(0)
                                  : const Radius.circular(20),
                            ),
                            color: _isMe(sender)
                                ? Colors.green[200]
                                : Colors.grey[200],
                          ),
                          child: Text(snapshot.data![index]['message']),
                        ),
                      );
                    });
              }
              return const Text("No message yet.");
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            hintText: "Send a message...",
                            hintStyle: TextStyle(fontSize: 16),
                            border: InputBorder.none),
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
                            Icons.send,
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
