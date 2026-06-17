import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_care/features/patient/theme3.dart';

class AiChatScreen extends StatefulWidget {
  final String role;
  const AiChatScreen({super.key, this.role = 'patient'});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  late List<String> _suggestions;

  @override
  void initState() {
    super.initState();
    
    _suggestions = widget.role == 'doctor'
        ? [
            "📅 Review my schedule today",
            "👥 View active patients list",
            "📄 How do I update records?",
            "🔒 Security & compliance details",
          ]
        : [
            "🔍 Check my symptoms",
            "💊 Medicine schedule help",
            "📅 Upcoming appointments",
            "🧪 Explain lab results",
          ];

    // Welcome message
    _messages.add(
      _ChatMessage(
        text: widget.role == 'doctor'
            ? "Welcome, Doctor. How can I help you manage your patient records, vitals checklist, or schedule details today?"
            : "Hello! I am your AI Health Assistant. How can I help you manage your health today?",
        isUser: false,
        time: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
          time: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();
    _messageController.clear();

    // Generate response after a brief delay
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      String aiResponse = "";
      final lowerText = text.toLowerCase();

      if (widget.role == 'doctor') {
        if (lowerText.contains("schedule") || lowerText.contains("visit") || lowerText.contains("appointment") || lowerText.contains("today")) {
          aiResponse = "You can view your active consultation hours and upcoming patients today in the 'Schedule' tab. Active video consultations can be initiated from there directly.";
        } else if (lowerText.contains("patient") || lowerText.contains("history") || lowerText.contains("record")) {
          aiResponse = "To view active medical histories, vitals, or allergies, go to the 'Patients' tab. Tapping on a patient will reveal their full medical history files.";
        } else if (lowerText.contains("update") || lowerText.contains("diagnos") || lowerText.contains("treatment")) {
          aiResponse = "To write a new record log, go to 'Schedule' and tap 'Start Visit' / 'Visit Details' next to the appointment slot. You'll be prompted with diagnosis and treatment fields.";
        } else if (lowerText.contains("security") || lowerText.contains("compliance") || lowerText.contains("hipaa") || lowerText.contains("privacy")) {
          aiResponse = "All patient data communications are encrypted end-to-end and stored securely. Supabase handles database-level access rules ensuring complete compliance with HIPAA standards.";
        } else {
          aiResponse = "I understand. I am here to help coordinate your daily clinic overview, check schedule slots, and patient file details. Please let me know how I can assist you further.";
        }
      } else {
        if (lowerText.contains("symptom") || lowerText.contains("pain") || lowerText.contains("headache") || lowerText.contains("hurt")) {
          aiResponse = "I recommend tracking the onset and intensity of your symptoms. If you are experiencing mild pain, ensure you rest and stay hydrated. However, if symptoms persist, worsen, or include shortness of breath, please book an urgent consultation with one of our specialists immediately.";
        } else if (lowerText.contains("medicine") || lowerText.contains("dosage") || lowerText.contains("schedule") || lowerText.contains("pill") || lowerText.contains("remind")) {
          aiResponse = "I can help with that! You can check today's dosage checklist on your Profile tab. Ensuring you take medications at the scheduled times is crucial. Would you like me to guide you on how to log a new medicine reminder?";
        } else if (lowerText.contains("appointment") || lowerText.contains("visit") || lowerText.contains("doctor") || lowerText.contains("check-up")) {
          aiResponse = "You can review and manage all your upcoming appointments in the 'Schedule' tab. If the doctor starts a video session, a 'Join Call' button will appear instantly in the upcoming card on your home screen.";
        } else if (lowerText.contains("lab") || lowerText.contains("result") || lowerText.contains("report") || lowerText.contains("test")) {
          aiResponse = "Laboratory results can be uploaded under your Profile records. If you need help translating complex values (like WBC, Hemoglobin, or Cholesterol), I can translate medical jargon into simple explanations, but always discuss reports with your doctor.";
        } else {
          aiResponse = "I understand. I am here to help coordinate your bookings, medicine schedules, and health logging. Please let me know how I can guide you further!";
        }
      }

      setState(() {
        _isTyping = false;
        _messages.add(
          _ChatMessage(
            text: aiResponse,
            isUser: false,
            time: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A3C34), Color(0xFF0F2620)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.role == 'doctor' ? 'AI Doctor Portal' : 'AI Health Assistant',
              style: AppText.display(16, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.role == 'doctor' ? 'AI Portal Active' : 'Online & ready',
                  style: AppText.label(color: Colors.white70, size: 9),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  _ChatMessage(
                    text: widget.role == 'doctor'
                        ? "Welcome, Doctor. How can I help you manage your patient records, vitals checklist, or schedule details today?"
                        : "Hello! I am your AI Health Assistant. How can I help you manage your health today?",
                    isUser: false,
                    time: DateTime.now(),
                  ),
                );
              });
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
                return _buildChatBubble(_messages[index]);
              },
            ),
          ),
          
          // Suggestion list
          if (_messages.length == 1 && !_isTyping) _buildSuggestions(),

          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final prompt = _suggestions[index];
          return GestureDetector(
            onTap: () => _sendMessage(prompt.substring(2)),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  prompt,
                  style: AppText.label(color: AppColors.primary, size: 11),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8, top: 4),
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 16),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser ? AppColors.primaryGradient : null,
                color: isUser ? null : Colors.white,
                border: isUser ? null : Border.all(color: AppColors.border),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: isUser
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: isUser ? Colors.white60 : AppColors.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.08),
              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 16),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8, top: 4),
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(),
                SizedBox(width: 4),
                _TypingDot(delay: 200),
                SizedBox(width: 4),
                _TypingDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: AppText.body(13),
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                        decoration: const InputDecoration(
                          hintText: "Ask AI Assistant...",
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _sendMessage(_messageController.text),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  _ChatMessage({required this.text, required this.isUser, required this.time});
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({this.delay = 0});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 3, end: 7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: _animation.value,
          height: _animation.value,
          decoration: const BoxDecoration(
            color: AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
