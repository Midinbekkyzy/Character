import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'character.dart';
import 'character_service.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key, this.service});

  final CharacterService? service;

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  late final CharacterService _service;
  late final bool _ownsService;
  final _scroll = ScrollController();
  final _items = <Character>[];

  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ownsService = widget.service == null;
    _service = widget.service ?? CharacterService();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    if (_ownsService) _service.dispose();
    super.dispose();
  }

  void _pinItachi() {
    final index = _items.indexWhere(
      (character) => character.name.toLowerCase().contains('itachi'),
    );
    if (index <= 0) return;
    final itachi = _items.removeAt(index);
    _items.insert(0, itachi);
  }

  void _onScroll() {
    if (!_scroll.hasClients || _loading || !_hasMore) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 280) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.fetch(page: _page);
      if (!mounted) return;
      setState(() {
        _items.addAll(result.characters);
        _pinItachi();
        _page = result.currentPage + 1;
        _hasMore = _items.length < result.total && result.characters.isNotEmpty;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Не удалось загрузить персонажей';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Characters',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 84, 5, 5),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty && _error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Повторить')),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _CharacterCard(character: _items[index]),
              childCount: _items.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _footer()),
      ],
    );
  }

  Widget _footer() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: TextButton(onPressed: _load, child: const Text('Повторить')),
        ),
      );
    }
    return const SizedBox(height: 12);
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(26, 219, 218, 233),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _CharacterPhoto(
                key: ValueKey(character.id),
                urls: character.photoUrls,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Text(
                character.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF24182F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterPhoto extends StatefulWidget {
  const _CharacterPhoto({super.key, required this.urls});

  final List<String> urls;

  @override
  State<_CharacterPhoto> createState() => _CharacterPhotoState();
}

class _CharacterPhotoState extends State<_CharacterPhoto> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (_index >= widget.urls.length) {
      return const ColoredBox(
        color: Color.fromARGB(255, 250, 249, 249),
        child: Center(child: _MissingPhoto()),
      );
    }

    return ColoredBox(
      color: const Color.fromARGB(255, 250, 249, 249),
      child: SizedBox.expand(
        child: Image.network(
          widget.urls[_index],
          fit: BoxFit.cover,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            );
          },
          errorBuilder: (context, error, stack) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _index >= widget.urls.length) return;
              setState(() => _index++);
            });
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MissingPhoto extends StatelessWidget {
  const _MissingPhoto();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.person, size: 42, color: Color(0xFF8C3A3A));
  }
}
