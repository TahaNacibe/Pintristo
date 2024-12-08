class TagModel {
  String name;
  int usedCount;

  TagModel({
    required this.name,
    required this.usedCount,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      TagModel(
        name: json["id"] as String,
        usedCount: (json["data"] as Map<String, dynamic>)["used"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": name,
        "data": {"used": usedCount},
      };

 @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          usedCount == other.usedCount;

  @override
  int get hashCode => name.hashCode ^ usedCount.hashCode;

}
