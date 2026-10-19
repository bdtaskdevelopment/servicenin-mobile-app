import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

/// Renders admin-authored rich text — a Home Service category's
/// Description/Terms & Conditions, or an FAQ's answer — which the admin
/// panel's Quill editor saves and the API returns as HTML (e.g.
/// `<p><strong>Bold</strong> text</p>`).
///
/// Plugged in wherever one of those fields used to go straight into a
/// plain `Text(...)` widget, which showed the raw tags on screen instead
/// of formatted text. `text` may also be empty/plain (no markup at all,
/// e.g. older rows saved before the rich-text editor existed) — rendering
/// plain text through this widget is harmless, it just shows as-is.
class RichHtmlText extends StatelessWidget {
  const RichHtmlText(
    this.html, {
    super.key,
    this.style = const TextStyle(
        fontSize: 13.5, height: 1.5, color: Color(0xFF334155)),
  });

  final String html;

  /// Base style every tag's own formatting (bold/italic/underline/links)
  /// layers on top of — matches the plain-Text() style this widget
  /// replaces at each call site, so swapping it in doesn't change the
  /// page's look beyond actually rendering the markup.
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      _normalizeQuillHtml(html),
      textStyle: style,
    );
  }
}

/// Quill (the admin panel's editor) writes text alignment as a CSS class
/// — `<p class="ql-align-center">…</p>` — rather than an inline style.
/// flutter_widget_from_html only understands inline `style="..."`
/// attributes, so without this it silently drops the alignment (content
/// still renders correctly, just always left-aligned). This rewrites the
/// three alignment classes Quill's toolbar can produce into the
/// equivalent inline style before handing the HTML to the widget.
String _normalizeQuillHtml(String html) {
  if (!html.contains('ql-align-')) return html;
  return html
      .replaceAll('class="ql-align-center"', 'style="text-align:center"')
      .replaceAll('class="ql-align-right"', 'style="text-align:right"')
      .replaceAll('class="ql-align-justify"', 'style="text-align:justify"');
}
