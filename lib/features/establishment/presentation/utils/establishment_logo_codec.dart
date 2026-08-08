import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Compresse une image choisie pour stockage Firestore + ticket 58mm.
abstract final class EstablishmentLogoCodec {
  static const maxWidth = 384;
  static const jpegQuality = 70;

  static String encodeForStorage(Uint8List sourceBytes) {
    final decoded = img.decodeImage(sourceBytes);
    if (decoded == null) {
      throw StateError('Image illisible. Choisissez un autre fichier.');
    }

    final resized = decoded.width > maxWidth
        ? img.copyResize(
            decoded,
            width: maxWidth,
            interpolation: img.Interpolation.linear,
          )
        : decoded;

    final jpeg = img.encodeJpg(resized, quality: jpegQuality);
    return base64Encode(jpeg);
  }

  static img.Image? decodeForPrint(String? logoBase64) {
    final raw = logoBase64?.trim();
    if (raw == null || raw.isEmpty) return null;
    try {
      final bytes = base64Decode(raw);
      final decoded = img.decodeImage(Uint8List.fromList(bytes));
      if (decoded == null) return null;
      if (decoded.width <= maxWidth) return decoded;
      return img.copyResize(
        decoded,
        width: maxWidth,
        interpolation: img.Interpolation.linear,
      );
    } catch (_) {
      return null;
    }
  }
}
