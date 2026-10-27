import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/details/screens/product_details_screen.dart';

class DeepLinkService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;
  static String? _pendingProductId;

  static String? get pendingProductId => _pendingProductId;

  static const String webBaseUrl = "https://humavolve.com/product";
  static const String customSchemeBase = "humavolve://product";

  static Future<void> init() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint("DeepLinkService: Initial URI received: $initialUri");
        _handleUri(initialUri, isColdStart: true);
      }
    } catch (e) {
      debugPrint("DeepLinkService: Error fetching initial link: $e");
    }
    _linkSubscription?.cancel();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debugPrint("DeepLinkService: Stream URI received: $uri");
        _handleUri(uri, isColdStart: false);
      },
      onError: (err) {
        debugPrint("DeepLinkService: Stream error: $err");
      },
    );
  }

  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  static void _handleUri(Uri uri, {required bool isColdStart}) {
    final productId = extractProductId(uri);
    if (productId != null && productId.isNotEmpty) {
      if (isColdStart) {
        _pendingProductId = productId;
      } else {
        navigateToProduct(productId);
      }
    }
  }

  static String? extractProductId(Uri uri) {
    if (uri.queryParameters.containsKey('id')) {
      return uri.queryParameters['id'];
    }
    if (uri.queryParameters.containsKey('productId')) {
      return uri.queryParameters['productId'];
    }

    final segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      final productIdx = segments.indexWhere(
        (s) =>
            s.toLowerCase() == 'product' ||
            s.toLowerCase() == 'products' ||
            s.toLowerCase() == 'product-details',
      );
      if (productIdx != -1 && productIdx + 1 < segments.length) {
        return segments[productIdx + 1];
      }

      if (uri.host.toLowerCase() == 'product') {
        return segments.first;
      }
    } else if (uri.host.toLowerCase() == 'product' && uri.path.isNotEmpty) {
      final clean = uri.path.replaceAll('/', '').trim();
      if (clean.isNotEmpty) return clean;
    }

    return null;
  }

  static void navigateToProduct(String productId) {
    final navState = navigatorKey.currentState;
    if (navState == null) {
      _pendingProductId = productId;
      return;
    }

    _pendingProductId = null;
    navState.push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(productId: productId),
      ),
    );
  }

  static void processPendingLink() {
    if (_pendingProductId != null) {
      final id = _pendingProductId!;
      _pendingProductId = null;
      navigateToProduct(id);
    }
  }

  static String buildProductLink(String productId) {
    return "$webBaseUrl/$productId";
  }

  static Future<void> shareProduct({
    required String productId,
    required String title,
    double? price,
  }) async {
    final link = buildProductLink(productId);
    final priceStr = price != null ? ' - \$${price.toStringAsFixed(2)}' : '';
    final message =
        'Check out this product on Huma-volve:\n$title$priceStr\n\n$link';

    await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: title,
      ),
    );
  }
}
