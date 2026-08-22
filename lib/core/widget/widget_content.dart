import 'widget_content_kind.dart';

/// The three text lines rendered on the widget for one [WidgetContentKind] —
/// shared shape between what gets pushed to the native widgets and what the
/// in-app preview (WidgetCustomizationPage) renders, so they can never drift
/// apart.
class WidgetContent {
  final WidgetContentKind kind;
  final String kicker;
  final String primary;
  final String secondary;

  const WidgetContent({
    required this.kind,
    required this.kicker,
    required this.primary,
    required this.secondary,
  });
}
