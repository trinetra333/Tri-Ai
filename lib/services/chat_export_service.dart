import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/chat_message.dart';

/// Exports a chat conversation as Markdown or PDF and shares it via the
/// platform share sheet.
class ChatExportService {
  ChatExportService._();

  static final DateFormat _fmt = DateFormat('MMM d, y · h:mm a');

  static String _roleLabel(String role) {
    switch (role) {
      case 'user':
        return 'You';
      case 'assistant':
        return 'Tri Ai';
      case 'cmd':
        return 'Command';
      default:
        return role.isEmpty ? 'Unknown' : role[0].toUpperCase() + role.substring(1);
    }
  }

  static String _safeFileName(String input) {
    final cleaned = input.trim().isEmpty ? 'Tri Ai Chat' : input.trim();
    return cleaned.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  static String _visibleContent(ChatMessage m) {
    if (m.fileName == null) return m.content;
    return m.content.split('\n\nAttached file:').first;
  }

  // ─── Markdown ────────────────────────────────────────

  static String buildMarkdown(String title, List<ChatMessage> messages) {
    final buffer = StringBuffer();
    buffer.writeln('# $title');
    buffer.writeln();
    buffer.writeln('_Exported from Tri Ai on ${_fmt.format(DateTime.now())}_');
    buffer.writeln();
    for (final m in messages) {
      final content = _visibleContent(m).trim();
      if (content.isEmpty && m.imageBase64 == null) continue;
      buffer.writeln('**${_roleLabel(m.role)}** · _${_fmt.format(m.timestamp)}_');
      buffer.writeln();
      if (content.isNotEmpty) buffer.writeln(content);
      if (m.imageBase64 != null) buffer.writeln('_[image attached]_');
      if (m.fileName != null) buffer.writeln('_[file attached: ${m.fileName}]_');
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }
    return buffer.toString();
  }

  static Future<void> shareMarkdown(String title, List<ChatMessage> messages) async {
    final content = buildMarkdown(title, messages);
    final tempDir = await getTemporaryDirectory();
    final fileName = '${_safeFileName(title)}.md';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)], text: 'Exported from Tri Ai');
  }

  // ─── PDF ─────────────────────────────────────────────

  static Future<Uint8List> buildPdfBytes(String title, List<ChatMessage> messages) async {
    final document = PdfDocument();
    document.pageSettings.margins.all = 40;
    document.pageSettings.size = PdfPageSize.a4;

    final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    final metaFont = PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.italic);
    final roleFont = PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold);
    final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 11);
    final mutedBrush = PdfSolidBrush(PdfColor(120, 120, 120));
    final accentBrush = PdfSolidBrush(PdfColor(123, 47, 247)); // brand violet

    final page = document.pages.add();
    final pageSize = page.getClientSize();
    final format = PdfLayoutFormat(layoutType: PdfLayoutType.paginate);

    PdfLayoutResult? result = PdfTextElement(text: title, font: titleFont).draw(
      page: page,
      bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
      format: format,
    );

    result = PdfTextElement(
      text: 'Exported from Tri Ai on ${_fmt.format(DateTime.now())}',
      font: metaFont,
      brush: mutedBrush,
    ).draw(
      page: result!.page,
      bounds: Rect.fromLTWH(0, result.bounds.bottom + 4, pageSize.width, pageSize.height),
      format: format,
    );

    for (final m in messages) {
      final content = _visibleContent(m).trim();
      if (content.isEmpty && m.imageBase64 == null && m.fileName == null) continue;

      result = PdfTextElement(
        text: '${_roleLabel(m.role)}   ·   ${_fmt.format(m.timestamp)}',
        font: roleFont,
        brush: m.role == 'user' ? accentBrush : PdfSolidBrush(PdfColor(0, 0, 0)),
      ).draw(
        page: result!.page,
        bounds: Rect.fromLTWH(0, result.bounds.bottom + 16, pageSize.width, pageSize.height),
        format: format,
      );

      final parts = <String>[
        if (content.isNotEmpty) content,
        if (m.imageBase64 != null) '[image attached]',
        if (m.fileName != null) '[file attached: ${m.fileName}]',
      ];

      result = PdfTextElement(text: parts.join('\n'), font: bodyFont).draw(
        page: result!.page,
        bounds: Rect.fromLTWH(0, result.bounds.bottom + 4, pageSize.width, pageSize.height),
        format: format,
      );
    }

    final bytes = await document.save();
    document.dispose();
    return Uint8List.fromList(bytes);
  }

  static Future<void> sharePdf(String title, List<ChatMessage> messages) async {
    final bytes = await buildPdfBytes(title, messages);
    final tempDir = await getTemporaryDirectory();
    final fileName = '${_safeFileName(title)}.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Exported from Tri Ai');
  }
}
