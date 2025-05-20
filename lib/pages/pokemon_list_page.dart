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
  final ScrollController _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _pokemons.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _pokemons.length) {
            final pokemon = _pokemons[index];
            return ListTile(
              title: Text(
                pokemon.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(pokemon.url, style: const TextStyle(fontSize: 15)),
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
    );
  }
}
