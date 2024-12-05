import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/model/Municipio.dart';
import 'package:helvetasfront/model/Zona.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class MunicipioService extends ChangeNotifier {
  List<Municipio> _lista = [];

  List<Municipio> get lista11 => _lista;
  List<Municipio> _lista5 = [];
  List<Municipio> get lista115 => _lista5;

  //final String url = 'http://192.168.1.25:8080'; // Reemplaza con la URL de tu API
  String url = Url().apiUrl;
  String ip = Url().ip;
  
  List<String> _cultivos = [];
  List<String> get cultivos => _cultivos;

  List<Zona> _zonas = [];
  List<Zona> get zonas => _zonas;

  List<String> _municipios = [];
  String? _selectedCultivo;
  String? _selectedMunicipio;
  List<String> get municipios => _municipios;

  Future<String?> obtenerTelefono(int idUsuario) async {
    final response = await http.get(Uri.parse(url+'/usuario/telefono/$idUsuario'));
    if (response.statusCode == 200) {
      return response
          .body; // Asumiendo que el teléfono se devuelve como texto plano
    } else {
      throw Exception('Error al obtener el teléfono');
    }
  }

  Future<void> obtenerZonas(int id) async {
    try {
      final response =
          await http.get(Uri.parse(url+'/municipio/zona/$id'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _lista = data.map((e) => Municipio.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

}
