import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/model/UsuarioEstacion.dart';
import 'package:helvetasfront/screens/Administrador/AdminScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;


class UsuarioService extends ChangeNotifier {
  List<UsuarioEstacion> _lista = [];
  List<UsuarioEstacion> get lista11 => _lista;
  String url = Url().apiUrl;
  String ip = Url().ip;

 Future<void> actualizarContrasena(String newPassword) async {
    try {

      final response = await http.get(Uri.http(ip, "/usuario/actualizar-contrasena"));


      if (response.statusCode == 200) {
        print("Contraseña actualizada correctamente");
      } else {
        print("Error al actualizar contraseña: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }

  Future<void> getUsuario() async {
    try {
      final response = await http.get(Uri.http(ip, "/usuario/verusuarios"));
      //print('aaaaaaaa');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        _lista = data.map((e) => UsuarioEstacion.fromJson(e)).toList();
        print('3333333' + _lista.length.toString());

        //return datosEstacion;
        notifyListeners();
      } else {
        throw Exception('Failed to load personas');
      }
    } catch (e) {
      throw Exception('Erroiiir: $e');
    }
  }

  Future<String> saveUsuario(UsuarioEstacion usuarioEstacion) async {
    try {
      final response = await http.post(
        Uri.http(ip, "/datosEstacion/addDatosEstacion"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(usuarioEstacion.toJson()),
      );
      if (response.statusCode == 201) {
        //print('Datos Estacion guardada correctamente');
        //print(response.statusCode);
        notifyListeners();
        //getDatosEstacion();
        return (response.body.toString());
      } else {
        throw Exception('Error al guardar la usuario');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> eliminarEstacion(int id) async {
    print('Dsddddddddddddddddde');
    final response = await http.delete(Uri.parse(url + '/datosEstacion/$id'));
    if (response.statusCode == 200) {
      // La estación se eliminó exitosamente
      // Puedes realizar alguna acción adicional si es necesario
      print('Datos Estacion eliminada correctamente');
    } else {
      // Ocurrió un error al intentar eliminar la estación
      throw Exception('Error al eliminar la estación');
    }
  }

  Future<Map<String, dynamic>> login(
      String nombreUsuario, String password, BuildContext context) async {
    final url2 = Uri.parse(url + '/api/login');

    try {
      final response = await http.post(
        url2,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'nombreUsuario': nombreUsuario,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        String responseBody = response.body;
        print('Respuesta del servidor: $responseBody');

        try {
          Map<String, dynamic> userDetails = jsonDecode(responseBody);

          if (userDetails.isNotEmpty) {
            // Usuario es administrador
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminScreen(
                  idUsuario: userDetails['idUsuario'],
                  nombre: userDetails['nombre'],
                  apeMat: userDetails['apeMat'],
                  apePat: userDetails['apePat'],
                  ci: userDetails['ci'],
                  imagen: userDetails['imagen'],
                ),
              ),
            );

            return {
              'success': true,
              'idUsuario': userDetails['idUsuario']
            }; // Login exitoso y idUsuario
          } else {
            // No es administrador, mostrar mensaje de error
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error de autenticación'),
                  content: Text('No se encontraron detalles de usuario.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );

            return {'success': false}; // Login fallido
          }
        } catch (e) {
          print('Error al decodificar JSON: $e');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error al procesar la respuesta'),
                content:
                    Text('Error al decodificar la respuesta del servidor.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );

          return {'success': false}; // Login fallido
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error de autenticación'),
              content:
                  Text('Usuario no encontrado o credenciales incorrectas.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

        return {'success': false}; // Login fallido
      }
    } catch (e) {
      print('Error en la conexión: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error de red'),
            content: Text('Hubo un problema al conectar con el servidor.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      return {'success': false}; // Login fallido
    }
  }
}
