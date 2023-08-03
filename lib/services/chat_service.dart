class ChatService {
  
  static Future getChatMessage() async {
    return [
      {'message': 'a', 'sender': 'Aby'},
      {'message': 'b', 'sender': 'Boby'},
      {'message': 'Hi', 'sender': 'Aby'},
      {'message': 'Hello', 'sender': 'Boby'},
      {'message': 'How are you?', 'sender': 'Aby'},
      {'message': 'I am fine', 'sender': 'Boby'},
      {'message': 'How about you?', 'sender': 'Aby'},
      {'message': 'I am fine too', 'sender': 'Boby'},
      {'message': 'Bye', 'sender': 'Aby'},
      {'message': 'Bye', 'sender': 'Boby'},
      {'message': 'I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too', 'sender': 'Boby'},
      {'message': 'I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too', 'sender': 'Aby'},
    ];
  }
}