class AlgorithmItem {
  final String id;
  final String title;
  final String category;
  final String notes;
  final String imageBase64;

  const AlgorithmItem({
    required this.id,
    required this.title,
    required this.category,
    required this.notes,
    required this.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'notes': notes,
      'imageBase64': imageBase64,
    };
  }

  factory AlgorithmItem.fromJson(Map<String, dynamic> json) {
    return AlgorithmItem(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      notes: (json['notes'] as String?) ?? '',
      imageBase64: json['imageBase64'] as String,
    );
  }
}
