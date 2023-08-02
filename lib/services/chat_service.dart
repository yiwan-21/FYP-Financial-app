class ChatService {
  
  static Future getChatMessage() async {
    return [
      {'message': 'a', 'sender': 'A'},
      {'message': 'b', 'sender': 'B'},
      {'message': 'Hi', 'sender': 'A'},
      {'message': 'Hello', 'sender': 'B'},
      {'message': 'How are you?', 'sender': 'A'},
      {'message': 'I am fine', 'sender': 'B'},
      {'message': 'How about you?', 'sender': 'A'},
      {'message': 'I am fine too', 'sender': 'B'},
      {'message': 'Bye', 'sender': 'A'},
      {'message': 'Bye', 'sender': 'B'},
      {'message': 'I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too', 'sender': 'B'},
      {'message': 'I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too I am fine too', 'sender': 'A'},
    ];
  }
}