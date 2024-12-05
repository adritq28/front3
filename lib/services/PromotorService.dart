import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/model/Promotor.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class PromotorService extends ChangeNotifier {
  List<Promotor> _lista = [];

  List<Promotor> get lista11 => _lista;

  //final String url ='http://192.168.1.25:8080'; // Reemplaza con la URL de tu API
  //final String ip ='192.168.1.25:8080';
  String url = Url().apiUrl;
  String ip = Url().ip;

  Future<String?> obtenerTelefono(int idUsuario) async {
    final response = await http.get(Uri.parse(url+'/usuario/telefono/$idUsuario'));
    if (response.statusCode == 200) {
      return response
          .body; // Asumiendo que el teléfono se devuelve como texto plano
    } else {
      throw Exception('Error al obtener el teléfono');
    }
  }

  Future<bool> validarContrasena(
      String contrasenaIngresada, int idUsuario) async {
    try {
      final telefono = await obtenerTelefono(idUsuario);
      return contrasenaIngresada == telefono;
    } catch (e) {
      print('Error al validar la contraseña: $e');
      return false;
    }
  }

  Future<void> getPromotor() async {
    try {
      final response = await http
          .get(Uri.http(ip, "/promotor/lista_promotor"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _lista = data.map((e) => Promotor.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> obtenerListaZonas(int id) async {
    try {
      final response = await http
          .get(Uri.parse(url+'/promotor/lista_zonas/$id'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _lista = data.map((e) => Promotor.fromJson(e)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
