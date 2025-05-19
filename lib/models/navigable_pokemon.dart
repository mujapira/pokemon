class NavigablePokemon {
  final String name;
  final String url;

  NavigablePokemon({required this.name, required this.url});

  factory NavigablePokemon.fromJson(Map<String, dynamic> json) =>
      NavigablePokemon(name: json['name'], url: json['url']);
}
