import 'app_localizations.dart';

/// Maps known English network/API error strings (thrown from Dio and
/// service layers, which have no BuildContext) onto localized copy.
String localizedError(AppLocalizations l10n, Object error) {
  var text = error.toString();
  if (text.startsWith('Exception: ')) {
    text = text.substring('Exception: '.length);
  }

  if (text.contains('Connection timeout') ||
      text.contains('connect timeout') ||
      text.contains('connectionTimeout')) {
    return l10n.errorConnectionTimeout;
  }
  if (text.contains('Request timeout') || text.contains('sendTimeout')) {
    return l10n.errorRequestTimeout;
  }
  if (text.contains('Response timeout') || text.contains('receiveTimeout')) {
    return l10n.errorResponseTimeout;
  }
  if (text.contains('No internet') || text.contains('connectionError')) {
    return l10n.errorNoInternet;
  }
  if (text.contains('Rate limit exceeded')) {
    return l10n.errorRateLimit;
  }
  if (text.contains('Unauthorized')) {
    return l10n.errorUnauthorized;
  }
  if (text.contains('Forbidden')) {
    return l10n.errorForbidden;
  }
  if (text.contains('not found') || text.contains('Not found')) {
    return l10n.errorNotFound;
  }
  if (text.contains('Internal server error')) {
    return l10n.errorInternalServer;
  }
  if (text.contains('Server error') || text.contains('Server Error')) {
    return l10n.errorServerError;
  }
  if (text.contains('Request was cancelled') ||
      text.contains('Request cancelled')) {
    return l10n.errorRequestCancelled;
  }

  final statusMatch = RegExp(r'status:?\s*(\d{3})').firstMatch(text);
  if (statusMatch != null) {
    return l10n.errorRequestFailedWithStatus(statusMatch.group(1)!);
  }
  final bracketStatus = RegExp(r'\[(\d{3})\]').firstMatch(text);
  if (bracketStatus != null) {
    return l10n.errorRequestFailedWithStatus(bracketStatus.group(1)!);
  }

  if (text.contains('unexpected error') ||
      text.contains('unknown error') ||
      text.contains('An unknown error')) {
    return l10n.errorUnknown;
  }

  return text;
}
