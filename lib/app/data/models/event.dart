class Event {
  String id;
  String name;
  String imageUrl;
  bool isFavorite;

  Event({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.isFavorite = false,
  });

  factory Event.fromJson(Map<String, dynamic> map) {
    Map<String, dynamic> json = Map<String, dynamic>.from(map);
    return Event(
      id: json["id"],
      name: json["name"],
      imageUrl: json["image_url"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image_url": imageUrl,
      };
}
