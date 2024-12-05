import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/screens/Administrador/Hidrologia/DatosHidrologicaScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class EstacionHidrologicaScreen extends StatefulWidget {
  final int idUsuario;
  final String nombre;
  final String apeMat;
  final String apePat;
  final String ci;
  final String imagen;

  const EstacionHidrologicaScreen({
    required this.idUsuario,
    required this.nombre,
    required this.apeMat,
    required this.apePat,
    required this.ci,
    required this.imagen
  });

  @override
  _EstacionHidrologicaScreenState createState() =>
      _EstacionHidrologicaScreenState();
}

class _EstacionHidrologicaScreenState extends State<EstacionHidrologicaScreen> {
  List<Map<String, dynamic>> estaciones = [];
  Map<String, List<Map<String, dynamic>>> estacionesPorMunicipio = {};
  String? municipioSeleccionado;
  String? estacionSeleccionada;
  int? idEstacionSeleccionada;
  String url = Url().apiUrl;
  String ip = Url().ip;

  @override
  void initState() {
    super.initState();
    fetchEstacionesHidrologica();
  }

  Future<void> fetchEstacionesHidrologica() async {
    final response =
        await http.get(Uri.parse(url + '/estacion/lista_hidrologica'));
    if (response.statusCode == 200) {
      setState(() {
        estaciones =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        estacionesPorMunicipio = agruparEstacionesPorMunicipio(estaciones);
      });
    } else {
      throw Exception('Failed to load estaciones');
    }
  }

  Map<String, List<Map<String, dynamic>>> agruparEstacionesPorMunicipio(
      List<Map<String, dynamic>> estaciones) {
    Map<String, List<Map<String, dynamic>>> agrupadas = {};
    for (var estacion in estaciones) {
      if (!agrupadas.containsKey(estacion['nombreMunicipio'])) {
        agrupadas[estacion['nombreMunicipio']] = [];
      }
      agrupadas[estacion['nombreMunicipio']]!.add(estacion);
    }
    return agrupadas;
  }

  void navigateToDatosHidrologicaScreen() {
    if (idEstacionSeleccionada != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DatosHidrologicaScreen(
            idEstacion: idEstacionSeleccionada!,
            nombreMunicipio: municipioSeleccionado!,
            nombreEstacion: estacionSeleccionada!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: widget.idUsuario,
        estado: PerfilEstado.soloNombreTelefono,
      ), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(
          isHomeScreen: false,
          idUsuario: widget.idUsuario,
          estado: PerfilEstado.soloNombreTelefono,
        ), // Indicamos que es la pantalla principal
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/fondo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              height: 70,
              color: Color.fromARGB(
                  91, 4, 18, 43), // Fondo negro con 20% de opacidad
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage("images/${widget.imagen}"),
                  ),
                  SizedBox(width: 15),
                  Flexible(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10.0,
                      runSpacing: 5.0,
                      children: [
                        Text("Bienvenid@",
                            style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                              color: Colors.white60,
                              //fontWeight: FontWeight.bold,
                            ))),
                        Text(
                            '| ${widget.nombre}' +
                                ' ' +
                                '${widget.apePat}' +
                                ' ' +
                                '${widget.apeMat}',
                            style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: estaciones.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: estacionesPorMunicipio.keys.length,
                      itemBuilder: (context, index) {
                        String municipio =
                            estacionesPorMunicipio.keys.elementAt(index);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      municipioSeleccionado = municipio;
                                      estacionSeleccionada = null;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 203, 230, 255),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      municipio,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 34, 52, 96),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (municipioSeleccionado != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Seleccione una estación en $municipioSeleccionado:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 234, 240, 255),
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      value: estacionSeleccionada,
                      hint: Text(
                        'Seleccione una estación',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 236, 241, 255),
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          estacionSeleccionada = newValue;
                          idEstacionSeleccionada =
                              estacionesPorMunicipio[municipioSeleccionado]!
                                  .firstWhere((element) =>
                                      element['nombreEstacion'] ==
                                      newValue)['idEstacion'];
                          navigateToDatosHidrologicaScreen();
                        });
                      },
                      items: estacionesPorMunicipio[municipioSeleccionado]!
                          .map<DropdownMenuItem<String>>(
                              (Map<String, dynamic> estacion) {
                        return DropdownMenuItem<String>(
                          value: estacion['nombreEstacion'],
                          child: Text(estacion['nombreEstacion']),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Footer(),
          ],
        ),
      ),
    );
  }
}
