/// stripHtmlTags turns admin-authored rich text (a Home Service category's
/// Description — written via the admin panel's Quill editor, delivered as
/// HTML, e.g. `<p><strong>Bold</strong> text</p>`) into plain text for
/// compact, single-line previews — a card subtitle, a list row — where
/// there's no room to render real formatting and showing the raw tags
/// would look broken. Full Description/Terms/FAQ content on a dedicated
/// detail screen should render through RichHtmlText instead (see
/// lib/app/global_widget/rich_html_text.dart) so bold/italic/lists still
/// show as formatting there, not as plain stripped text.
///
/// Deliberately crude (no entity decoding beyond the handful HTML authors
/// actually produce) — good enough for a preview string, and harmless if
/// the input has no markup at all (older rows saved before the rich-text
/// editor existed, or any other plain string passed through by mistake).
String stripHtmlTags(String html) {
  if (!html.contains('<')) return html;
  final withoutTags = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
  return withoutTags
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
