import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokemao/models/navigable_pokemon.dart';
import '../models/pokemon_list_response.dart';
import '../models/pokemon_detail_response.dart';
import '../utils/debounce.dart';

class PokemonApi {
  static const _baseUrl = 'https://pokeapi.co/api/v2';
  static const _buscarUrl = 'https://beta.pokeapi.co/graphql/v1beta';
  final _debounce = AppDebounce();

  Future<PokemonListApiResponse> fetchPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final completer = Completer<PokemonListApiResponse>();
    final url = '$_baseUrl/pokemon?limit=$limit&offset=$offset';

    _debounce.call(() async {
      try {
        final res = await http.get(Uri.parse(url));

        if (res.statusCode == 200) {
          final listResponse = PokemonListApiResponse.fromJson(
            jsonDecode(res.body),
          );
          completer.complete(listResponse);
        } else {
          completer.completeError(
            Exception(
              'Failed to fetch Pokemon list (statusCode: ${res.statusCode})',
            ),
          );
        }
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  Future<PokemonDetailApiResponse> fetchPokemonDetails(String url) {
    final completer = Completer<PokemonDetailApiResponse>();

    _debounce.call(() async {
      try {
        final res = await http.get(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'PokemonMaurico/1.0',
          },
        );

        if (res.statusCode == 200) {
          final detail = PokemonDetailApiResponse.fromJson(
            jsonDecode(res.body),
          );
          completer.complete(detail);
        } else {
          completer.completeError(
            Exception(
              'Failed to fetch Pokemon details (statusCode: ${res.statusCode})',
            ),
          );
        }
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
  }

  Future<List<NavigablePokemon>> searchPokemons(String name) async {
    final endpoint = Uri.parse(_buscarUrl);
    // raw string r'''
    const graphqlQuery = r'''
 query search($like: String!) {
pokemon_v2_pokemon(where: { name: { _like: $like } }) {
 id
 name
 }
 }
 ''';
    final variables = {'like': '%${name.toLowerCase()}%'};
    final body = jsonEncode({'query': graphqlQuery, 'variables': variables});
    final res = await http.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (res.statusCode != 200) {
      throw Exception('Erro na busca: status ${res.statusCode}');
    }
    final data = jsonDecode(res.body)['data']['pokemon_v2_pokemon'] as List;
    return data.map((item) {
      final id = item['id'];
      final pname = item['name'] as String;
      return NavigablePokemon(
        name: pname,
        url: 'https://pokeapi.co/api/v2/pokemon/$id',
      );
    }).toList();
  }
}
