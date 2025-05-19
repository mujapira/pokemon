import 'package:flutter/material.dart';
import '../models/pokemon_detail_response.dart';
import '../services/pokemon_api.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PokemonDetailPage extends StatefulWidget {
  final String url;
  const PokemonDetailPage({super.key, required this.url});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late Future<PokemonDetailApiResponse> _futureDetail;
  final _api = PokemonApi();

  @override
  void initState() {
    super.initState();
    _futureDetail = _api.fetchPokemonDetails(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokemon Details')),
      body: FutureBuilder<PokemonDetailApiResponse>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final p = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: p.imageUrl,
                    placeholder:
                        (ctx, url) => const CircularProgressIndicator(),
                    errorWidget:
                        (ctx, url, error) => const Icon(Icons.error_outline),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Height: ${p.height}',
                    style: const TextStyle(fontSize: 22),
                  ),
                  Text(
                    'Weight: ${p.weight}',
                    style: const TextStyle(fontSize: 22),
                  ),
                  Text(
                    'Types: ${p.types.join(', ')}',
                    style: const TextStyle(fontSize: 22),
                  ),
                ],
              ),
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
