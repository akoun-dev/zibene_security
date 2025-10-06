import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class MessagesScreen extends StatefulWidget {
  final String peerName;
  const MessagesScreen({super.key, required this.peerName});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final controller = TextEditingController();
  final List<_Msg> messages = [
    const _Msg(me: false, text: 'Hello, how can I help you?'),
    const _Msg(me: true, text: 'Hi, confirming the schedule for tomorrow.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.peerName)),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (_, i) {
              final m = messages[messages.length - 1 - i];
              return Align(
                alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: m.me ? AppColors.yellow : const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(m.text, style: TextStyle(color: m.me ? Colors.black : Colors.white)),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Type a message...'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                setState(() {
                  messages.add(_Msg(me: true, text: text));
                });
                controller.clear();
              },
            )
          ]),
        )
      ]),
    );
  }
}

class _Msg {
  final bool me; final String text; const _Msg({required this.me, required this.text});
}

