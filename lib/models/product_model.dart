import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory {
  fashion,
  beauty,
  electronics,
  home,
  sports,
  books,
  food,
  other,
}

enum ProductStatus {
  available,
  outOfStock,
  discontinued,
}

class ProductModel {
  final String productId;
  final String sellerId;
  final String sellerName;
  final String sellerPhotoUrl;
  final String name;
  final String description;
  final List<String> imageUrls;
  final double price;
  final double? originalPrice;
  final String currency;
  final ProductCategory category;
  final ProductStatus status;
  final int stockQuantity;
  final List<String> tags;
  final int soldCount;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.productId,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhotoUrl,
    required this.name,
    this.description = '',
    this.imageUrls = const [],
    required this.price,
    this.originalPrice,
    this.currency = 'USD',
    this.category = ProductCategory.other,
    this.status = ProductStatus.available,
    this.stockQuantity = 0,
    this.tags = const [],
    this.soldCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerPhotoUrl: map['sellerPhotoUrl'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      price: (map['price'] ?? 0.0).toDouble(),
      originalPrice: map['originalPrice'] != null ? (map['originalPrice'] as num).toDouble() : null,
      currency: map['currency'] ?? 'USD',
      category: ProductCategory.values.firstWhere(
        (e) => e.toString() == 'ProductCategory.${map['category']}',
        orElse: () => ProductCategory.other,
      ),
      status: ProductStatus.values.firstWhere(
        (e) => e.toString() == 'ProductStatus.${map['status']}',
        orElse: () => ProductStatus.available,
      ),
      stockQuantity: map['stockQuantity'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      soldCount: map['soldCount'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ProductModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhotoUrl': sellerPhotoUrl,
      'name': name,
      'description': description,
      'imageUrls': imageUrls,
      'price': price,
      'originalPrice': originalPrice,
      'currency': currency,
      'category': category.toString().split('.').last,
      'status': status.toString().split('.').last,
      'stockQuantity': stockQuantity,
      'tags': tags,
      'soldCount': soldCount,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ProductModel copyWith({
    String? productId,
    String? sellerId,
    String? sellerName,
    String? sellerPhotoUrl,
    String? name,
    String? description,
    List<String>? imageUrls,
    double? price,
    double? originalPrice,
    String? currency,
    ProductCategory? category,
    ProductStatus? status,
    int? stockQuantity,
    List<String>? tags,
    int? soldCount,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerPhotoUrl: sellerPhotoUrl ?? this.sellerPhotoUrl,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      status: status ?? this.status,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      tags: tags ?? this.tags,
      soldCount: soldCount ?? this.soldCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAvailable => status == ProductStatus.available && stockQuantity > 0;
  bool get isOutOfStock => status == ProductStatus.outOfStock || stockQuantity == 0;
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  double get discountPercentage => hasDiscount ? ((originalPrice! - price) / originalPrice! * 100) : 0.0;
}

class CartItem {
  final ProductModel product;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.addedAt,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    ProductModel? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class Order {
  final String orderId;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String shippingAddress;
  final String paymentMethod;
  final String status; // pending, processing, shipped, delivered, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.tax = 0.0,
    this.shipping = 0.0,
    required this.total,
    required this.shippingAddress,
    required this.paymentMethod,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem(
                    product: ProductModel.fromMap(item['product']),
                    quantity: item['quantity'] ?? 1,
                    addedAt: (item['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  ))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      shipping: (map['shipping'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      shippingAddress: map['shippingAddress'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items
          .map((item) => {
                'product': item.product.toMap(),
                'quantity': item.quantity,
                'addedAt': Timestamp.fromDate(item.addedAt),
              })
          .toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
