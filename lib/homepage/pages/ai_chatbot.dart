import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({Key? key}) : super(key: key);

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  
  // Free Groq API Configuration
  static const String _groqApiKey = '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'; // Replace with your free Groq API key
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // System prompt for LNMIIT context
  static const String _systemPrompt = '''You are LNMIIT Campus Assistant, a helpful AI chatbot for The LNM Institute of Information Technology (LNMIIT), Jaipur, Rajasthan, India. 

LNMIIT is a premier technical institute offering undergraduate and postgraduate programs in Computer Science, Communication & Computer Engineering, Electronics & Communication, Mechanical Engineering, and other disciplines.

Campus Information:
- Library: Open 8 AM - 11 PM (weekdays), 9 AM - 6 PM (weekends)
- Mess timings: Breakfast 7:30-9:30 AM, Lunch 12-2 PM, Snacks 4:30-6 PM, Dinner 7:30-9:30 PM
- Gym: Open 6 AM - 10 PM daily
- Academic offices: 9 AM - 5 PM (weekdays)
- Campus has separate hostels for boys and girls
- Wi-Fi network: LNMIIT-Student (use student credentials)
- Medical center available during working hours
- Transportation: Campus shuttle services and private options available

Always provide helpful, accurate information about LNMIIT campus facilities, academics, events, and student life. Keep responses concise and friendly. If you don't know specific information, suggest contacting the relevant department or checking the official website.''';

  @override
  void initState() {
    super.initState();
    // Welcome message
    _addMessage(
      "Hello! I'm LNMIIT Campus Assistant. I can help you with information about campus facilities, academics, events, and more. How can I assist you today?",
      isUser: false,
    );
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
        animationController: AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        ),
      ));
    });
    _messages.last.animationController.forward();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _addMessage(text, isUser: true);

    setState(() {
      _isTyping = true;
    });

    try {
      String response = await _getAIResponse(text);
      setState(() {
        _isTyping = false;
      });
      _addMessage(response, isUser: false);
    } catch (e) {
      setState(() {
        _isTyping = false;
      });
      // Fallback to local responses if API fails
      String fallbackResponse = _generateLocalResponse(text);
      _addMessage(fallbackResponse, isUser: false);
    }
  }

  Future<String> _getAIResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192', // Fast and free Llama model
          'messages': [
            {
              'role': 'system',
              'content': _systemPrompt,
            },
            {
              'role': 'user', 
              'content': userMessage,
            }
          ],
          'max_tokens': 500,
          'temperature': 0.7,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else if (response.statusCode == 401) {
        return "🔑 API key not configured. Please add your free Groq API key to use AI responses. Using local responses for now.";
      } else {
        throw Exception('API request failed');
      }
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  String _generateLocalResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // Campus facilities
    if (message.contains('library') || message.contains('lib')) {
      return "📚 The LNMIIT Library is open from 8:00 AM to 11:00 PM on weekdays and 9:00 AM to 6:00 PM on weekends. It has digital resources, study areas, and computer terminals available for students.";
    }
    
    if (message.contains('hostel') || message.contains('accommodation')) {
      return "🏠 LNMIIT has separate hostels for boys and girls with modern amenities. Hostel allocation is done during admission. For queries about hostel facilities or mess timings, you can contact the hostel office.";
    }
    
    if (message.contains('mess') || message.contains('food') || message.contains('dining')) {
      return "🍽️ The campus mess serves breakfast (7:30-9:30 AM), lunch (12:00-2:00 PM), snacks (4:30-6:00 PM), and dinner (7:30-9:30 PM). There's also a cafeteria and food court for additional options.";
    }
    
    if (message.contains('gym') || message.contains('fitness') || message.contains('sports')) {
      return "💪 LNMIIT has a well-equipped gym, sports complex with basketball, volleyball courts, and a cricket ground. The gym is open from 6:00 AM to 10:00 PM. Sports equipment can be borrowed from the sports room.";
    }
    
    // Academic queries
    if (message.contains('exam') || message.contains('result') || message.contains('grade')) {
      return "📊 For exam schedules, results, and academic queries, please check the student portal or contact the academic office. Mid-semester and end-semester exam dates are usually announced 2 weeks in advance.";
    }
    
    if (message.contains('faculty') || message.contains('professor') || message.contains('teacher')) {
      return "👨‍🏫 Faculty information, office hours, and contact details are available on the LNMIIT website under the respective department pages. You can also find them in the student handbook.";
    }
    
    if (message.contains('course') || message.contains('syllabus') || message.contains('curriculum')) {
      return "📖 Course details and syllabus information are available on the academic portal. For specific course queries, you can contact the respective department or faculty advisor.";
    }
    
    // Events and activities
    if (message.contains('event') || message.contains('fest') || message.contains('activity')) {
      return "🎉 LNMIIT hosts various events throughout the year including technical fests, cultural programs, and workshops. Check the official notice board and social media pages for upcoming events.";
    }
    
    // Transportation
    if (message.contains('bus') || message.contains('transport') || message.contains('shuttle')) {
      return "🚌 Campus shuttle services run to nearby areas and the city center. Bus timings and routes are posted at the transport office. Private transportation options are also available.";
    }
    
    // Medical facilities
    if (message.contains('medical') || message.contains('health') || message.contains('doctor')) {
      return "🏥 The campus has a medical center with basic healthcare facilities. For emergencies, there are nearby hospitals. The medical center is open during working hours on weekdays.";
    }
    
    // Wi-Fi and IT
    if (message.contains('wifi') || message.contains('internet') || message.contains('network')) {
      return "📶 Campus-wide Wi-Fi is available. Use your student credentials to connect to 'LNMIIT-Student' network. For technical issues, contact the IT helpdesk at the computer center.";
    }
    
    // General campus info
    if (message.contains('timings') || message.contains('hours') || message.contains('schedule')) {
      return "⏰ Campus facilities have different timings:\n• Library: 8 AM - 11 PM\n• Mess: Breakfast 7:30-9:30 AM, Lunch 12-2 PM, Dinner 7:30-9:30 PM\n• Gym: 6 AM - 10 PM\n• Academic offices: 9 AM - 5 PM";
    }
    
    // Default responses
    List<String> defaultResponses = [
      "I'd be happy to help! Could you please be more specific about what information you need regarding LNMIIT campus?",
      "I can assist you with information about campus facilities, academics, events, hostels, and more. What would you like to know?",
      "For detailed information, you might also want to check the official LNMIIT website or contact the respective department directly.",
      "I'm here to help with campus-related queries. Could you please rephrase your question or ask about specific facilities?",
    ];
    
    return defaultResponses[DateTime.now().millisecond % defaultResponses.length];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    for (var message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 27,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               RichText(
                      text: TextSpan(
                         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        children: const [
                       TextSpan(
                       text: 'Campus ',
                       style: TextStyle(color: Colors.blueAccent),
                        ),
                       TextSpan(
                      text: 'Assistant',
                    style: TextStyle(color: Colors.green),
                     ),
                      ],
                   ),
                ),
                Text(
                  'LNMIIT Helper Bot',
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[700]),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: message.animationController,
        curve: Curves.easeOut,
      )),
      child: FadeTransition(
        opacity: message.animationController,
        child: Container(
          margin: EdgeInsets.only(
            bottom: 12,
            left: message.isUser ? 40 : 0,
            right: message.isUser ? 0 : 40,
          ),
          child: Row(
            mainAxisAlignment: message.isUser 
                ? MainAxisAlignment.end 
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser 
                        ? Colors.blue[600] 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, right: 40),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.4, end: 1.0),
      builder: (context, value, child) {
        return AnimatedBuilder(
          animation: ModalRoute.of(context)!.animation!,
          builder: (context, child) {
            final animationValue = (DateTime.now().millisecondsSinceEpoch / 600) % 1;
            final opacity = index == 0 
                ? animationValue 
                : index == 1 
                    ? (animationValue + 0.33) % 1 
                    : (animationValue + 0.66) % 1;
            return Opacity(
              opacity: 0.4 + (opacity * 0.6),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask about campus facilities...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  textInputAction: TextInputAction.send,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Clear Chat'),
              onTap: () {
                setState(() {
                  _messages.clear();
                });
                Navigator.pop(context);
                _addMessage(
                  "Chat cleared! How can I help you today?",
                  isUser: false,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & FAQ'),
              onTap: () {
                Navigator.pop(context);
                _addMessage(
                  "I can help you with:\n• Campus facilities (library, gym, mess)\n• Academic information\n• Hostel details\n• Events and activities\n• Transportation\n• Medical facilities\n• Wi-Fi and IT support\n\nJust ask me anything about LNMIIT campus!",
                  isUser: false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final AnimationController animationController;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.animationController,
  });
}