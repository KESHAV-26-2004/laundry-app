import 'dart:async';
import 'package:flutter/material.dart';
import 'student/ai_connect.dart';
import 'package:http/http.dart' as http;

class FloatingBotButton extends StatefulWidget {
  const FloatingBotButton({Key? key}) : super(key: key);

  @override
  _FloatingBotButtonState createState() => _FloatingBotButtonState();
}

class _FloatingBotButtonState extends State<FloatingBotButton> {
  bool _showMessage = false;
  double _messageOpacity = 0.0;
  bool _isExpanded = false;
  String? _ngrokUrl="hello";
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Show help message after 5 seconds, then fade it out
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!mounted || _isExpanded) return;
      setState(() {
        _showMessage = true;
        _messageOpacity = 1.0;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_isExpanded) {
          setState(() {
            _messageOpacity = 0.0;
          });
        }
      });
    });
  }

  Future<void> _fetchNgrokUrl() async {
    try {
      final response = await http.get(
        Uri.parse("https://keshav-26-2004.github.io/laundry_redirect/redirect.html"),
      );

      if (response.statusCode == 200) {
        final regex = RegExp(r'https://[a-zA-Z0-9\-]+\.ngrok\-free\.app');
        final match = regex.firstMatch(response.body);

        if (match != null) {
          setState(() {
            _ngrokUrl = match.group(0); // Save extracted URL
          });
        } else {
          debugPrint("No ngrok URL found in redirect.html");
        }
      } else {
        debugPrint("Failed to load redirect.html");
      }
    } catch (e) {
      debugPrint("Error fetching ngrok URL: $e");
    }
  }

  void _toggleChat() async{
    if (!_isExpanded) {
      await _fetchNgrokUrl(); // Fetch URL only once when opening
    }
    setState(() {
      // When closing, clear the text field
      if (_isExpanded) _controller.clear();
      _isExpanded = !_isExpanded;
    });
  }

  void _sendMessage() async {
    String userInput = _controller.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      _chatHistory.add({'sender': 'user', 'message': userInput});
      _controller.clear();
    });
    _scrollToBottom();

    String botReply = await getBotResponse(userInput,_ngrokUrl!);

    setState(() {
      _chatHistory.add({'sender': 'bot', 'message': botReply});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // When expanded, show the chat canvas centered on screen.
        if (_isExpanded)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 15,
                right: 15,
              ),
              child: Material(
                // Use Material to get proper shadow and rounded corners
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 700,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with title and close button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Laundry Assistant",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: _toggleChat,
                            )
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Chat history area
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey.shade100,
                          child: _chatHistory.isEmpty
                              ? const Center(child: Text("Hi! How can I help you today?"))
                              : ListView.builder(
                            controller: _scrollController,
                            itemCount: _chatHistory.length,
                              itemBuilder: (context, index) {
                                final chat = _chatHistory[index];
                                final isUser = chat['sender'] == 'user';

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Align(
                                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isUser ? Colors.deepPurple.shade100 : Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(chat['message'] ?? ""),
                                    ),
                                  ),
                                );
                              },
                          ),
                        ),
                      ),
                      // TextField and Send button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  hintText: "Type your message...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
                              onPressed: _sendMessage,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),),
        // The floating button always visible at the bottom right
        Positioned(
          bottom: 26,
          right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_showMessage && !_isExpanded)
                AnimatedOpacity(
                  opacity: _messageOpacity,
                  duration: const Duration(seconds: 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("Need help? Tap me!"),
                  ),
                ),
              AnimatedOpacity(
                opacity: _isExpanded ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: _isExpanded, // Prevents tap when invisible
                  child: FloatingActionButton(
                    onPressed: _toggleChat,
                    backgroundColor: Colors.purpleAccent,
                    child: const Icon(Icons.chat_bubble),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
