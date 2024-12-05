import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/model/Municipio.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;


class ZonaService extends ChangeNotifier{

  String url = Url().apiUrl;
  String ip = Url().ip;
  List<Municipio> _lista4 = [];
  List<Municipio> get lista114 => _lista4;

/////FECHA SIEMBRA
  Future<List<Map<String, dynamic>>> fetchZonas(int idZona) async {
    final response = await http.get(
      Uri.parse(url + '/cultivos/lista_datos_cultivo/${idZona}'),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al cargar datos meteorológicos');
    }
  }

  Future<List<Map<String, dynamic>>> fetchZonasFechaS() async {
    try {
      final response = await http.get(Uri.parse(url + '/datos_pronostico/lista_zonas'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load zonas');
      }
    } catch (e) {
      print('Error al cargar las zonas: $e');
      throw Exception('Error de red o decodificación');
    }
  }

  Map<String, List<Map<String, dynamic>>> agruparZonasPorMunicipio(List<Map<String, dynamic>> zonas) {
    Map<String, List<Map<String, dynamic>>> agrupadas = {};
    for (var zona in zonas) {
      if (!agrupadas.containsKey(zona['nombreMunicipio'])) {
        agrupadas[zona['nombreMunicipio']] = [];
      }
      agrupadas[zona['nombreMunicipio']]!.add(zona);
    }
    return agrupadas;
  }

  Future<void> getMunicipio() async {
    try {
      final response =
          await http.get(Uri.http(ip, "/zona/vermunicipios"));
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
}



