import 'package:flutter/material.dart';
import 'package:helvetasfront/screens/LoginScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/textos.dart';

class CustomDrawer extends StatelessWidget {
  final bool showProfileButton;
  final int idUsuario;
  final PerfilEstado estado;
  
  // Nuevos parámetros para PerfilScreen
  final String? nombreMunicipio;
  final String? nombreEstacion;
  final String? nombreZona;
  final String? nombreCultivo;

  CustomDrawer({
    this.showProfileButton = true,
    required this.idUsuario,
    required this.estado,
    this.nombreMunicipio,
    this.nombreEstacion,
    this.nombreZona,
    this.nombreCultivo,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF48C9B0)),
            child: Text('Menú de Navegación', style: getTextStyleNormal24()),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () {
              // Navegar a la página de inicio usando Navigator.push
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          if (showProfileButton) // Condición para mostrar el botón "Perfil"
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilScreen(
                      idUsuario: idUsuario,
                      estado: estado,
                      // Pasar los valores adicionales para PerfilScreen
                      nombreMunicipio: nombreMunicipio,
                      nombreEstacion: nombreEstacion,
                      nombreZona: nombreZona,
                      nombreCultivo: nombreCultivo,
                    ),
                  ),
                );
              },
            ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuración'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
