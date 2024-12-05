import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class EditarEstacionScreen extends StatefulWidget {
  // EditarEstacionScreen();
  final int estacionId;
  final int idUsuario;
  final String nombreMunicipio;
  final double tempMax;
  final double tempMin;
  final double tempAmb;
  final double pcpn;
  final double taevap;
  final String dirViento;
  final double velViento;
  final int idEstacion;

  EditarEstacionScreen({
    required this.estacionId,
    required this.idUsuario,
    required this.nombreMunicipio,
    required this.tempMax,
    required this.tempMin,
    required this.tempAmb,
    required this.pcpn,
    required this.taevap,
    required this.dirViento,
    required this.velViento,
    required this.idEstacion,
  });

  @override
  _EditarEstacionScreenState createState() => _EditarEstacionScreenState();
}

class _EditarEstacionScreenState extends State<EditarEstacionScreen> {
  TextEditingController idUsuario = TextEditingController();
  TextEditingController nombreMunicipio = TextEditingController();
  TextEditingController tempMax = TextEditingController();
  TextEditingController tempMin = TextEditingController();
  TextEditingController tempAmb = TextEditingController();
  TextEditingController pcpn = TextEditingController();
  TextEditingController taevap = TextEditingController();
  TextEditingController dirViento = TextEditingController();
  TextEditingController velViento = TextEditingController();
  String url = Url().apiUrl;
  String ip = Url().ip;
  

  @override
  void initState() {
    super.initState();
    idUsuario.text = widget.idUsuario.toString();
    nombreMunicipio.text = widget.tempMax.toString();
    tempMax.text = widget.tempMax.toString();
    tempMin.text = widget.tempMin.toString();
    tempAmb.text = widget.tempAmb.toString();
    pcpn.text = widget.pcpn.toString();
    taevap.text = widget.taevap.toString();
    dirViento.text = widget.dirViento.toString();
    velViento.text = widget.velViento.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.nombreEstacionMunicipio,
        nombreMunicipio: widget.nombreMunicipio,
      ), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(isHomeScreen: false, showProfileButton: true, idUsuario: 0, 
        estado: PerfilEstado.nombreEstacionMunicipio,
        nombreMunicipio: widget.nombreMunicipio,), // Indicamos que es la pantalla principal
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: tempMax,
              decoration: InputDecoration(labelText: 'tempMax'),
            ),
            TextFormField(
              controller: tempMin,
              decoration: InputDecoration(labelText: 'Temperatura Mínima'),
              // Puedes establecer un valor inicial si lo deseas
            ),
            TextFormField(
              controller: tempAmb,
              decoration: InputDecoration(labelText: 'tempAmb'),
            ),
            TextFormField(
              controller: pcpn,
              decoration: InputDecoration(labelText: 'pcpn'),
            ),
            TextFormField(
              controller: taevap,
              decoration: InputDecoration(labelText: 'taevap'),
            ),
            TextFormField(
              controller: dirViento,
              decoration: InputDecoration(labelText: 'Dir viento'),
            ),
            TextFormField(
              controller: velViento,
              decoration: InputDecoration(labelText: 'Vel Viento'),
            ),

            // Agrega más TextFormField para otros campos según sea necesario
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                actualizarDatosEstacion();
              },
              child: Text('Actualizar'),
            ),
            ////////////////
          ],
        ),
        
      ),
      
    );
  }

  Future<void> actualizarDatosEstacion() async {
    final String url2 =
        url+'/datosEstacion/updateDatosEstacion/${widget.estacionId}';

    Map<String, dynamic> datosActualizados = {
      "idUsuario": idUsuario.text,
      "nombreMunicipio": nombreMunicipio.text,
      "tempMax": tempMax.text,
      "tempMin": tempMin.text,
      "tempAmb": tempAmb.text,
      "pcpn": pcpn.text,
      "taevap": taevap.text,
      "dirViento": dirViento.text,
      "velViento": velViento.text,
    };

    try {
      final response = await http.put(
        Uri.parse(url2),
        body: jsonEncode(datosActualizados),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Mostrar el diálogo emergente
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Actualizado con éxito'),
              content: Text(
                  'Los datos de la estación han sido actualizados correctamente.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Cierra el diálogo emergente
                    Navigator.of(context).pop();
                  },
                  child: Text('Aceptar'),
                ),
              ],
            );
          },
        );
      } else {
        print(
            'Error al actualizar los datos de la estación: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error al realizar la solicitud PUT: $e');
    }
  }
}
