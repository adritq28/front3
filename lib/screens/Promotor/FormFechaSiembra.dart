import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class FormFechaSiembra extends StatefulWidget {
  final int idUsuario;
  final int idZona;
  final String nombreZona;
  final String nombreMunicipio;
  final String nombreCompleto;
  final String telefono;
  final int idCultivo;
  final String nombreCultivo;
  final String tipo;
  final String imagen;
  final String imagenP;

  FormFechaSiembra(
      {required this.idUsuario,
      required this.idZona,
      required this.nombreZona,
      required this.nombreMunicipio,
      required this.nombreCompleto,
      required this.telefono,
      required this.idCultivo,
      required this.nombreCultivo,
      required this.tipo,
      required this.imagen,
      required this.imagenP});

  @override
  _FormFechaSiembraState createState() => _FormFechaSiembraState();
}

class _FormFechaSiembraState extends State<FormFechaSiembra> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  DateTime? _fechaSeleccionada;
  String url = Url().apiUrl;
  String ip = Url().ip;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  Future<List<Map<String, dynamic>>> fetchComunidades(int idZona) async {
    try {
      final response =
          await http.get(Uri.parse('$url/zona/lista_comunidad/$idZona'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Error al obtener las comunidades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

 Future<void> guardarFechaSiembra() async {
  if (_fechaSeleccionada != null) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!);
    final url2 = Uri.parse(url +
        '/cultivos/${widget.idCultivo}/fecha-siembra?fechaSiembra=$formattedDate');

    final response = await http.put(
      url2,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fechaSiembra': formattedDate,
      }),
    );

    if (response.statusCode == 200) {
      // Mostrar el AlertDialog si la respuesta es exitosa
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFFf0f0f0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Dato guardado correctamente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25, // Tamaño de fuente dinámico
                      color: Color(0xFF34495e),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text('Dato añadido correctamente.'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1abc9c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el dialogo
                },
                child: Text('OK',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ],
          );
        },
      );
      
      // Reiniciar la selección de fecha después de guardar
      setState(() {
        _fechaSeleccionada = null;
      });
    } else {
      print('Error ${response.statusCode}: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la fecha'),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Por favor selecciona una fecha primero'),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF164092),
      drawer: CustomDrawer(
        idUsuario: widget.idUsuario,
        estado: PerfilEstado.nombreZonaCultivo,
        nombreZona: widget.nombreZona,
        nombreCultivo: widget.nombreCultivo,
      ), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(
          isHomeScreen: false,
          showProfileButton: true,
          idUsuario: widget.idUsuario,
          estado: PerfilEstado.nombreZonaCultivo,
          nombreZona: widget.nombreZona,
          nombreCultivo: widget.nombreCultivo,
        ), // Indicamos que es la pantalla principal
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10), // Márgenes alrededor del contenedor
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
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
                      backgroundImage: AssetImage("images/${widget.imagenP}"),
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
                          Text('| ${widget.nombreCompleto}',
                              style: GoogleFonts.lexend(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))),
                          Text('| Municipio de: ${widget.nombreZona}',
                              style: GoogleFonts.lexend(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))),
                          Text('| Cultivo de: ${widget.nombreCultivo}',
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
              SizedBox(height: 20),
              Text(
                        'REGISTRO DE FECHAS DE SIEMBRA PARA LAS COMUNIDADES DE LA ZONA ' +
                      widget.nombreZona.toUpperCase()+' EN EL MUNICIPIO '+ widget. nombreMunicipio.toUpperCase(),
                        style: GoogleFonts.reemKufiFun(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                      ),

                      SizedBox(height:20), // Espaciado entre el título y las tarjetas

// FutureBuilder para cargar las comunidades en forma de lista horizontal
    FutureBuilder<List<Map<String, dynamic>>>(
  future: fetchComunidades(widget.idZona), // Usamos el idZona recibido
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Text(
          'Error: ${snapshot.error}',
          style: TextStyle(color: Colors.red),
        ),
      );
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(
        child: Text(
          'No hay comunidades disponibles.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else {
      List<Map<String, dynamic>> comunidades =
          List<Map<String, dynamic>>.from(snapshot.data!);

      List<String> nombresComunidades = comunidades
          .map((comunidad) => comunidad['nombreComunidad'] ?? 'Sin nombre')
          .toList()
          .cast<String>();
      final ScrollController scrollController = ScrollController();

      // Define a list of colors to use for the cards
      List<Color> cardColors = [
        Color.fromARGB(120, 30, 136, 229), // Semi-transparent blue
        Color.fromARGB(120, 75, 169, 124), // Semi-transparent green
        Color.fromARGB(120, 199, 119, 16), // Semi-transparent orange
        Color.fromARGB(120, 111, 12, 231), // Semi-transparent purple
        Color.fromARGB(120, 7, 170, 230),  // Semi-transparent cyan
      ];

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ListView horizontal para mostrar las tarjetas de las comunidades
            Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: scrollController,
                child: Row(
                  children: List.generate(nombresComunidades.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 10), // Espacio entre las tarjetas
                      child: Card(
                        elevation: 4,
                        color: cardColors[index % cardColors.length],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 25, // Tamaño de la imagen redonda
                                backgroundImage: AssetImage(
                                  'images/76.png', // Ruta de la imagen
                                ),
                                //backgroundColor: Colors.white,
                              ),
                              SizedBox(height: 10),
                              Text(
                                nombresComunidades[index].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    }
  },
),
              Container(
                margin: EdgeInsets.all(20), // Márgenes alrededor del contenedor
                padding: EdgeInsets.all(15), // Padding interno del contenedor
                decoration: BoxDecoration(
                  color: Colors.white, // Color de fondo blanco
                  borderRadius: BorderRadius.circular(
                      15), // Bordes redondeados de radio 15
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26, // Color de la sombra
                      blurRadius: 5, // Radio de desenfoque de la sombra
                      offset:
                          Offset(0, 2), // Offset de la sombra (desplazamiento)
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime(DateTime.now().year - 1),
                  lastDay: DateTime(DateTime.now().year + 1),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _fechaSeleccionada = DateTime(
                          selectedDay.year,
                          selectedDay.month,
                          selectedDay.day); // Asegurarse de que la fecha no tenga horas ni minutos
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (_fechaSeleccionada != null)
                Text(
                  'Fecha seleccionada: ${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 240,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await guardarFechaSiembra();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1abc9c),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    ),
                    icon: Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
              //SizedBox(width: 20),
              const SizedBox(height: 20),
              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}
