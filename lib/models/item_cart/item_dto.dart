class ItemDto {
  final int itemId;
  final String itemName;
  final int price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final int readyIn;

  const ItemDto({
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isAvailable,
    required this.readyIn,
  });

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return ItemDto(
      itemId: json['itemId'] as int,
      itemName: json['itemName'] as String,
      price: json['price'] as int,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      isAvailable: json['isAvailable'] as bool,
      readyIn: json['readyIn'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'readyIn': readyIn,
    };
  }
}
