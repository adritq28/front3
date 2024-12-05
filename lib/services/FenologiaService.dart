import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/model/DatosPronostico.dart';
import 'package:helvetasfront/model/Fenologia.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class FenologiaService extends ChangeNotifier {
  List<Fenologia> _lista = [];
  List<DatosPronostico> _lista2 = [];
  List<DatosPronostico> _lista3 = [];
  List<Fenologia> get lista11 => _lista;
  //List<DatosPronostico> get lista112 => _lista2;
  List<DatosPronostico> get lista112 => _lista2;
  List<Fenologia> _lista5 = [];
  List<Fenologia> get lista115 => _lista5;
  String url = Url().apiUrl;
  String ip = Url().ip;
  int _faseActual = 0;
  int get faseActual => _faseActual;

  Future<List<DatosPronostico>> pronosticoCultivo(int idCultivo) async {
    final response = await http
        .get(Uri.parse(url + '/datos_pronostico/registro/$idCultivo'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      if (jsonData.isEmpty) {
        return [];
      }
      return jsonData.map((item) => DatosPronostico.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener datos del observador');
    }
  }

  Future<void> obtenerPronosticosFase(int cultivoId) async {
    final response =
        await http.get(Uri.parse(url + '/alertas/pronostico_fase/$cultivoId'));

    if (response.statusCode == 200) {
      // Si la solicitud fue exitosa, parseamos la respuesta
      // List<dynamic> jsonData = json.decode(response.body);
      // return jsonData.map((data) => DatosPronostico.fromJson(data)).toList();

      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      _lista2 = data.map((e) => DatosPronostico.fromJson(e)).toList();
      notifyListeners();
    } else {
      throw Exception('Error al obtener los pronósticos');
    }
  }

  Future<void> fase(int cultivoId) async {
    final response =
        await http.get(Uri.parse(url + '/alertas/fase/$cultivoId'));

    if (response.statusCode == 200) {
      // Decodificamos la respuesta como un número.
      final int faseActual = json.decode(utf8.decode(response.bodyBytes));

      // Almacena el número de fase actual en una variable o úsalo como necesites.
      _faseActual = faseActual;
      print(_faseActual);
      notifyListeners();
    } else {
      throw Exception('Error al obtener la fase actual');
    }
  }

  Future<void> obtenerFenologia(int idCultivo) async {
    try {
      final response =
          await http.get(Uri.parse(url + '/fenologia/verFenologia/$idCultivo'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _lista = data.map((e) => Fenologia.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPcpnFase(int cultivoId) async {
    final response =
        await http.get(Uri.parse(url + '/alertas/pcpnFase/$cultivoId'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> fetchUltimaAlerta(int cultivoId) async {
    final url2 = Uri.parse(url + '/alertas/ultima/$cultivoId');
    try {
      final response = await http.get(url2);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load alert: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching alert: $e');
    }
  }
}
