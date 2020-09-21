

import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:async';

import 'package:peliculas/src/models/pelicula_molde.dart';
import 'package:peliculas/src/models/actores_model.dart';

class PeliculasProvider {

  String _apiKey   = 'e6b9c83fcbf8010bbb1d57930c363684';
  String _url      = 'api.themoviedb.org';
  String _languaje = 'es-ES';

  int _popularesPage = 0;
  bool _cargando = false;

  List<Pelicula> _populares = new List();

  final _popularesStreamController = StreamController<List<Pelicula>>.broadcast();


  Function(List<Pelicula>) get popularesSink => _popularesStreamController.sink.add;

  Stream<List<Pelicula>> get popularesStream => _popularesStreamController.stream;


  void disposeStream() {
    _popularesStreamController?.close();
  }



  Future<List<Pelicula>> _procesarRespuesta( Uri url) async {

    final resp = await http.get( url );
    final decodedData = json.decode( resp.body );

    final peliculas = new Peliculas.fromJsonList( decodedData['results'] );
    // print(peliculas.items[1].title);

    return peliculas.items;
  }


  Future<List<Pelicula>> getEnCines() async {

    final url = Uri.https(_url, '3/movie/now_playing', {
      'api_key': _apiKey,
      'language': _languaje
    });

    return await  _procesarRespuesta(url);
  }


  Future<List<Pelicula>> getPopulares() async {

    if ( _cargando ) return [];

    _cargando = true;

    _popularesPage++;

    final url = Uri.https(_url, '3/movie/popular', {
      'api_key' : _apiKey,
      'language': _languaje,
      'page'    : _popularesPage.toString()
    });

    final resp = await _procesarRespuesta(url);

    _populares.addAll(resp);
    popularesSink( _populares );

    _cargando = false;

    return resp;
  }


  Future<List<Actor>> getCast( String pelId ) async {
    final url = Uri.https(_url, '3/movie/${pelId}/credits', {
      'api_key' : _apiKey,
      'language': _languaje
    });

    final resp = await http.get(url);
    final decodeData = json.decode(resp.body);

    final cast = new Cast.fromJsonList(decodeData['cast']);

    return cast.actores;
  }


  Future<List<Pelicula>> buscarPelicula( String query) async {

    final url = Uri.https(_url, '3/search/movie', {
      'api_key': _apiKey,
      'language': _languaje,
      'query' : query
    });

    return await  _procesarRespuesta(url);
  }  
}