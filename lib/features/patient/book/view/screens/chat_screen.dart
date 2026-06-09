import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_care/features/patient/book/cubit/chat_cubit.dart';
import 'package:smart_care/features/patient/book/cubit/chat_state.dart';
import 'package:smart_care/features/patient/book/data/model/chat_model.dart';
import 'package:smart_care/features/patient/book/data/repository/chat_repository.dart';
import 'package:smart_care/features/patient/theme3.dart';

/// Entry point — wraps [_ChatPage] with its own [ChatCubit].
class ChatScreen extends StatelessWidget {
  /// The appointment that this conversation belongs to.
  final String appointmentId;

  /// The authenticated user's profile ID (sender).
  final String currentUserId;

  /// The other party's profile ID (receiver).
  final String otherUserId;

  /// Display name shown in the app bar.
  final String otherUserName;

  /// Optional specialty / role subtitle shown under the name.
  final String? otherUserRole;

  /// Optional avatar URL.
  final String? otherUserAvatar;

  const ChatScreen({
    super.key,
    required this.appointmentId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserRole,
    this.otherUserAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(ChatRepository())
        ..loadAndSubscribe(
          appointmentId: appointmentId,
          currentUserId: currentUserId,
        ),
      child: _ChatPage(
        appointmentId: appointmentId,
        currentUserId: currentUserId,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserRole: otherUserRole,
        otherUserAvatar: otherUserAvatar,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ChatPage extends StatefulWidget {
  final String appointmentId;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserRole;
  final String? otherUserAvatar;

  const _ChatPage({
    required this.appointmentId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserRole,
    this.otherUserAvatar,
  });

  @override
  State<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final target = _scrollController.position.maxScrollExtent;
        if (animated) {
          _scrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(target);
        }
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<ChatCubit>().sendMessage(
          appointmentId: widget.appointmentId,
          senderProfileId: widget.currentUserId,
          receiverProfileId: widget.otherUserId,
          text: text,
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          _Avatar(
            name: widget.otherUserName,
            url: widget.otherUserAvatar,
            radius: 18,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.otherUserName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              if (widget.otherUserRole != null)
                Text(
                  widget.otherUserRole!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, size: 22),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  // ── Message list ─────────────────────────────────────────────────────────

  Widget _buildMessageList() {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is ChatLoaded || state is ChatSending) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text(
                  'Could not load messages',
                  style: AppText.body(14, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        final messages = state is ChatLoaded
            ? state.messages
            : state is ChatSending
                ? state.messages
                : <ChatMessage>[];

        if (messages.isEmpty) {
          return _EmptyConversation(name: widget.otherUserName);
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg.senderProfileId == widget.currentUserId;
            final isFirst = index == 0 ||
                messages[index - 1].senderProfileId != msg.senderProfileId;
            final isLast = index == messages.length - 1 ||
                messages[index + 1].senderProfileId != msg.senderProfileId;
            final showTime = isLast;
            final isSending =
                msg.id.startsWith('temp_') && state is ChatSending;

            return _MessageBubble(
              message: msg,
              isMe: isMe,
              isFirst: isFirst,
              isLast: isLast,
              showTime: showTime,
              isSending: isSending,
              otherName: widget.otherUserName,
              otherAvatar: widget.otherUserAvatar,
            );
          },
        );
      },
    );
  }

  // ── Input bar ────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button
          _IconBtn(
            icon: Icons.attach_file_rounded,
            color: AppColors.textMuted,
            onTap: () {},
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: AppText.body(14),
                decoration: const InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, value, __) {
              final hasText = value.text.trim().isNotEmpty;
              return AnimatedScale(
                scale: hasText ? 1.0 : 0.85,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: _send,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: hasText ? AppColors.primary : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: hasText ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message bubble
// ─────────────────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool isFirst;
  final bool isLast;
  final bool showTime;
  final bool isSending;
  final String otherName;
  final String? otherAvatar;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.isFirst,
    required this.isLast,
    required this.showTime,
    required this.isSending,
    required this.otherName,
    this.otherAvatar,
  });

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    const myBubbleColor = AppColors.primary;
    const theirBubbleColor = Colors.white;

    final myRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: Radius.circular(isFirst ? 18 : 4),
      bottomRight: Radius.circular(isLast ? 4 : 4),
      bottomLeft: const Radius.circular(18),
    );

    final theirRadius = BorderRadius.only(
      topLeft: Radius.circular(isFirst ? 18 : 4),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isLast ? 4 : 4),
      bottomRight: const Radius.circular(18),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 10 : 2,
        top: isFirst ? 6 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Other user's avatar (only on their last message)
          if (!isMe) ...[
            if (isLast)
              _Avatar(name: otherName, url: otherAvatar, radius: 14)
            else
              const SizedBox(width: 28),
            const SizedBox(width: 6),
          ],

          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? myBubbleColor : theirBubbleColor,
                    borderRadius: isMe ? myRadius : theirRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.45,
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (showTime)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            isSending
                                ? Icons.access_time_rounded
                                : message.isRead
                                    ? Icons.done_all_rounded
                                    : Icons.done_rounded,
                            size: 12,
                            color: message.isRead && !isSending
                                ? AppColors.teal
                                : AppColors.textMuted,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Space on right for "their" messages
          if (!isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyConversation extends StatelessWidget {
  final String name;
  const _EmptyConversation({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 36, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Start the conversation',
              style: AppText.display(18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to $name.\nAll messages are private.',
              style: AppText.body(14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar helper
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? url;
  final double radius;

  const _Avatar({required this.name, this.url, required this.radius});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(url!),
        backgroundColor: AppColors.tealLight,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.teal.withValues(alpha: 0.15),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.65,
          fontWeight: FontWeight.w700,
          color: AppColors.teal,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Icon button helper
// ─────────────────────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _IconBtn({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: color, size: 22),
        ),
      );
}
