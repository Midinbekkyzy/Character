class Character {
  const Character({
    required this.id,
    required this.name,
    this.image,
    this.images = const [],
  });

  final int id;
  final String name;
  final String? image;
  final List<String> images;

  List<String> get photoUrls {
    if (images.isNotEmpty) return images;
    final single = image;
    if (single != null && single.isNotEmpty) return [single];
    return const [];
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final images = <String>[];
    if (rawImages is List) {
      for (final item in rawImages) {
        if (item is String && item.trim().isNotEmpty) {
          images.add(item.trim());
        }
      }
    }

    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;

    return Character(
      id: id,
      name: json['name'] as String? ?? '',
      image: images.isEmpty ? null : images.first,
      images: images,
    );
  }
}

class CharacterPage {
  const CharacterPage({
    required this.characters,
    required this.currentPage,
    required this.total,
  });

  final List<Character> characters;
  final int currentPage;
  final int total;
}
