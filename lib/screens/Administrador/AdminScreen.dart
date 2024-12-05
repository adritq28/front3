import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/Administrador/FechaSiembra/FechaSiembraScreen.dart';
import 'package:helvetasfront/screens/Administrador/Hidrologia/EstacionHidrologica.dart';
import 'package:helvetasfront/screens/Administrador/Meteorologia/EstacionMeteorologica.dart';
import 'package:helvetasfront/screens/Administrador/Pronosticos/PronosticoScreen.dart';
import 'package:helvetasfront/screens/Administrador/Usuario/UsuarioScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';

class AdminScreen extends StatelessWidget {
  final int idUsuario;
  final String nombre;
  final String apeMat;
  final String apePat;
  final String ci;
  final String imagen;

  const AdminScreen({
    required this.idUsuario,
    required this.nombre,
    required this.apeMat,
    required this.apePat,
    required this.ci,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: 0,
        estado: PerfilEstado.soloNombreTelefono,
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
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
          LayoutBuilder(
            builder: (context, constraints) {
              // Detectar el ancho disponible y ajustar las columnas
              int crossAxisCount;
              if (constraints.maxWidth < 600) {
                crossAxisCount = 1; // Pantallas pequeñas
              } else if (constraints.maxWidth < 1000) {
                crossAxisCount = 2; // Pantallas medianas
              } else {
                crossAxisCount = 3; // Pantallas grandes
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        height: 70,
                        color: Color.fromARGB(91, 4, 18, 43),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage("images/${imagen}"),
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
                                      ))),
                                  Text(
                                      '| ${nombre} ${apePat} ${apeMat}',
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
                      const SizedBox(height: 20),
                      GridView.count(
                        crossAxisCount: crossAxisCount, // Ajustar columnas
                        shrinkWrap: true,
                        crossAxisSpacing: 80,
                        mainAxisSpacing: 50,
                        padding: const EdgeInsets.all(60.0),
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          _buildButton(
                            context,
                            "Estaciones Meteorológicas",
                            Icons.holiday_village_rounded,
                            Color.fromARGB(255, 136, 96, 151),
                            Color.fromARGB(255, 232, 200, 255),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EstacionMeteorologicaScreen(
                                    idUsuario: idUsuario,
                                    nombre: nombre,
                                    apePat: apePat,
                                    apeMat: apeMat,
                                    ci: ci,
                                    imagen: imagen,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildButton(
                            context,
                            "Estaciones Hidrológicas",
                            Icons.query_stats_outlined,
                            Color.fromARGB(255, 161, 82, 73),
                            Color.fromARGB(255, 255, 217, 200),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EstacionHidrologicaScreen(
                                    idUsuario: idUsuario,
                                    nombre: nombre,
                                    apePat: apePat,
                                    apeMat: apeMat,
                                    ci: ci,
                                    imagen: imagen,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildButton(
                            context,
                            "Pronósticos Decenales",
                            Icons.satellite_rounded,
                            Color.fromARGB(255, 144, 128, 63),
                            Color.fromARGB(255, 255, 254, 200),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PronosticoScreen(
                                    idUsuario: idUsuario,
                                    nombre: nombre,
                                    apePat: apePat,
                                    apeMat: apeMat,
                                    ci: ci,
                                    imagen: imagen,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildButton(
                            context,
                            "Fecha de Siembra de Cultivo",
                            Icons.calendar_month,
                            Color.fromARGB(255, 57, 139, 91),
                            Color.fromARGB(255, 201, 255, 200),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FechaSiembraScreen(
                                    idUsuario: idUsuario,
                                    nombre: nombre,
                                    apePat: apePat,
                                    apeMat: apeMat,
                                    ci: ci,
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildButton(
                            context,
                            "Usuarios",
                            Icons.account_circle,
                            Color.fromARGB(255, 24, 110, 104),
                            Color.fromARGB(255, 200, 255, 255),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UsuarioScreen(
                                    idUsuario: idUsuario,
                                    nombre: nombre,
                                    apePat: apePat,
                                    apeMat: apeMat,
                                    ci: ci,
                                    imagen: imagen,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String title,
    IconData icon,
    Color backgroundColor,
    Color borderColor,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 200,
      height: 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: borderColor,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 45,
              color: borderColor,
            ),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 242, 246, 255),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
