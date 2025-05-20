import 'package:flutter/material.dart';
import 'package:pokemao/models/navigable_pokemon.dart';
import '../services/pokemon_api.dart';
import 'pokemon_detail_page.dart';

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key, required this.title});
  final String title;

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  final List<NavigablePokemon> _pokemons = [];
  final List<NavigablePokemon> _searchResults = [];

  final ScrollController _scrollController = ScrollController();

  String _searchText = '';
  bool _isSearching = false;

  bool _isLoading = false;
  bool _hasMore = true;
  int _limit = 20;
  int _offset = 0;

  final _api = PokemonApi();

  @override
  void initState() {
    super.initState();

    _loadPokemons();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.8 &&
          !_isLoading &&
          _hasMore) {
        _loadPokemons();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPokemons() async {
    setState(() => _isLoading = true);

    try {
      final response = await _api.fetchPokemonList(
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        _offset += _limit;
        _pokemons.addAll(response.results);
        _hasMore = response.next != null;
      });
    } catch (e) {
      debugPrint('Erro ao carregar pokemons: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    final name = query.trim().toLowerCase();

    if (name.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
    }

    try {
      final results = await _api.searchPokemons(name);
      setState(() {
        _searchResults
          ..clear()
          ..addAll(results);
      });
    } catch (e) {
      debugPrint('Erro ao buscar pokemons $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFiltering = _searchText.isNotEmpty;
    final displayList = isFiltering ? _searchResults : _pokemons;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "buscar pokemon por nome",
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _isSearching
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchText = value);
                _performSearch(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: displayList.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < displayList.length) {
                  final pokemon = displayList[index];
                  return ListTile(
                    title: Text(
                      pokemon.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      pokemon.url,
                      style: const TextStyle(fontSize: 15),
                    ),
                    trailing: ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          Colors.purpleAccent,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PokemonDetailPage(url: pokemon.url),
                          ),
                        );
                      },
                      child: const Text(
                        'Ver mais',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
