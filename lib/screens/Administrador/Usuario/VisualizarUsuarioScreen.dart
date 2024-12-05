import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class VisualizarUsuarioScreen extends StatefulWidget {
  final int idUsuario;
  final String nombre;
  final String imagen;
  final String apePat;
  final String apeMat;
  final String ci;
  final bool admin;
  final String telefono;
  final String rol;

  VisualizarUsuarioScreen({
    required this.idUsuario,
    required this.nombre,
    required this.imagen,
    required this.apePat,
    required this.apeMat,
    required this.ci,
    required this.admin,
    required this.telefono,
    required this.rol,
  });

  @override
  _VisualizarUsuarioScreenState createState() =>
      _VisualizarUsuarioScreenState();
}

class _VisualizarUsuarioScreenState extends State<VisualizarUsuarioScreen> {
  String url = Url().apiUrl;
  String ip = Url().ip;

  bool isLoading = true;
  List<Map<String, dynamic>> datosUsuario = [];
  String? imagenUsuario;

  @override
  void initState() {
    super.initState();
    fetchDatosUsuario();
  }

  Future<void> fetchDatosUsuario() async {
    print('User ID: ${widget.idUsuario}');
    try {
      final response =
          await http.get(Uri.parse(url + '/usuario/roles/${widget.idUsuario}'));
      print(
          'Fetching data from URL: ${url + '/usuario/roles/${widget.idUsuario}'}');
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody =
            json.decode(response.body); // Decodificar la respuesta JSON
        //print('Response body: $responseBody');

        if (responseBody is List) {
          setState(() {
            datosUsuario = List<Map<String, dynamic>>.from(responseBody);
            imagenUsuario = (datosUsuario.isNotEmpty &&
                    datosUsuario[0]['usuarioImagen'] != null)
                ? 'images/${datosUsuario[0]['usuarioImagen']}'
                : 'images/default.png';
            isLoading = false;
          });
        } else {
          throw Exception('El formato de la respuesta no es una lista.');
        }
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Error al obtener los datos del usuario');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error en fetchDatosUsuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: 0,
        estado: PerfilEstado.soloNombreTelefono,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomNavBar(
          isHomeScreen: false,
          idUsuario: 0,
          estado: PerfilEstado.soloNombreTelefono,
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/fondo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  // Aquí permitimos el desplazamiento
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        CircleAvatar(
                          radius: 100,
                          backgroundImage:
                              AssetImage(imagenUsuario ?? 'images/default.png'),
                        ),
                        const SizedBox(height: 20),

                        // Acomodar la información del usuario en columnas
                        _buildUserInfoGrid(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                )
        ],
      ),
    );
  }

  // Método para construir una cuadrícula de información del usuario
  Widget _buildUserInfoGrid() {
    return Container(
      //height: 900,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600
              ? 2
              : 1, // Dos columnas en pantallas grandes
          childAspectRatio: MediaQuery.of(context).size.width > 600
              ? 1.5
              : 0.8, // Ajusta la relación de aspecto de los elementos
        ),
        itemCount: datosUsuario.length + 1, // +1 para incluir la tarjeta común
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCommonUserInfoCard(datosUsuario[0]); // Tarjeta común
          } else {
            var usuario = datosUsuario[index - 1];
            if (usuario['rol'] == '2') {
              return _buildObservadorCard(usuario); // Tarjeta de observador
            } else if (usuario['rol'] == '3') {
              return _buildPromotorCard(usuario); // Tarjeta de promotor
            }
          }
          return SizedBox(); // Placeholder en caso de error
        },
      ),
    );
  }

  // Tarjeta con los datos comunes (nombre, apellidos, ci, teléfono, admin)
  Widget _buildCommonUserInfoCard(Map<String, dynamic> usuario) {
    return Container(
      // constraints: BoxConstraints(
      //   minHeight: 1950, // Alto mínimo
      //   maxWidth: 2900, // Ancho máximo
      // ),
      child: Card(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          //child: SingleChildScrollView( // Agregar scroll
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField(
                  'Nombre',
                  '${usuario['nombre']} ${usuario['apePat']} ${usuario['apeMat']}',
                  Icons.person),
              _buildReadOnlyField(
                  'CI', usuario['ci'] ?? 'N/A', Icons.credit_card),
              _buildReadOnlyField(
                  'Teléfono', usuario['telefono'] ?? 'N/A', Icons.phone),
              _buildReadOnlyField(
                  'Admin',
                  (usuario['admin'] ?? false) ? 'Sí' : 'No',
                  Icons.admin_panel_settings),
            ],
          ),
          // ),
        ),
      ),
    );
  }

  // Tarjeta para el rol de observador (municipio, estación)
  Widget _buildObservadorCard(Map<String, dynamic> usuario) {
    return Card(
      color: Colors.transparent,
      child: Container(
        //height: 300,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField('Municipio', usuario['municipio'] ?? 'N/A',
                  Icons.location_city),
              _buildReadOnlyField(
                  'Estación', usuario['estacion'] ?? 'N/A', Icons.dashboard),
              _buildReadOnlyField('Tipo Estación',
                  usuario['tipoEstacion'] ?? 'N/A', Icons.dashboard),
            ],
          ),
        ),
      ),
    );
  }

  // Tarjeta para el rol de promotor (zona, cultivo, municipio)
  Widget _buildPromotorCard(Map<String, dynamic> usuario) {
    return Card(
      color: Colors.transparent,
      child: Container(
        //height: 800,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField('Zona', usuario['zona'] ?? 'N/A', Icons.map),
              _buildReadOnlyField(
                  'Cultivo', usuario['cultivoNombre'] ?? 'N/A', Icons.abc),
              _buildReadOnlyField('Municipio', usuario['municipio'] ?? 'N/A',
                  Icons.location_city),
            ],
          ),
        ),
      ),
    );
  }

  // Widget que construye un TextFormField de solo lectura
  Widget _buildReadOnlyField(
      String labelText, String valueText, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        initialValue: valueText,
        decoration: _getInputDecoration(labelText, icon),
        readOnly: true,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // Decoración del TextFormField
  InputDecoration _getInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.white),
      labelStyle: TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }
}
