import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


////ANADIR CULTIVO SCREEN

Future<void> guardarDato(
  GlobalKey<FormState> formKey,
  String url,
  BuildContext context,
  int idZona,
  TextEditingController nombreController,
  TextEditingController tipoController,
  TextEditingController fechaSiembraController
) async {
  if (formKey.currentState!.validate()) {
    final String fechaReg = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(DateTime.now());

    final newDato = {
      'idZona': idZona,
      'nombre': nombreController.text,
      'tipo': tipoController.text,
      'fechaSiembra': fechaSiembraController.text.isEmpty ? null : fechaSiembraController.text,
      'fechaReg': fechaReg,
    };

    final response = await http.post(
      Uri.parse('$url/cultivos/addCultivo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newDato),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dato añadido correctamente')),
      );
      Navigator.pop(context, true);
    } else {
      final errorMessage = response.body;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir dato: $errorMessage')),
      );
    }
  }
}

///////////EDITAR CULTIVO SCREEN

class CultivoService {
  String url = Url().apiUrl;
  String ip = Url().ip;
  Future<bool> guardarCambios({
    required int idCultivo,
    required String nombre,
    String? fechaSiembra,
    String? fechaReg,
    required String tipo,
  }) async {
    final url2 = Uri.parse(url + '/cultivos/editar');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      'idCultivo': idCultivo,
      'nombre': nombre,
      'fechaSiembra': fechaSiembra?.isEmpty ?? true ? null : fechaSiembra,
      'fechaReg': fechaReg?.isEmpty ?? true ? null : fechaReg,
      'tipo': tipo,
    });

    final response = await http.post(url2, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Datos actualizados correctamente');
      return true;  // Cambios guardados correctamente
    } else {
      print('Error al actualizar los datos: ${response.body}');
      return false;  // Error al actualizar los datos
    }
  }
}
