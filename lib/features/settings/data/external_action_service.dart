import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Performs the Settings actions that leave the app.
///
/// Kept behind an interface so screens can be tested without touching the
/// platform, and so a failed or unsupported action can be reported to the user
/// instead of crashing.
abstract interface class ExternalActionService {
  /// Opens [uri] in the browser or the app that handles it.
  Future<bool> openUrl(Uri uri);

  /// Opens the user's email app with a pre-filled message.
  Future<bool> sendEmail({
    required String address,
    required String subject,
    required String body,
  });

  /// Opens the platform share sheet.
  ///
  /// [sharePositionOrigin] anchors the popover on iPad and macOS; it is
  /// ignored elsewhere.
  Future<bool> shareText({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  });
}

class PlatformExternalActionService implements ExternalActionService {
  const PlatformExternalActionService();

  @override
  Future<bool> openUrl(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> sendEmail({
    required String address,
    required String subject,
    required String body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: address,
      query: _encodeQuery({'subject': subject, 'body': body}),
    );
    try {
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> shareText({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    try {
      // The sheet opening is the outcome we report. share_plus cannot tell on
      // every platform whether the user completed or dismissed the share, so a
      // dismissed sheet is not treated as a failure.
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: subject,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Percent-encodes mailto parameters.
  ///
  /// [Uri.queryParameters] encodes spaces as `+`, which several mail clients
  /// render literally in the subject line.
  String _encodeQuery(Map<String, String> parameters) {
    return parameters.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}='
              '${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }
}
