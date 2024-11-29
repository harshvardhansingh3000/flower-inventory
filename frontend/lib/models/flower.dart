class Flower {
  final int id;
  final String name;
  final String description;
  final int quantity;
  final int threshold;
  Flower({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.threshold,
  });

  // Factory method to create a Flower object from JSON data
  factory Flower.fromJson(Map<String, dynamic> json) {
    return Flower(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      threshold: json['threshold'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'threshold': threshold,
    };
  }
}
