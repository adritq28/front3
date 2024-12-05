import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

// Definimos los tres estados posibles
enum PerfilEstado {
  soloNombreTelefono, // Estado 1
  nombreEstacionMunicipio, // Estado 2
  nombreZonaCultivo // Estado 3
}

class PerfilScreen extends StatefulWidget {
  final int idUsuario;
  final PerfilEstado estado;
  final String? nombreMunicipio; // Parámetro opcional para nombreMunicipio
  final String? nombreEstacion; // Parámetro opcional para nombreEstacion
  final String? nombreZona; // Opcional para nombreZona
  final String? nombreCultivo; // Opcional para nombreCultivo

  const PerfilScreen({
    Key? key,
    required this.idUsuario,
    required this.estado,
    this.nombreMunicipio, // Parámetro opcional
    this.nombreEstacion, // Parámetro opcional
    this.nombreZona, // Parámetro opcional
    this.nombreCultivo, // Parámetro opcional
  }) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late Future<Map<String, dynamic>> _perfilData;
  String url = Url().apiUrl;

  @override
  void initState() {
    super.initState();
    _perfilData = fetchPerfilData(widget.idUsuario);
  }

  Future<Map<String, dynamic>> fetchPerfilData(int idUsuario) async {
    final response =
        await http.get(Uri.parse('$url/usuario/perfil/$idUsuario'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data[0];
      } else {
        throw Exception('No data found');
      }
    } else {
      throw Exception('Failed to load perfil data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.nombreEstacionMunicipio,), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(
            isHomeScreen: false, showProfileButton: false,idUsuario: 0, estado: PerfilEstado.nombreEstacionMunicipio,), // Indicamos que es la pantalla principal
      ),
      body: Stack(
        // Usar Stack para superponer widgets
        children: [
          // Container para la imagen de fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/fondo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // FutureBuilder para cargar los datos del perfil
          FutureBuilder<Map<String, dynamic>>(
            future: _perfilData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No hay datos disponibles'));
              } else {
                final perfil = snapshot.data!;
                return Center(
                  // Centrar el contenido
                  child: SizedBox(
                    width: 550, // Establecer el ancho deseado
                    height: 600, // Establecer la altura deseada
                    child: Card(
                      color: Color.fromARGB(91, 4, 18, 43),
                      elevation: 4, // Sombra de la tarjeta
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Esquinas redondeadas
                      ),
                      margin: EdgeInsets.all(16), // Margen alrededor del Card
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Ajustar el tamaño del Card al contenido
                          crossAxisAlignment: CrossAxisAlignment.center, // Centrar el contenido horizontalmente
                          children: [
                            // Mostrar la imagen en un círculo
                            SizedBox(height:40),
                            CircleAvatar(
                              radius: 120, // Ajusta el tamaño del círculo según sea necesario
                              backgroundImage:
                                  AssetImage('images/${perfil['imagen']}'),
                              backgroundColor: Color.fromARGB(
                              91, 4, 18, 43), // Color de fondo si la imagen no está disponible
                            ),
                            SizedBox(height:16), // Espacio entre la imagen y el texto
                            Text(
                              '${perfil['nombreCompleto']}'.toUpperCase(),
                              
                                  style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              textAlign: TextAlign.center,
                              // Centrar el texto
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Teléfono: ${perfil['telefono']}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),

                            // Mostrar contenido según el estado
                            if (widget.estado ==
                                PerfilEstado.nombreEstacionMunicipio) ...[
                              Text('Estación: ${widget.nombreEstacion}',
                                  textAlign: TextAlign.center, style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                ),
                              ),),
                              SizedBox(height: 10),
                              Text('Municipio: ${widget.nombreMunicipio}',
                                  textAlign: TextAlign.center, style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                ),
                              ),),
                            ] else if (widget.estado ==
                                PerfilEstado.nombreZonaCultivo) ...[
                              Text(
                                  'Zona: ${widget.nombreZona ?? 'No disponible'}',
                                  textAlign: TextAlign.center, style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                ),
                              ),),
                              SizedBox(height: 10),
                              Text(
                                  'Cultivo: ${widget.nombreCultivo ?? 'No disponible'}',
                                  textAlign: TextAlign.center, style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                ),
                              ),),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
