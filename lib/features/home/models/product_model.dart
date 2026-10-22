import 'package:ecommerce_app_huma_volve/features/home/models/categories_model.dart';

class ProductModel {
  int? id;
  String? title;
  num? price;
  String? description;
  List<String>? images;
  CategoryModel? category;

  ProductModel({
    this.id,
    this.title,
    this.price,
    this.description,
    this.images,
    this.category,
  
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json["id"],
        title: json["title"],
        price: json["price"],
        description: json["description"],
        images: json["images"] != null
            ? List<String>.from(
                (json["images"] as List).map((x) => x.toString()))
            : null,
        category: json["category"] != null
            ? CategoryModel.fromJson(json["category"])
            : null,
     
      );

 
}

