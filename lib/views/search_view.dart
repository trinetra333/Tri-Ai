import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message.dart';

/// Full-text search across every stored conversation. Pushed on top of the
/// chat view; tapping a result opens that conversation and pops back.
class SearchView extends GetView<ChatController> {
  const SearchView({super.key});

  Color _accent(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? const Color(0xFF9B4DFF)
      : const Color(0xFF7B2FF7);

  Color _sep(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.08);

  String _snippet(String content, String query) {
    final lower = content.toLowerCase();
    final idx = lower.indexOf(query.toLowerCase());
    if (idx < 0) {
      return content.length > 140 ? '${content.substring(0, 140)}…' : content;
    }
    const radius = 60;
    final start = (idx - radius).clamp(0, content.length);
    final end = (idx + query.length + radius).clamp(0, content.length);
    final prefix = start > 0 ? '…' : '';
    final suffix = end < content.length ? '…' : '';
    return '$prefix${content.substring(start, end).trim()}$suffix';
  }

  String _fmtDate(DateTime d) {
    final now = DateTime.now();
    final sameDay = d.year == now.year && d.month == now.month && d.day == now.day;
    if (sameDay) {
      final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
      final ampm = d.hour >= 12 ? 'PM' : 'AM';
      return '$h:${d.minute.toString().padLeft(2, '0')} $ampm';
    }
    return '${d.month}/${d.day}/${d.year % 100}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0E0A1F) : const Color(0xFFFAF8FF);
    final textCtrl = TextEditingController(text: controller.searchQuery.value);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 8,
        title: TextField(
          controller: textCtrl,
          autofocus: true,
          onChanged: controller.searchMessages,
          style: GoogleFonts.inter(fontSize: 16, color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Search all conversations…',
            hintStyle: GoogleFonts.inter(color: Theme.of(context).hintColor),
            border: InputBorder.none,
          ),
        ),
        actions: [
          Obx(() => controller.searchQuery.value.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    textCtrl.clear();
                    controller.clearSearch();
                  },
                )),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: _sep(context)),
        ),
      ),
      body: Obx(() {
        final query = controller.searchQuery.value;
        final results = controller.searchResults;
        if (query.trim().isEmpty) {
          return _hint(context, 'Search across every chat by message content.');
        }
        if (results.isEmpty) {
          return _hint(context, 'No messages found for "$query".');
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: results.length,
          separatorBuilder: (_, __) => Divider(height: 0.5, indent: 16, color: _sep(context)),
          itemBuilder: (ctx, i) {
            final ChatSearchResult r = results[i];
            final isUser = r.message.role == 'user';
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: _accent(context).withValues(alpha: 0.12),
                child: Icon(
                  isUser ? Icons.person_outline_rounded : Icons.auto_awesome,
                  size: 15,
                  color: _accent(context),
                ),
              ),
              title: Text(
                r.sessionTitle,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  _snippet(r.message.content, query),
                  style: GoogleFonts.inter(fontSize: 13, color: Theme.of(ctx).hintColor, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: Text(
                _fmtDate(r.message.timestamp),
                style: GoogleFonts.inter(fontSize: 11, color: Theme.of(ctx).hintColor),
              ),
              onTap: () {
                controller.openSearchResult(r);
                Navigator.pop(context);
              },
            );
          },
        );
      }),
    );
  }

  Widget _hint(BuildContext context, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).hintColor),
        ),
      ),
    );
  }
}
