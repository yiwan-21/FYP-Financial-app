import 'package:flutter/material.dart';

import '../constants/style_constant.dart';
import '../services/chat_service.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  void _send() {}

  bool _isMe(String sender) {
    return sender == 'Aby';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isMe(sender) ? 'You' : sender,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 2, bottom: 4),
                                  child: Text(snapshot.data![index]['message']),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                  DateTime.now().toString().substring(11, 16),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),)
                              ],
                            ),
                          ),
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
