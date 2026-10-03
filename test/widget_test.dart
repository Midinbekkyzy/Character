import 'package:character_list/character.dart';
import 'package:character_list/character_service.dart';
import 'package:character_list/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads name and first image from the API json', () {
    final character = Character.fromJson({
      'id': 1344,
      'name': 'Naruto Uzumaki',
      'images': [
        'https://example.com/naruto.png',
        'https://example.com/naruto-2.png',
      ],
    });

    expect(character.name, 'Naruto Uzumaki');
    expect(character.image, 'https://example.com/naruto.png');
  });

  testWidgets('shows character name from the list', (tester) async {
    await tester.pumpWidget(CharacterApp(service: _FakeCharacterService()));
    await tester.pumpAndSettle();

    expect(find.text('Characters'), findsOneWidget);
    expect(find.text('Naruto Uzumaki'), findsOneWidget);
  });
}

class _FakeCharacterService extends CharacterService {
  @override
  Future<CharacterPage> fetch({required int page, int limit = 20}) async {
    return const CharacterPage(
      characters: [
        Character(id: 1344, name: 'Naruto Uzumaki'),
      ],
      currentPage: 1,
      total: 1,
    );
  }

  @override
  void dispose() {}
}
