class BoardModel {
  String name;
  String boardId;
  String cover;
  bool isSecret;
  List<String> postsIds;
  List<String> contributors;

  BoardModel({
    required this.name,
    required this.boardId,
    required this.cover,
    required this.isSecret,
    required this.postsIds,
    required this.contributors,
  });

  //* from json formate
  Map<String, dynamic> toJson() => {
        "name": name,
        "boardId": boardId,
        "isSecret": isSecret,
        "cover": cover,
        "postsIds": postsIds,
        "contributors":contributors,
      };

  //* to json formate
  factory BoardModel.fromJson(Map<String, dynamic> json) => BoardModel(
      name: json["name"],
      cover: json["cover"] ?? "",
      boardId: json["boardId"],
      postsIds: List<String>.from(json["postsIds"]),
      contributors: List<String>.from(json["contributors"]),
      isSecret: json["isSecret"]);
}
