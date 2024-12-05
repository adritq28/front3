import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/model/DatosPronostico.dart';
import 'package:helvetasfront/model/Municipio.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class PronosticoService extends ChangeNotifier {
  List<DatosPronostico> _lista = [];
  List<DatosPronostico> get lista11 => _lista;

  List<DatosPronostico> _lista3 = [];
  List<DatosPronostico> get lista113 => _lista3;

  List<Municipio> _lista4 = [];
  List<Municipio> get lista114 => _lista4;

  //final String url ='http://192.168.1.25:8080'; // Reemplaza con la URL de tu API
  //final String ip ='192.168.1.25:8080';
  String url = Url().apiUrl;
  String ip = Url().ip;

  


  Future<List<String>> fetchAlertas(int cultivoId) async {
    final response = await http
        .get(Uri.parse(url+'/alertas/$cultivoId'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<String> alertas = body.map((dynamic item) => item as String).toList();
      return alertas;
    } else {
      throw Exception('Failed to load alertas');
    }
  }
  

  // Future<String> saveDatosPronostico(DatosPronostico pronostico) async {
  //   try {
  //     final response = await http.post(
  //       Uri.http("localhost:8080", "/datosPronostico/addDatosPronostico"),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(pronostico.toJson()),
  //     );
  //     if (response.statusCode == 201) {
  //       //print('Datos Pronostico guardada correctamente');
  //       //print(response.statusCode);
  //       notifyListeners();
  //       //getDatosPronostico();
  //       return (response.body.toString());
  //     } else {
  //       throw Exception('Error al guardar la persona');
  //     }
  //   } catch (e) {
  //     throw Exception('Errooor222: $e');
  //   }
  // }
  Future<String> saveDatosPronostico(DatosPronostico pronostico) async {
    try {
      final response = await http.post(
        Uri.http(ip, "/datos_pronostico/addDatosPronostico"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(pronostico.toJson()),
      );

      if (response.statusCode == 201) {
        notifyListeners();
        return response.body;
      } else {
        throw Exception('Err222or al guardar el pronóstico: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro222r al guardar el pronóstico: $e');
    }
  }

  Future<List<DatosPronostico>> obtenerDatosPronostico(
      int id, int idZona) async {
    final response = await http
        .get(Uri.parse(url+'/datos_pronostico/$id/$idZona'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      if (jsonData.isEmpty) {
        return []; // Indica que no hay datos
      }
      return jsonData.map((item) => DatosPronostico.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener datos del observador');
    }
  }

  // Future<List<DatosPronostico>> alertas(int idFenologia, int idZona) async {
  //   final response =
  //       await http.get(Uri.parse('http://localhost:8080/datos_pronostico/comparacion/$idFenologia/$idZona'));
  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonData = jsonDecode(response.body);
  //     if (jsonData.isEmpty) {
  //       return []; // Indica que no hay datos
  //     }
  //     return jsonData.map((item) => DatosPronostico.fromJson(item)).toList();
  //   } else {
  //     throw Exception('Error al obtener datos del observador');
  //   }
  // }

  

  Future<List<DatosPronostico>> getListaMetetorologica(int id) async {
    final response = await http.get(Uri.parse(
        url+'/datosPronostico/obtener_Pronostico_meteorologica/$id'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      _lista3 = jsonData.map((e) => DatosPronostico.fromJson(e)).toList();
      notifyListeners();
      if (jsonData.isEmpty) {
        return []; // Indica que no hay datos
      }
      return _lista3;
    } else {
      throw Exception('Error al obtener datos del observador');
    }
  }

  Future<List<int>> fetchUmbralesByZona(int idZona) async {
    final response = await http
        .get(Uri.parse(url+'/datos_pronostico/zona/$idZona'));
    print("aaaaaaaaaaa " + idZona.toString());
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<int>.from(data);
    } else {
      throw Exception('Error al obtener los umbrales');
    }
  }
}
