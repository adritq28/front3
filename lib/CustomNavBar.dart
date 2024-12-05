import 'package:flutter/material.dart';
import 'package:helvetasfront/screens/LoginScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/textos.dart';

class CustomNavBar extends StatelessWidget {
  final bool isHomeScreen;
  final bool showProfileButton;
  final int idUsuario;
  final PerfilEstado estado;
  final String? nombreMunicipio;  // Nuevo parámetro opcional
  final String? nombreEstacion;  
  final String? nombreZona;
  final String? nombreCultivo; // Nuevo parámetro opcional

  CustomNavBar({
    this.isHomeScreen = false,
    this.showProfileButton = false,
    required this.idUsuario,
    required this.estado,
    this.nombreMunicipio,  // Inicialización del parámetro opcional
    this.nombreEstacion,
    this.nombreZona,
    this.nombreCultivo,
      // Inicialización del parámetro opcional
  });

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AppBar(
      backgroundColor: Color.fromARGB(255, 9, 31, 67),
      elevation: 0,
      leadingWidth: isSmallScreen ? 100 : 56,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isHomeScreen)
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: isSmallScreen ? 24 : 28,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          if (isSmallScreen)
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
        ],
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'PACHA',
                  style: getTextStyleNormal201(),
                ),
                const TextSpan(
                  text: 'YATIÑA',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (nombreMunicipio != null && nombreEstacion != null) // Mostrar nombres si están disponibles
            Text(
              '$nombreMunicipio - $nombreEstacion',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
        ],
      ),
      actions: [
        if (!isSmallScreen) ...[
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text(
              "Inicio",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16),
          if (showProfileButton) // Condición para mostrar el botón "Perfil"
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilScreen(idUsuario: idUsuario, estado: estado, nombreMunicipio: nombreMunicipio, nombreEstacion: nombreEstacion, nombreZona: nombreZona, nombreCultivo: nombreCultivo,),
                  ),
                );
              },
              child: Text(
                'Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          SizedBox(width: 16),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text(
              "Configuración",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          icon: Icon(
            Icons.more_vert,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }
}
