class PokemonDetailApiResponse {
  final int id;
  final String name;
  final int height;
  final int weight;
  final String imageUrl;
  final List<String> types;

  PokemonDetailApiResponse({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.imageUrl,
    required this.types,
  });

  factory PokemonDetailApiResponse.fromJson(Map<String, dynamic> json) =>
      PokemonDetailApiResponse(
        id: json['id'],
        name: json['name'],
        height: json['height'],
        weight: json['weight'],
        imageUrl: json['sprites']['front_default'],
        types:
            (json['types'] as List)
                .map((e) => e['type']['name'] as String)
                .toList(),
      );
}
