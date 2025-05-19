import 'navigable_pokemon.dart';

class PokemonListApiResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<NavigablePokemon> results;

  PokemonListApiResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PokemonListApiResponse.fromJson(Map<String, dynamic> json) {
    final list =
        (json['results'] as List)
            .map((e) => NavigablePokemon.fromJson(e))
            .toList();
    return PokemonListApiResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: list,
    );
  }
}
