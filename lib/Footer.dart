import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      //color: Color.fromARGB(35, 20, 19, 19), // Color de fondo del footer
      child: Center(
        child: Text(
          '© Pachatatiña 2024 | HELVETAS | EUROCLIMA | SENAMHI',
          style: GoogleFonts.convergence(
            textStyle: TextStyle(
              color: Color.fromARGB(255, 237, 237, 239), // Color del texto
              fontSize: 11.0, // Tamaño de la fuente
              //fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.center, // Centra el texto
        ),
      ),
    );
  }
}