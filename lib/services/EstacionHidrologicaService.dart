import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/model/DatosEstacion.dart';
import 'package:helvetasfront/model/DatosEstacionHidrologica.dart';
import 'package:helvetasfront/model/Municipio.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class EstacionHidrologicaService extends ChangeNotifier {
  List<DatosEstacionHidrologica> _lista = [];
  List<DatosEstacionHidrologica> get lista11 => _lista;

  List<DatosEstacionHidrologica> _lista3 = [];
  List<DatosEstacionHidrologica> get lista113 => _lista3;

  List<Municipio> _lista4 = [];
  List<Municipio> get lista114 => _lista4;

  List<DatosEstacion> _lista5 = [];
  List<DatosEstacion> get lista115 => _lista5;

  //final String url = 'http://192.168.1.25:8080';
  //final String ip = '192.168.1.25:8080';

  String url = Url().apiUrl;
  String ip = Url().ip;

  Future<String> saveDatosEstacionHidrologica(
      DatosEstacionHidrologica estacion) async {
    try {
      final response = await http.post(
        Uri.http(ip, "/datosHidrologica/addDatosHidrologica"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(estacion.toJson()),
      );
      if (response.statusCode == 201) {
        //print('Datos Estacion guardada correctamente');
        //print(response.statusCode);
        notifyListeners();
        //getDatosEstacion();
        return (response.body.toString());
      } else {
        throw Exception('Error al guardar la persona');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<DatosEstacionHidrologica>> obtenerDatosHidrologica(int id) async {
    final response = await http.get(Uri.parse(
        url+'/datosHidrologica/listaHidrologica/$id'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      if (jsonData.isEmpty) {
        return []; // Indica que no hay datos
      }
      return jsonData
          .map((item) => DatosEstacionHidrologica.fromJson(item))
          .toList();
    } else {
      throw Exception('Error al obtener datos de la estacion hidrologica');
    }
  }

  Future<List<DatosEstacionHidrologica>> obtenerListaHidrologica(int id) async {
    final response = await http.get(
        Uri.parse(url+'/datosHidrologica/hidrologica/$id'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      if (jsonData.isEmpty) {
        return []; // Indica que no hay datos
      }
      return jsonData
          .map((item) => DatosEstacionHidrologica.fromJson(item))
          .toList();
    } else {
      throw Exception('Error al obtener datos de la estacion hidrologica');
    }
  }

  Future<List<DatosEstacionHidrologica>> getListaHidrologica(int id) async {
    final response = await http.get(
        Uri.parse(url+'/datosHidrologica/hidrologica/$id'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      _lista3 =
          jsonData.map((e) => DatosEstacionHidrologica.fromJson(e)).toList();
      notifyListeners();
      if (jsonData.isEmpty) {
        return []; // Indica que no hay datos
      }
      return _lista3;
    } else {
      throw Exception('Error al obtener datos del observadooooooooor');
    }
  }

  Future<List<DatosEstacion>> obtenerDatosMunicipio(int id) async {
    print("jjjjjjjjjjjjjjjj");
    final response = await http.get(
        Uri.parse(url+'/datosEstacion/datos_municipio/$id'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      _lista5 = jsonData.map((item) => DatosEstacion.fromJson(item)).toList();
      if (jsonData.isEmpty) {
        return []; // Indica que no hay datos
      }
      return _lista5;
    } else {
      throw Exception('Error al obtener datos del observador2222211--2222');
    }
  }

  Future<void> getMunicipio() async {
    try {
      final response = await http
          .get(Uri.http(ip, "/datosEstacion/vermunicipios"));
      //print('aaaaaaaa');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        _lista4 = data.map((e) => Municipio.fromJson(e)).toList();
        print('3333333' + _lista4.length.toString());

        //return datosEstacion;
        notifyListeners();
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> getDatos() async {
    try {
      final response = await http
          .get(Uri.http(ip, "/datosEstacion/verDatosEstacion"));
      //print('aaaaaaaa');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        _lista3 =
            data.map((e) => DatosEstacionHidrologica.fromJson(e)).toList();
        print('3333333' + _lista.length.toString());

        //return datosEstacion;
        notifyListeners();
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
