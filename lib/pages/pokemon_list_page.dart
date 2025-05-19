import 'package:flutter/material.dart';
import '../models/pokemon_list_response.dart';
import '../services/pokemon_api.dart';
import 'pokemon_detail_page.dart';

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key, required this.title});
  final String title;

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  late Future<PokemonListApiResponse> _futureList;
  final _api = PokemonApi();

  @override
  void initState() {
    super.initState();
    _futureList = _api.fetchPokemonList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<PokemonListApiResponse>(
        future: _futureList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final pokemons = snapshot.data!.results;
            return ListView.builder(
              itemCount: pokemons.length,
              itemBuilder: (context, i) {
                final pokemon = pokemons[i];
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
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
