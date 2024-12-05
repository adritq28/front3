import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart' as excel_pkg;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/Utils/mobile_utils.dart';
import 'package:helvetasfront/model/DatosPronostico.dart';
import 'package:helvetasfront/model/Fenologia.dart';
import 'package:helvetasfront/model/HistFechaSiembra.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/FenologiaService.dart';
import 'package:helvetasfront/textos.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class PronosticoAgrometeorologico extends StatefulWidget {
  final int idZona;
  final String nombreMunicipio;
  final int idCultivo;
  final String nombreZona;

  PronosticoAgrometeorologico(
      {required this.idZona,
      required this.nombreMunicipio,
      required this.idCultivo,
      required this.nombreZona});

  @override
  _PronosticoAgrometeorologicoState createState() =>
      _PronosticoAgrometeorologicoState();
}

class _PronosticoAgrometeorologicoState
    extends State<PronosticoAgrometeorologico> {
  late Future<void> _futureObtenerZonas;
  late FenologiaService miModelo5;
  late Future<Map<String, dynamic>>? _futureUltimaAlerta;

  late Future<List> _futurePronosticoCultivo;
  late Future<List<Map<String, dynamic>>> _futurePcpnFase;

  List<HistFechaSiembra> _fechasSiembra = [];
  HistFechaSiembra? _selectedFechaSiembra;
  String url = Url().apiUrl;
  String ip = Url().ip;

  @override
  void initState() {
    super.initState();
    miModelo5 = Provider.of<FenologiaService>(context, listen: false);
    _cargarFenologia();
    _cargarFenologia2();
    _fetchFechasSiembra();
  }

  Future<List<DatosPronostico>> obtenerPronosticosFase(int cultivoId) async {
    final response = await http.get(
      Uri.parse('$url/pronostico_fase/$cultivoId'),
    );

    if (response.statusCode == 200) {
      // Si la solicitud fue exitosa, parseamos la respuesta
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => DatosPronostico.fromJson(data)).toList();
    } else {
      throw Exception('Error al obtener los pronósticos');
    }
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

  Future<void> exportToExcel(
    List<Fenologia> datosList,
  ) async {
    try {
      var excel = excel_pkg.Excel.createExcel(); // Crear un nuevo archivo Excel
      var sheet = excel['Sheet1']; // Seleccionar la primera hoja
      var aux = 1;
      // Agregar los encabezados de las columnas
      sheet.appendRow([
        'FASE',
        'Temp. letal min',
        'Temp. opt min',
        'Umb. inf',
        'Umb. sup',
        'Temp. opt max',
        'Temp. letal max'
      ]);

      // Agregar los datos de la lista
      for (var dato in datosList) {
        sheet.appendRow([
          aux++,
          dato.tempMin.toString(),
          dato.tempOptMin.toString(),
          dato.umbInf.toString(),
          dato.umbSup.toString(),
          dato.tempOptMax.toString(),
          dato.tempMax.toString(),
        ]);
      }

      var fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('No se pudo generar el archivo Excel.');
      }

      if (kIsWeb) {
        // Código para la web
        await downloadExcelMobile2(fileBytes, "Umbrales.xlsx");
      } else {
        // Código para dispositivos móviles
        final directory =
            await getExternalStorageDirectory(); // O usa getApplicationDocumentsDirectory si prefieres
        final filePath = '${directory!.path}/Umbrales.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        OpenFile.open(filePath);
      }

      print('Archivo listo para descargar');
    } catch (e) {
      print('Error al guardar el archivo: $e');
    }
  }

  void exportarDato() async {
    try {
      // Aquí asumo que 'miModelo5.lista11' contiene los datos
      await exportToExcel(miModelo5.lista11);
    } catch (e) {
      print('Error al exportar los datos: $e');
    }
  }

  Future<void> _fetchFechasSiembra() async {
    final response =
        await http.get(Uri.parse(url + '/cultivos/fechas/${widget.idCultivo}'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _fechasSiembra =
            data.map((json) => HistFechaSiembra.fromJson(json)).toList();
      });
    } else {
      // Manejar error
    }
  }

  Future<void> _cargarFenologia() async {
    try {
      await Provider.of<FenologiaService>(context, listen: false)
          .obtenerFenologia(widget.idCultivo);

      if (miModelo5.lista11.isNotEmpty) {
        int idCultivo = miModelo5.lista11[0].idCultivo;

        // Inicializa las variables de los futuros
        setState(() {
          _futureUltimaAlerta = miModelo5.fetchUltimaAlerta(idCultivo);
          _futurePronosticoCultivo = miModelo5.pronosticoCultivo(idCultivo);
          _futurePcpnFase = miModelo5.fetchPcpnFase(widget.idCultivo);
        });
      } else {
        // Manejo de error si la lista está vacía
        throw Exception('No se encontró el idCultivo');
      }
    } catch (e) {
      // Manejo de errores
      print('Error al cargar los datos: $e');
    }
  }

  Future<void> _cargarFenologia2() async {
    try {
      await Provider.of<FenologiaService>(context, listen: false)
          .obtenerPronosticosFase(widget.idCultivo);
      await Provider.of<FenologiaService>(context, listen: false)
          .fase(widget.idCultivo);
    } catch (e) {
      // Manejo de errores
      print('Error al cargar los datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFF164092),
      drawer: CustomDrawer(
        idUsuario: 0,
        estado: PerfilEstado.nombreEstacionMunicipio,
      ), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(
          isHomeScreen: false,
          idUsuario: 0,
          estado: PerfilEstado.nombreEstacionMunicipio,
        ), // Indicamos que es la pantalla principal
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
          Container(
            margin: const EdgeInsets.all(10.0),
            child: Consumer<FenologiaService>(
              builder: (context, miModelo5, _) {
                if (miModelo5.lista11.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay datos disponibles',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                //final timelineEvents = generateTimeline(miModelo5.lista11);
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Container(
                              height: 90,
                              color: Color.fromARGB(91, 4, 18,
                                  43), // Fondo negro con 20% de opacidad
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 10),
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        AssetImage("images/47.jpg"),
                                  ),
                                  SizedBox(width: 15),
                                  Flexible(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 10.0,
                                      runSpacing: 5.0,
                                      children: [
                                        Text("Bienvenido Invitado",
                                            style: GoogleFonts.lexend(
                                                textStyle: TextStyle(
                                              color: Colors.white60,
                                              //fontWeight: FontWeight.bold,
                                            ))),
                                        Text(
                                            '| Municipio de: ${widget.nombreMunicipio}',
                                            style: GoogleFonts.lexend(
                                                textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12))),
                                        Text('| Zona: ${widget.nombreZona}',
                                            style: GoogleFonts.lexend(
                                                textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12))),
                                        Text(
                                            ' | Cultivo de ' +
                                                miModelo5
                                                    .lista11[0].nombreCultivo,
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Text(
                      //   'SELECCIONE FECHAS: ',
                      //   style: GoogleFonts.kulimPark(
                      //     textStyle: TextStyle(
                      //       color: Color.fromARGB(
                      //           255, 239, 239, 240), // Color del texto
                      //       fontSize: 15.0,
                      //       fontWeight: FontWeight.bold, // Tamaño de la fuente
                      //       //fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                      // DropdownButton<HistFechaSiembra>(
                      //   hint: Text('Seleccionar Fecha de Siembra'),
                      //   value: _selectedFechaSiembra,
                      //   onChanged: (HistFechaSiembra? nuevaFecha) {
                      //     setState(() {
                      //       _selectedFechaSiembra = nuevaFecha;
                      //       // Aquí puedes actualizar la fecha de siembra en tu UI
                      //       // y recalcular la fecha acumulada si es necesario
                      //     });
                      //   },
                      //   items: _fechasSiembra.map((HistFechaSiembra fecha) {
                      //     return DropdownMenuItem<HistFechaSiembra>(
                      //       value: fecha,
                      //       child: Text('${fecha.fechaSiembra.toLocal()}'),
                      //     );
                      //   }).toList(),
                      // ),
                      SizedBox(height: 25),
                      
                      Container(
                        width: double
                            .infinity, // Asegura que el contenedor ocupe todo el ancho disponible
                        padding: EdgeInsets.all(
                            16.0), // Espaciado alrededor del texto
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centra el contenido verticalmente
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Centra el contenido horizontalmente
                          children: [
                            Text(
                              'COMUNIDADES DE LA ZONA ' +
                            widget.nombreZona.toUpperCase() +
                            ' EN EL MUNICIPIO ' +
                            widget.nombreMunicipio.toUpperCase(),
                              style: GoogleFonts.reemKufiFun(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              textAlign: TextAlign.center, // Centrar el texto
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height:20), // Espaciado entre el título y las tarjetas

// FutureBuilder para cargar las comunidades en forma de lista horizontal
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchComunidades(
                            widget.idZona), // Usamos el idZona recibido
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blueAccent),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
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
                                .map((comunidad) =>
                                    comunidad['nombreComunidad'] ??
                                    'Sin nombre')
                                .toList()
                                .cast<String>();
                            final ScrollController scrollController =
                                ScrollController();

                            // Define a list of colors to use for the cards
                            List<Color> cardColors = [
                              Color.fromARGB(
                                  120, 30, 136, 229), // Semi-transparent blue
                              Color.fromARGB(
                                  120, 75, 169, 124), // Semi-transparent green
                              Color.fromARGB(
                                  120, 199, 119, 16), // Semi-transparent orange
                              Color.fromARGB(
                                  120, 111, 12, 231), // Semi-transparent purple
                              Color.fromARGB(
                                  120, 7, 170, 230), // Semi-transparent cyan
                            ];

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 7.0),
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
                                        children: List.generate(
                                            nombresComunidades.length, (index) {
                                          return Padding(
                                            padding: EdgeInsets.only(right:4), // Espacio entre las tarjetas
                                            child: Card(
                                              elevation: 4,
                                              color: cardColors[
                                                  index % cardColors.length],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    CircleAvatar(
                                                      radius:
                                                          25, // Tamaño de la imagen redonda
                                                      backgroundImage:
                                                          AssetImage(
                                                        'images/76.png', // Ruta de la imagen
                                                      ),
                                                      //backgroundColor: Colors.white,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      nombresComunidades[index]
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
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
                        width: double
                            .infinity, // Asegura que el contenedor ocupe todo el ancho disponible
                        padding: EdgeInsets.all(
                            16.0), // Espaciado alrededor del texto
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centra el contenido verticalmente
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Centra el contenido horizontalmente
                          children: [
                            Text(
                              'PRONOSTICO AGROMETEOROLOGICO',
                              style: GoogleFonts.reemKufiFun(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              textAlign: TextAlign.center, // Centrar el texto
                            ),
                          ],
                        ),
                      ),
                      //SizedBox(height: 10),
                      if (_futureUltimaAlerta != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FutureBuilder<Map<String, dynamic>>(
                              future: _futureUltimaAlerta,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${snapshot.error}',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  final alertData = snapshot.data!;
                                  final alertMessages = {
                                    'Temperatura Máxima':
                                        alertData['TempMax']?.toString() ??
                                            'No alert',
                                    'Temperatura Mínima':
                                        alertData['TempMin']?.toString() ??
                                            'No alert',
                                    'Precipitación':
                                        alertData['Pcpn']?.toString() ??
                                            'No alert',
                                  };

                                  return SizedBox(
                                    height:
                                        400.0, // Ajusta la altura según tus necesidades
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children:
                                            alertMessages.entries.map((entry) {
                                          final alertType = entry.key;
                                          final alertMessage = entry.value;

                                          IconData icon;
                                          Color alertColor;
                                          String imageUrl;

                                          if (alertMessage.contains("ROJA")) {
                                            alertColor = const Color.fromARGB(
                                                255, 255, 139, 131);
                                            icon = Icons.warning;
                                            imageUrl = 'images/rojo.png';
                                          } else if (alertMessage
                                              .contains("AMARILLA")) {
                                            alertColor = Color.fromARGB(
                                                255, 231, 217, 90);
                                            icon = Icons.notifications_active;
                                            imageUrl = 'images/amarillo.png';
                                          } else if (alertMessage
                                              .contains("VERDE")) {
                                            alertColor = const Color.fromARGB(
                                                255, 161, 255, 164);
                                            icon = Icons.sentiment_satisfied;
                                            imageUrl = 'images/verde.png';
                                          } else {
                                            alertColor = Colors.white;
                                            icon = Icons.info;
                                            imageUrl = 'images/verde.png';
                                          }

                                          return Container(
                                            width: 250.0,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Card(
                                              color: Color.fromARGB(
                                                  255, 255, 253, 251),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                                side: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1.0),
                                              ),
                                              elevation: 4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 250.0,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                            imageUrl),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      12.0)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      children: [
                                                        // Título de la tarjeta
                                                        Text(
                                                          alertType,
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.0),
                                                        // Fila de alerta con icono y mensaje
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              width: 35.0,
                                                              height: 35.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    alertColor,
                                                              ),
                                                              child: Icon(
                                                                icon,
                                                                color: Colors
                                                                    .white,
                                                                size: 30.0,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: 8.0),
                                                            Expanded(
                                                              child: Text(
                                                                alertMessage,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: Text(
                                      'No hay alertas disponibles',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),
                      Container(
                        width: double
                            .infinity, // Asegura que el contenedor ocupe todo el ancho disponible
                        padding: EdgeInsets.all(
                            16.0), // Espaciado alrededor del texto
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centra el contenido verticalmente
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Centra el contenido horizontalmente
                          children: [
                            Text(
                              'PRONOSTICO EN LOS PROXIMOS 10 DIAS',
                              style: GoogleFonts.reemKufiFun(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              textAlign: TextAlign.center, // Centrar el texto
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<DatosPronostico>>(
                        future: miModelo5
                            .pronosticoCultivo(miModelo5.lista11[0].idCultivo),
                        builder: (context,
                            AsyncSnapshot<List<DatosPronostico>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                                child: Text(
                                    'Este usuario no tiene datos registrados'));
                          } else {
                            final datosList = snapshot.data!;
                            final ScrollController scrollController =
                                ScrollController();
                            return Column(
                              children: [
                                //tablaDatos(datosList),
                                listaTarjetasPronostico(
                                    datosList, scrollController, context),
                                //tablaDatosInvertida2(datosList),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      Container(
                        width: double
                            .infinity, // Asegura que el contenedor ocupe todo el ancho disponible
                        padding: EdgeInsets.all(
                            16.0), // Espaciado alrededor del texto
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centra el contenido verticalmente
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Centra el contenido horizontalmente
                          children: [
                            Text(
                              'FENOLOGIA DE ' +
                                  miModelo5.lista11[0].nombreCultivo
                                      .toUpperCase(),
                              style: GoogleFonts.reemKufiFun(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              textAlign: TextAlign.center, // Centrar el texto
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Builder(
                          builder: (context) {
                            final ScrollController scrollController =
                                ScrollController();
                            return Scrollbar(
                              controller: scrollController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: scrollController,
                                child: Row(
                                  children: [
                                    ...miModelo5.lista11
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      var dato = entry.value;

                                      // Calcular la fecha acumulada correctamente para cada fase
                                      DateTime fechaAcumulado;
                                      if (index == 0) {
                                        // La primera fase muestra la fecha de siembra sin sumar días
                                        fechaAcumulado = _selectedFechaSiembra
                                                ?.fechaSiembra ??
                                            dato.fechaSiembra;
                                      } else {
                                        // Acumula los días de cada fase desde el inicio hasta el índice actual
                                        int diasAcumulados = miModelo5.lista11
                                            .take(index +
                                                1) // Tomamos todas las fases hasta el índice actual
                                            .map((d) => d.nroDias)
                                            .reduce((a, b) => a + b);

                                        fechaAcumulado = (_selectedFechaSiembra
                                                    ?.fechaSiembra ??
                                                miModelo5
                                                    .lista11[0].fechaSiembra)
                                            .add(
                                                Duration(days: diasAcumulados));
                                      }

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 5,
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        width: 200,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 10),
                                            Center(
                                              child: Image.asset(
                                                'images/${dato.imagen}', // Ruta de la imagen
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Center(
                                              child: Text(
                                                '${dato.descripcion}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'Nro Dias: ${dato.nroDias}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              'Fase: ${dato.fase}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '${formatearFecha(fechaAcumulado)}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),
                      // Container(
                      //   width: double
                      //       .infinity, // Asegura que el contenedor ocupe todo el ancho disponible
                      //   padding:
                      //       EdgeInsets.all(16.0), // Espaciado alrededor del texto
                      //   child: Column(
                      //     mainAxisAlignment: MainAxisAlignment
                      //         .center, // Centra el contenido verticalmente
                      //     crossAxisAlignment: CrossAxisAlignment
                      //         .center, // Centra el contenido horizontalmente
                      //     children: [
                      //       Text(
                      //         'DATOS PCPN FASE',
                      //         style: GoogleFonts.reemKufiFun(
                      //           textStyle: TextStyle(
                      //             color: Colors.white,
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 20,
                      //           ),
                      //         ),
                      //         textAlign: TextAlign.center, // Centrar el texto
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // FutureBuilder<List<Map<String, dynamic>>>(
                      //   future: _futurePcpnFase,
                      //   builder: (context, snapshot) {
                      //     if (snapshot.connectionState == ConnectionState.waiting) {
                      //       return Center(child: CircularProgressIndicator());
                      //     } else if (snapshot.hasError) {
                      //       return Center(child: Text('Error: ${snapshot.error}'));
                      //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      //       return Center(child: Text('No hay datos disponibles'));
                      //     } else {
                      //       final pcpnFaseList = snapshot.data!;
                      //       // Extraer datos
                      //       List<String> fases = pcpnFaseList
                      //           .map((e) => e['fase']?.toString() ?? '')
                      //           .toList();
                      //       List<String> pcpnAcumuladas = pcpnFaseList
                      //           .map((e) => e['pcpnAcumulada']?.toString() ?? '')
                      //           .toList();
                      //       // Crear filas para el DataTable invertido
                      //       List<DataRow> rows = [];
                      //       for (int i = 0; i < fases.length; i++) {
                      //         rows.add(
                      //           DataRow(
                      //             cells: [
                      //               DataCell(Text(fases[i],
                      //                   style: TextStyle(
                      //                     color: Colors
                      //                         .white, // Color blanco para todas las letras
                      //                   ))),
                      //               DataCell(Text(pcpnAcumuladas[i],
                      //                   style: TextStyle(
                      //                     color: Colors
                      //                         .white, // Color blanco para todas las letras
                      //                   ))),
                      //             ],
                      //           ),
                      //         );
                      //       }
                      //       return SingleChildScrollView(
                      //         scrollDirection: Axis.horizontal,
                      //         child: DataTable(
                      //           decoration: BoxDecoration(
                      //             borderRadius:
                      //                 BorderRadius.circular(10), // Borde redondeado
                      //             border: Border.all(
                      //                 color: Color.fromARGB(255, 245, 205,
                      //                     156)), // Borde gris alrededor de la tabla
                      //           ),
                      //           columns: [
                      //             DataColumn(
                      //                 label: Text('Fase',
                      //                     style: TextStyle(
                      //                       fontWeight: FontWeight.bold,
                      //                       color: Colors.white,
                      //                       fontSize: 20,
                      //                     ))),
                      //             DataColumn(
                      //                 label: Text('PCPN Acumulada',
                      //                     style: TextStyle(
                      //                       fontWeight: FontWeight.bold,
                      //                       color: Colors.white,
                      //                       fontSize: 20,
                      //                     ))),
                      //           ],
                      //           rows: rows,
                      //         ),
                      //       );
                      //     }
                      //   },
                      // ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(width: 5),
                          Container(
                            width: 300,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right:
                                      20.0), // Ajusta el valor según sea necesario
                              child: TextButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFFC57A),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  exportarDato();
                                },
                                icon:
                                    Icon(Icons.show_chart, color: Colors.white),
                                label: Text(
                                  'Descargar umbrales',
                                  style: getTextStyleNormal20(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double
                            .infinity, // Asegura que el contenedor ocupe todo el ancho disponible
                        padding: EdgeInsets.all(
                            16.0), // Espaciado alrededor del texto
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centra el contenido verticalmente
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Centra el contenido horizontalmente
                          children: [
                            Text(
                              'UMBRALES',
                              style: GoogleFonts.reemKufiFun(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              textAlign: TextAlign.center, // Centrar el texto
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Card(
                          elevation:
                              4.0, // Ajusta la sombra del card si es necesario
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12.0), // Ajusta el radio del borde si es necesario
                          ),
                          color: Color.fromARGB(106, 0, 0, 0),
                          //.withOpacity(0.3), // Fondo negro con transparencia
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top:
                                    40.0), // Ajusta el valor para el padding superior
                            child: Container(
                              width:
                                  1200, // Ajusta este valor según el tamaño deseado para tu gráfico
                              height:
                                  500, // Ajusta este valor según el tamaño deseado para tu gráfico
                              child: crearGrafica3(
                                  miModelo5.lista11, miModelo5.lista112),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Card(
                          elevation:
                              4.0, // Ajusta la sombra del card si es necesario
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12.0), // Ajusta el radio del borde si es necesario
                          ),
                          color: Color.fromARGB(106, 0, 0, 0),
                          //.withOpacity(0.3), // Fondo negro con transparencia
                          child: Padding(
                            padding: EdgeInsets.only(top: 40.0),
                            //EdgeInsets.symmetric(horizontal: 8.0), // Ajusta el valor para el padding superior
                            child: Container(
                              width:
                                  800, // Ajusta este valor según el tamaño deseado para tu gráfico
                              height:
                                  500, // Ajusta este valor según el tamaño deseado para tu gráfico
                              child: crearGraficaPCPN(miModelo5.lista11),
                            ),
                          ),
                        ),
                      ),

                      // const SizedBox(height: 20),
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Card(
                      //     elevation:
                      //         4.0, // Ajusta la sombra del card si es necesario
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(
                      //           12.0), // Ajusta el radio del borde si es necesario
                      //     ),
                      //     color: Color.fromARGB(106, 0, 0, 0),
                      //     child: Padding(
                      //       padding: EdgeInsets.only(
                      //           top:
                      //               40.0), // Ajusta el valor para el padding superior
                      //       child: Container(
                      //         width:
                      //             800, // Ajusta este valor según el tamaño deseado para tu gráfico
                      //         height:
                      //             500, // Ajusta este valor según el tamaño deseado para tu gráfico
                      //         child: crearGrafica2(miModelo5
                      //             .lista112), // Pasa los datos de miModelo5.lista11
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(height: 20),

                      tablaDatosUmb(miModelo5.lista11),
                      Footer(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget crearGrafica(List<Fenologia> datosList) {
    // Crear listas de FlSpot para cada umbral y para PCPN
    List<FlSpot> tempMinSpots = [];
    List<FlSpot> tempOptMinSpots = [];
    List<FlSpot> umbInfSpots = [];
    List<FlSpot> umbSupSpots = [];
    List<FlSpot> tempOptMaxSpots = [];
    List<FlSpot> tempMaxSpots = [];

    for (int i = 0; i < datosList.length; i++) {
      tempMinSpots.add(FlSpot(i.toDouble(), datosList[i].tempMin));
      tempOptMinSpots.add(FlSpot(i.toDouble(), datosList[i].tempOptMin));
      umbInfSpots.add(FlSpot(i.toDouble(), datosList[i].umbInf));
      umbSupSpots.add(FlSpot(i.toDouble(), datosList[i].umbSup));
      tempOptMaxSpots.add(FlSpot(i.toDouble(), datosList[i].tempOptMax));
      tempMaxSpots.add(FlSpot(i.toDouble(), datosList[i].tempMax));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gráfico con datos de líneas y barras
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 400,
            width: 800,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: tempMinSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.blue],
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: tempOptMinSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.green],
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: umbInfSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.orange],
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: umbSupSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.red],
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: tempOptMaxSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.purple],
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: tempMaxSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.yellow],
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitles: (value) {
                      return (value.toInt() < datosList.length
                          ? 'Fase ${datosList[value.toInt()].fase}'
                          : '');
                    },
                    getTextStyles: (context, value) => TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 10,
                    getTitles: (value) {
                      return value.toString();
                    },
                    getTextStyles: (context, value) => TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: const Color.fromARGB(255, 12, 70, 170),
                    tooltipRoundedRadius: 8,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                  ),
                ),
                minX: 0,
                maxX: datosList.length.toDouble() - 1,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 900),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.blue, 'Temp Min'),
                _buildLegendItem(Colors.green, 'Temp Opt Min'),
                _buildLegendItem(Colors.orange, 'Umb Inf'),
                _buildLegendItem(Colors.red, 'Umb Sup'),
                _buildLegendItem(Colors.purple, 'Temp Opt Max'),
                _buildLegendItem(Colors.yellow, 'Temp Max'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget crearGrafica3(
    List<Fenologia> datosList, List<DatosPronostico> datosPronostico) {
  // Crear listas de FlSpot para cada umbral y para PCPN
  List<FlSpot> tempMinSpots = [];
  List<FlSpot> tempOptMinSpots = [];
  List<FlSpot> umbInfSpots = [];
  List<FlSpot> umbSupSpots = [];
  List<FlSpot> tempOptMaxSpots = [];
  List<FlSpot> tempMaxSpots = [];

  List<FlSpot> tempMinSpots2 = [];
  List<FlSpot> tempMaxSpots2 = [];

  // Procesar solo hasta i == 3 para datosList
  for (int i = 0; i < datosList.length; i++) {
    tempMinSpots.add(FlSpot(i.toDouble(), datosList[i].tempMin));
    tempOptMinSpots.add(FlSpot(i.toDouble(), datosList[i].tempOptMin));
    umbInfSpots.add(FlSpot(i.toDouble(), datosList[i].umbInf));
    umbSupSpots.add(FlSpot(i.toDouble(), datosList[i].umbSup));
    tempOptMaxSpots.add(FlSpot(i.toDouble(), datosList[i].tempOptMax));
    tempMaxSpots.add(FlSpot(i.toDouble(), datosList[i].tempMax));
  }

  // Procesar solo hasta i == 3 para datosPronostico
  for (int j = 0; j < datosPronostico.length; j++) {
    // Escalar el índice de datosPronostico para encajar dentro del rango 0 a 3
    double xScaled = (j / (datosPronostico.length - 1)) * (miModelo5.faseActual-1);
    tempMinSpots2.add(FlSpot(xScaled, datosPronostico[j].tempMin));
    tempMaxSpots2.add(FlSpot(xScaled, datosPronostico[j].tempMax));
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Gráfico con datos de líneas y barras
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          height: 400,
          width: 1200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: tempMinSpots2,
                  isCurved: true,
                  barWidth: 2,
                  colors: [Color.fromARGB(255, 201, 173, 255)],
                  belowBarData: BarAreaData(show: true),
                ),
                LineChartBarData(
                  spots: tempMaxSpots2,
                  isCurved: true,
                  barWidth: 2,
                  colors: [Color.fromARGB(255, 143, 211, 147)],
                  belowBarData: BarAreaData(show: true),
                ),
                LineChartBarData(
                  spots: tempMinSpots,
                  isCurved: true,
                  barWidth: 2,
                  colors: [Colors.blue],
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: tempOptMinSpots,
                  isCurved: true,
                  barWidth: 2,
                  colors: [Colors.green],
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: umbInfSpots,
                  isCurved: true,
                  barWidth: 2,
                  colors: [Colors.orange],
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: umbSupSpots,
                  isCurved: true,
                  barWidth: 2,
                  colors: [Colors.red],
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: tempOptMaxSpots,
                  isCurved: true,
                  barWidth: 2,
                  colors: [Colors.purple],
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: tempMaxSpots,
                  isCurved: true,
                  barWidth: 2,
                  colors: [Colors.yellow],
                  belowBarData: BarAreaData(show: false),
                ),
                
              ],
              titlesData: FlTitlesData(
                bottomTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 1,
                  getTitles: (value) {
                    return (value.toInt() < datosList.length
                        ? 'Fase ${datosList[value.toInt()].fase}'
                        : '');
                  },
                  getTextStyles: (context, value) => TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leftTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 10,
                  getTitles: (value) {
                    return value.toString();
                  },
                  getTextStyles: (context, value) => TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: const Color.fromARGB(255, 12, 70, 170),
                  tooltipRoundedRadius: 8,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                ),
              ),
              minX: 0,
              maxX: datosList.length.toDouble() - 1, // Limitar el eje X hasta 3
            ),
          ),
        ),
      ),
      SizedBox(height: 10),
      Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 900),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.blue, 'Temp Min'),
              _buildLegendItem(Colors.green, 'Temp Opt Min'),
              _buildLegendItem(Colors.orange, 'Umb Inf'),
              _buildLegendItem(Colors.red, 'Umb Sup'),
              _buildLegendItem(Colors.purple, 'Temp Opt Max'),
              _buildLegendItem(Colors.yellow, 'Temp Max'),
              _buildLegendItem(Colors.brown, 'Temp Max Alt'),
            ],
          ),
        ),
      ),
    ],
  );
}


  Widget crearGrafica2(List<DatosPronostico> datosPronostico) {
    // Crear las listas de FlSpot para temperaturas mínima y máxima
    List<FlSpot> tempMinSpots = [];
    List<FlSpot> tempMaxSpots = [];

    // Iterar sobre los datos de pronóstico y agregar los puntos a las listas de spots
    for (int i = 0; i < datosPronostico.length; i++) {
      tempMinSpots.add(FlSpot(i.toDouble(), datosPronostico[i].tempMin));
      tempMaxSpots.add(FlSpot(i.toDouble(), datosPronostico[i].tempMax));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gráfico con solo los datos de temperatura mínima y máxima
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 400,
            width: 800,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: tempMinSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.blue],
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: tempMaxSpots,
                    isCurved: true,
                    barWidth: 2,
                    colors: [Colors.yellow],
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitles: (value) {
                      return (value.toInt() < datosPronostico.length
                          ? 'Día ${value.toInt() + 1}'
                          : '');
                    },
                    getTextStyles: (context, value) => TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 10,
                    getTitles: (value) {
                      return value.toString();
                    },
                    getTextStyles: (context, value) => TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: const Color.fromARGB(255, 12, 70, 170),
                    tooltipRoundedRadius: 8,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                  ),
                ),
                minX: 0,
                maxX: datosPronostico.length.toDouble() - 1,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 900),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.blue, 'Temp Min'),
                _buildLegendItem(Colors.yellow, 'Temp Max'),
              ],
            ),
          ),
        ),
      ],
    );
  }

// // Función para construir los elementos de la leyenda
// Widget _buildLegendItem(Color color, String label) {
//   return Row(
//     children: [
//       Container(
//         width: 20,
//         height: 20,
//         color: color,
//       ),
//       SizedBox(width: 8),
//       Text(
//         label,
//         style: TextStyle(color: Colors.white),
//       ),
//     ],
//   );
// }

  Widget crearGraficaPCPN(List<Fenologia> datosList) {
    List<FlSpot> pcpnSpots = []; // Lista de puntos para PCPN

    for (int i = 0; i < datosList.length; i++) {
      pcpnSpots.add(FlSpot(i.toDouble(), datosList[i].pcpn)); // Agregar PCPN
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gráfico con datos de líneas y barras
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 400,
            width: 800,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: pcpnSpots,
                    isCurved: false,
                    barWidth: 6,
                    colors: [Colors.cyan],
                    belowBarData: BarAreaData(
                        show: true, colors: [Colors.cyan.withOpacity(0.3)]),
                    dotData: FlDotData(show: false), // Ocultar puntos
                  ),

                  // Añadir PCPN como barras
                ],
                titlesData: FlTitlesData(
                  bottomTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 1,
                    getTitles: (value) {
                      return (value.toInt() < datosList.length
                          ? 'Fase ${datosList[value.toInt()].fase}'
                          : '');
                    },
                    getTextStyles: (context, value) => TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leftTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 10,
                    getTitles: (value) {
                      return value.toString();
                    },
                    getTextStyles: (context, value) => TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: const Color.fromARGB(255, 12, 70, 170),
                    tooltipRoundedRadius: 8,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                  ),
                ),
                minX: 0,
                maxX: datosList.length.toDouble() - 1,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 900),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.cyan, 'PCPN'), // Leyenda para PCPN
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            color: color,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView tablaDatosUmb(List<Fenologia> datosList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Borde redondeado
          // border: Border.all(
          //     color: Color.fromARGB(
          //         255, 156, 245, 219)), // Borde gris alrededor de la tabla
        ),
        child: DataTable(
          // Color de fondo de las filas de datos
          columns: const [
            DataColumn(
                label: Text('Fase',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Temp. letal min',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Temp. opt min',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Umb. inf',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Umb. sup',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Temp. opt max',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Temp. letal max',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
            DataColumn(
                label: Text('Precipitacion',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ))),
          ],
          rows: datosList.map((datos) {
            return DataRow(cells: [
              DataCell(Text('${datos.fase}',
                  style: TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.tempMin}',
                  style: TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.tempOptMin}',
                  style: TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.umbInf}',
                  style: TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.umbSup}',
                  style: TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.tempOptMax}',
                  style: TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.tempMax}',
                  style: TextStyle(
                    color: Colors.white,
                  ))),
              DataCell(Text('${datos.pcpn}',
                  style: TextStyle(
                    color: Colors.white,
                  ))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

DateTime parseFecha(String fecha) {
  return DateTime.parse(fecha);
}

String formatearFecha(DateTime fecha) {
  final DateFormat formatter = DateFormat('MMM d, y', 'es');
  return formatter.format(fecha).toUpperCase();
}

String formatFecha(DateTime date) {
  try {
    // Formato para mostrar el día, número, mes y día de la semana
    return DateFormat('d EEEE, MMM', 'es').format(date);
  } catch (e) {
    // En caso de error, usar un formato alternativo
    return DateFormat('d EEEE, MMM').format(date); // Sin especificar el locale
  }
}

Widget tarjetaPronostico(DatosPronostico datos, bool isMobile) {
  DateTime fechaInicio = datos.fechaRangoDecenal;
  DateTime fechaFinal = fechaInicio.add(Duration(days: 10));

  String fechaFormateada = formatFecha(datos.fechaRangoDecenal);
  String imagen = datos.pcpn > 0 ? 'images/25.png' : 'images/26.png';

  final tempMaxIcon = Icons.thermostat_outlined;
  final tempMinIcon = Icons.thermostat_rounded;
  final pcpnIcon = Icons.water_drop;

  TextStyle textStyle = TextStyle(
    color: Colors.white,
    fontSize: isMobile ? 12 : 13,
  );

  return SizedBox(
    width: isMobile
        ? 100
        : 120, // Ancho fijo y más estrecho para lograr el efecto rectangular
    child: Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color.fromARGB(255, 156, 245, 219)),
      ),
      color: datos.pcpn > 0
          ? Color.fromARGB(119, 128, 253, 255)
          : Color.fromARGB(119, 255, 251, 128),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagen,
              height: isMobile ? 60 : 80,
              width: isMobile ? 60 : 80,
            ),
            SizedBox(height: 10),
            Text(
              fechaFormateada.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: isMobile ? 14 : 15,
              ),
            ),
            SizedBox(height: 10),
            _buildRowWithIcon(
                tempMaxIcon, 'Max: ${datos.tempMax}°C', textStyle),
            SizedBox(height: 8),
            _buildRowWithIcon(
                tempMinIcon, 'Min: ${datos.tempMin}°C', textStyle),
            SizedBox(height: 8),
            _buildRowWithIcon(pcpnIcon, 'PCPN: ${datos.pcpn} mm', textStyle),
          ],
        ),
      ),
    ),
  );
}

Widget _buildRowWithIcon(IconData icon, String text, TextStyle textStyle) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: Colors.white, size: 20),
      SizedBox(width: 8),
      Text(
        text,
        style: textStyle,
      ),
    ],
  );
}

Widget listaTarjetasPronostico(List<DatosPronostico> datosList,
    ScrollController scrollController, BuildContext context) {
  // Determina si es un dispositivo móvil
  bool isMobile = MediaQuery.of(context).size.width < 600;

  return Scrollbar(
    controller: scrollController,
    thumbVisibility: true,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Desplazamiento horizontal
      controller: scrollController,
      child: Row(
        children: datosList.map((datos) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: isMobile
                  ? 150
                  : 200, // Ajusta el ancho mínimo según el dispositivo
            ),
            child: tarjetaPronostico(datos, isMobile), // Pasa isMobile aquí
          );
        }).toList(),
      ),
    ),
  );
}
