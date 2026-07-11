import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';
import '../utils/thought_parser.dart';
import 'attachment_preview.dart';
import 'image_viewer.dart';
import 'thought_disclosure.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  // ── Tri Ai brand accent colors ──
  static const _brandViolet = Color(0xFF7B2FF7);
  static const _brandVioletDark = Color(0xFF9B4DFF);

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visibleContent = message.fileName == null
        ? message.content
        : message.content.split('\n\nAttached file:').first;
    final thoughtParts = isUser
        ? const ThoughtParts(thought: '', answer: '', isThinking: false)
        : splitThoughtTags(_cleanAssistantText(visibleContent));
    final answerContent = isUser ? visibleContent : thoughtParts.answer.trim();

    return _BubbleEntrance(
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _bubbleColor(context, isUser),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 20 : 6),
              bottomRight: Radius.circular(isUser ? 6 : 20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image attachment
              if (message.decodedImageBytes != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => ImageViewer.show(context, message.imageBase64!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        message.decodedImageBytes!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => Container(

                          height: 100,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(child: Icon(Icons.broken_image_rounded, size: 28)),
                        ),
                      ),
                    ),
                  ),
                ),

              // Thought disclosure
              if (!isUser && thoughtParts.hasThought)
                ThoughtDisclosure(
                  thought: thoughtParts.thought,
                  durationSeconds: message.thoughtDurationSeconds,
                  styleSheet: _thoughtMarkdownStyle(context),
                ),

              // Message content
              if (isUser)
                SelectableText(
                  visibleContent,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                )
              else if (answerContent.isNotEmpty)
                MarkdownBody(
                  data: answerContent,
                  selectable: true,
                  styleSheet: _markdownStyle(context),
                ),

              // File attachment
              if (message.fileName != null) ...[
                const SizedBox(height: 10),
                AttachmentPreview(
                  fileName: message.fileName!,
                  fileType: message.fileType,
                  fileSize: message.fileSize,
                  imageBase64: message.imageBase64,
                  imagePath: message.imagePath,
                  compact: true,
                ),
              ],

              // Timestamp & speed
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.tokensPerSec != null && message.tokensPerSec! > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${message.tokensPerSec!.toStringAsFixed(1)} tok/s',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isUser
                              ? Colors.white.withValues(alpha: 0.55)
                              : Theme.of(context).hintColor.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (message.imageGenDurationMs != null && message.imageGenDurationMs! > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        _formatGenTime(message.imageGenDurationMs!),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isUser
                              ? Colors.white.withValues(alpha: 0.55)
                              : Theme.of(context).hintColor.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isUser
                          ? Colors.white.withValues(alpha: 0.55)
                          : Theme.of(context).hintColor.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (visibleContent.trim().isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _CopyButton(
                      text: isUser ? visibleContent : answerContent,
                      isUser: isUser,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Color _bubbleColor(BuildContext context, bool isUser) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isUser) return isDark ? _brandVioletDark : _brandViolet;
    return isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Theme.of(context).colorScheme.onSurface;
    final muted = Theme.of(context).hintColor;
    final base = GoogleFonts.inter(fontSize: 15, color: color, height: 1.5);
    final codeBlockBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: base,
      strong: base.copyWith(fontWeight: FontWeight.w600),
      em: base.copyWith(fontStyle: FontStyle.italic),
      listBullet: base,
      code: GoogleFonts.firaCode(
        fontSize: 13,
        color: color,
        backgroundColor: codeBlockBg,
      ),
      codeblockDecoration: BoxDecoration(
        color: codeBlockBg,
        borderRadius: BorderRadius.circular(12),
      ),
      codeblockPadding: const EdgeInsets.all(14),
      blockquote: base.copyWith(color: muted),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15),
            width: 3,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 14, top: 2, bottom: 2),
    );
  }

  MarkdownStyleSheet _thoughtMarkdownStyle(BuildContext context) {
    final muted = Theme.of(context).hintColor;
    final base = GoogleFonts.inter(fontSize: 13, color: muted, height: 1.4);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: base,
      strong: base.copyWith(fontWeight: FontWeight.w600),
      em: base.copyWith(fontStyle: FontStyle.italic),
      listBullet: base,
      code: GoogleFonts.firaCode(
        fontSize: 11,
        color: muted,
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatGenTime(int ms) {
    if (ms < 1000) return '${ms}ms';
    if (ms < 60000) return '${(ms / 1000).toStringAsFixed(1)}s';
    final m = ms ~/ 60000;
    final s = (ms % 60000) ~/ 1000;
    return s > 0 ? '${m}m ${s}s' : '${m}m';
  }

  String _cleanAssistantText(String text) {
    return text
        .replaceAll('<|endoftext|>', '')
        .replaceAll('<|im_end|>', '')
        .replaceAll('<|end|>', '')
        .trim();
  }
}

/// Small tappable copy icon with a brief "copied" checkmark animation and a
/// press-scale micro-interaction.
class _CopyButton extends StatefulWidget {
  final String text;
  final bool isUser;

  const _CopyButton({required this.text, required this.isUser});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;
  bool _pressed = false;

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isUser
        ? Colors.white.withValues(alpha: 0.55)
        : Theme.of(context).hintColor.withValues(alpha: 0.5);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: _handleCopy,
      child: AnimatedScale(
        scale: _pressed ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            _copied ? Icons.check_rounded : Icons.copy_rounded,
            key: ValueKey(_copied),
            size: 13,
            color: _copied
                ? (widget.isUser ? Colors.white : const Color(0xFF34C759))
                : color,
          ),
        ),
      ),
    );
  }
}

/// Fades and slides a chat bubble in as it's first built, giving new
/// messages a subtle premium entrance instead of popping in instantly.
class _BubbleEntrance extends StatefulWidget {
  final Widget child;
  const _BubbleEntrance({required this.child});

  @override
  State<_BubbleEntrance> createState() => _BubbleEntranceState();
}

class _BubbleEntranceState extends State<_BubbleEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
