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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      quantity: json['quantity'],
      threshold: json['threshold'],
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
