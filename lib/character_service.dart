import 'dart:convert';

import 'package:http/http.dart' as http;

import 'character.dart';

class CharacterService {
  CharacterService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const baseUrl = 'https://dattebayo-api.onrender.com/characters';

  Future<CharacterPage> fetch({required int page, int limit = 20}) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
      },
    );

    final response = await _client.get(uri).timeout(const Duration(seconds: 90));
    if (response.statusCode != 200) {
      throw Exception('Сервер ответил ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw Exception('Неожиданный ответ сервера');
    }

    final rawList = data['characters'];
    final characters = rawList is List
        ? rawList.whereType<Map<String, dynamic>>().map(Character.fromJson).toList()
        : <Character>[];

    return CharacterPage(
      characters: characters,
      currentPage: data['currentPage'] is int ? data['currentPage'] as int : page,
      total: data['total'] is int ? data['total'] as int : characters.length,
    );
  }

  void dispose() {
    _client.close();
  }
}
