class Product {
  final int id;
  final String title;
  final double pricePerUnit;

  Product({
    required this.id,
    required this.title,
    required this.pricePerUnit,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'pricePerUnit': pricePerUnit,
    };
  }
}
