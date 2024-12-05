import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/model/DatosEstacion.dart';
import 'package:helvetasfront/model/Estacion.dart';
import 'package:helvetasfront/model/Municipio.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class EstacionService extends ChangeNotifier {
  List<DatosEstacion> _lista = [];
  List<DatosEstacion> get lista11 => _lista;

  List<DatosEstacion> _lista3 = [];
  List<DatosEstacion> get lista113 => _lista3;

  List<Municipio> _lista4 = [];
  List<Municipio> get lista114 => _lista4;

  List<Estacion> _lista5 = [];
  List<Estacion> get lista115 => _lista5;

  //final String url ='http://192.168.1.25:8080'; // Reemplaza con la URL de tu API
  //final String ip = '192.168.1.25:8080';

  String url = Url().apiUrl;
  String ip = Url().ip;

  Future<String?> obtenerCi(int idUsuario) async {
    //final response = await http.get(Uri.parse('$url/ci/$idUsuario'));
    final response = await http.get(Uri.parse(url + '/usuario/ci/$idUsuario'));
    if (response.statusCode == 200) {
      return response
          .body; // Asumiendo que el teléfono se devuelve como texto plano
    } else {
      throw Exception('Error al obtener el teléfono');
    }
  }

  Future<String?> obtenerPassword(int idUsuario) async {
    //final response = await http.get(Uri.parse('$url/ci/$idUsuario'));
    final response =
        await http.get(Uri.parse(url + '/usuario/password/$idUsuario'));
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
      final telefono = await obtenerPassword(idUsuario);
      return contrasenaIngresada == telefono;
    } catch (e) {
      print('Error al validar la contraseña: $e');
      return false;
    }
  }

  Future<void> getDatosEstacion() async {
    try {
      final response =
          await http.get(Uri.http(ip, "/datosEstacion/listaDatosEstacion"));
      //print('aaaaaaaa');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _lista = data.map((e) => DatosEstacion.fromJson(e)).toList();
        print('3333333' + _lista.length.toString());
        notifyListeners();
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Erroraaaaa: $e');
    }
  }

  Future<List<DatosEstacion>> getDatosEstacion2() async {
    try {
      final response =
          await http.get(Uri.http(ip, "/datosEstacion/listaDatosEstacion"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _lista.sort((a, b) => b.idUsuario.compareTo(a.idUsuario));
        _lista = _lista.take(10).toList();
        List<DatosEstacion> datosEstacion =
            data.map((e) => DatosEstacion.fromJson(e)).toList();
        return datosEstacion;
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> saveDatosEstacion(DatosEstacion estacion) async {
    try {
      final response = await http.post(
        Uri.http(ip, "/datosEstacion/addDatosEstacion"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(estacion.toJson()),
      );
      if (response.statusCode == 201) {
        notifyListeners();
        return (response.body.toString());
      } else {
        throw Exception('Error al guardar la persona');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> eliminarEstacion(int id) async {
    print('Dsddddddddddddddddde');
    final response = await http.delete(Uri.parse(url + '/datosEstacion/$id'));
    if (response.statusCode == 200) {
      print('Datos Estacion eliminada correctamente');
    } else {
      // Ocurrió un error al intentar eliminar la estación
      throw Exception('Error al eliminar la estación');
    }
  }

  Future<List<DatosEstacion>> obtenerDatosEstacion(int id) async {
    final response = await http.get(Uri.parse(url + '/datosEstacion/$id'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      if (jsonData.isEmpty) {
        return []; // Indica que no hay datos
      }
      return jsonData.map((item) => DatosEstacion.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener datos del observador');
    }
  }

  Future<List<DatosEstacion>> obtenerDatosMunicipio(int id) async {
    final response =
        await http.get(Uri.parse(url + '/datosEstacion/datos_municipio/$id'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      if (jsonData.isEmpty) {
        return []; // Indica que no hay datos
      }
      return jsonData.map((item) => DatosEstacion.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener datos del observador');
    }
  }

  Future<void> getMunicipio() async {
    try {
      final response =
          await http.get(Uri.http(ip, "/datosEstacion/vermunicipios"));
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

  Future<List<Estacion>> getEstacion(int id) async {
    final response =
        await http.get(Uri.parse(url + '/estacion/verEstaciones/$id'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      _lista5 = jsonData.map((e) => Estacion.fromJson(e)).toList();
      notifyListeners();
      if (jsonData.isEmpty) {
        return []; // Indica que no hay datos
      }
      return _lista5;
    } else {
      throw Exception('Error al obtener datos del observador');
    }
  }

  Future<List<DatosEstacion>> getListaMetetorologica(int id) async {
    final response = await http.get(
        Uri.parse(url + '/datosEstacion/obtener_estacion_meteorologica/$id'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      _lista3 = jsonData.map((e) => DatosEstacion.fromJson(e)).toList();
      notifyListeners();
      if (jsonData.isEmpty) {
        return []; // Indica que no hay datos
      }
      return _lista3;
    } else {
      throw Exception('Error al obtener datos del observador');
    }
  }

  Future<void> getDatos() async {
    try {
      final response =
          await http.get(Uri.http(ip, "/datosEstacion/verDatosEstacion"));
      //print('aaaaaaaa');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        _lista3 = data.map((e) => DatosEstacion.fromJson(e)).toList();
        print('3333333' + _lista.length.toString());

        //return datosEstacion;
        notifyListeners();
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Erroreeee: $e');
    }
  }

  Future<void> actualizarUltimoAcceso(int idUsuario) async {
    // Asegúrate de usar tu IP o dominio correcto

    try {
      // Construye la URL correctamente
      final response = await http.put(
        Uri.parse(url+'/usuario/actualizarUltimoAcceso/$idUsuario'),
        headers: {
          'Content-Type': 'application/json', // Si necesitas enviar headers
        },
      );

      if (response.statusCode == 200) {
        print('Último acceso actualizado correctamente');
      } else {
        print('Error al actualizar último acceso: ${response.body}');
      }
    } catch (error) {
      print('Error en la petición: $error');
    }
  }
  Future<void> getMunicipio2() async {
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
