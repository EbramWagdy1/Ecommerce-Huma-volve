import 'package:ecommerce_app_huma_volve/features/home/data/models/categories_model.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/home_product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    super.id,
    super.title,
    super.price,
    super.description,
    super.images,
    super.category,
  });

  factory ProductModel.fromJson(Map<dynamic, dynamic> json) => ProductModel(
        id: json["id"] is num ? (json["id"] as num).toInt() : int.tryParse(json["id"]?.toString() ?? ''),
        title: json["title"]?.toString(),
        price: json["price"] is num ? json["price"] as num : num.tryParse(json["price"]?.toString() ?? ''),
        description: json["description"]?.toString(),
        images: _parseImages(json["images"]),
        category: json["category"] is Map
            ? CategoryModel.fromJson(json["category"] as Map)
            : null,
      );

  static String _stripJunk(String input) {
    return input
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll(r'\', '')
        .trim();
  }

  static List<String> _parseImages(dynamic rawImages) {
    if (rawImages == null) return [];
    final List<dynamic> list;
    if (rawImages is List) {
      list = rawImages;
    } else if (rawImages is String) {
      list = [rawImages];
    } else {
      return [];
    }

    final List<String> sanitizedImages = [];
    for (final item in list) {
      if (item == null) continue;
      final String str = _stripJunk(item.toString());

      // In case multiple comma-separated URLs were squashed into one string
      final parts = str.contains(',') ? str.split(',') : [str];
      for (final part in parts) {
        final clean = cleanUrl(part);
        if (clean.isNotEmpty && !sanitizedImages.contains(clean)) {
          sanitizedImages.add(clean);
        }
      }
    }
    return sanitizedImages;
  }

  static String cleanUrl(String? rawUrl) {
    if (rawUrl == null) return '';
    String url = _stripJunk(rawUrl);

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return '';
    }

    // Fix placehold.co SVG issue: Flutter cannot render SVG with Image.network
    // Appending .png before any query params instructs placehold.co to return PNG
    if (url.contains('placehold.co')) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        String path = uri.path;
        if (!path.endsWith('.png') &&
            !path.endsWith('.jpg') &&
            !path.endsWith('.jpeg')) {
          path = '$path.png';
          url = uri.replace(path: path).toString();
        }
      }
    }

    return url;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
        "description": description,
        "images": images,
        "category": category != null && category is CategoryModel
            ? (category as CategoryModel).toJson()
            : null,
      };
}
