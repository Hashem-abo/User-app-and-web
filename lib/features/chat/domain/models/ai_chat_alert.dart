class AIChatAlert {
  final String id;
  final String type; // 'new_items' or 'discount'
  final int categoryId;
  final String categoryName;
  final DateTime createdAt;

  AIChatAlert({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AIChatAlert.fromJson(Map<String, dynamic> json) => AIChatAlert(
    id: json['id'],
    type: json['type'],
    categoryId: json['categoryId'] is int ? json['categoryId'] : int.parse(json['categoryId'].toString()),
    categoryName: json['categoryName'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
