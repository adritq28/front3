import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Función para obtener el estilo de texto basado en el tamaño de la pantalla
//LISTAESTACIONSCREEN - TABLA
TextStyle getTextStyle(BoxConstraints constraints) {
  bool isMobile = constraints.maxWidth < 600;
  return GoogleFonts.lexend(
    textStyle: TextStyle(
      color: Colors.white,
      fontSize: isMobile ? 12 : 14, // Tamaño de la fuente
    ),
  );
}

TextStyle getTextStyleNormal20() {
  //bool isMobile = constraints.maxWidth < 600;
  return GoogleFonts.lexend(
    textStyle: TextStyle(
      color: Colors.white,
      fontSize:
          20.0,
      fontWeight: FontWeight.bold,
    ),
  );
}

TextStyle getTextStyForm() {
  //bool isMobile = constraints.maxWidth < 600;
  return GoogleFonts.lexend(
    textStyle: TextStyle(
      fontSize:
          35.0, // Tamaño del texto ingresado, ajustado para pantallas más pequeñas
      color: Color.fromARGB(255, 201, 219, 255),
    ),
  );
}

TextStyle getTextStyleNormal15() {
  //bool isMobile = constraints.maxWidth < 600;
  return GoogleFonts.lexend(
    textStyle: TextStyle(
      color: Colors.white,
      fontSize:
          15.0,
      fontWeight: FontWeight.bold,
    ),
  );
}

TextStyle getTextStyleNormal24() {
  //bool isMobile = constraints.maxWidth < 600;
  return GoogleFonts.lexend(
    textStyle: TextStyle(
      color: Colors.white,
      fontSize:
          24.0,
      fontWeight: FontWeight.bold,
    ),
  );
}

TextStyle getTextStyleNormal201() {
  //bool isMobile = constraints.maxWidth < 600;
  return GoogleFonts.tenorSans(
    textStyle: TextStyle(
      color: Colors.white,
      fontSize:
          20.0,
      fontWeight: FontWeight.bold,
    ),
  );
}
TextStyle getTextStyleNormal20n() {
  //bool isMobile = constraints.maxWidth < 600;
  return GoogleFonts.lexend(
    textStyle: TextStyle(
      color: Colors.black,
      fontSize:
          16.0,
      //fontWeight: FontWeight.bold,
    ),
  );
}