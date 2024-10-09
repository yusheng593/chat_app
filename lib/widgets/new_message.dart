import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageControll = TextEditingController();

  @override
  void dispose() {
    _messageControll.dispose();
    super.dispose();
  }

  void _submitMessage() {
    final enterMessage = _messageControll.text;
    if (enterMessage.trim().isEmpty) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageControll,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration:
                    const InputDecoration(labelText: 'Send a message...'),
              ),
            ),
            IconButton(
              onPressed: _submitMessage,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
