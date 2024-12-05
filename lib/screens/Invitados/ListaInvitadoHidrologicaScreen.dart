import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/Utils/mobile_utils.dart';
import 'package:helvetasfront/model/DatosEstacionHidrologica.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionHidrologicaService.dart';
import 'package:helvetasfront/url.dart';
import 'package:helvetasfront/util/download_helper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';


class ListaInvitadoHidrologicaScreen extends StatefulWidget {
  final int idEstacion;
  final String nombreMunicipio;
  final String nombreEstacion;

  const ListaInvitadoHidrologicaScreen({
    required this.idEstacion,
    required this.nombreMunicipio,
    required this.nombreEstacion,
  });

  @override
  _ListaInvitadoHidrologicaScreenState createState() =>
      _ListaInvitadoHidrologicaScreenState();
}

class _ListaInvitadoHidrologicaScreenState extends State<ListaInvitadoHidrologicaScreen> {
  final EstacionHidrologicaService _datosService2 = EstacionHidrologicaService();
  late Future<List<DatosEstacionHidrologica>> _futureDatosEstacion;
  late List<Map<String, dynamic>> datos = [];
  bool isLoading = true;
  List<Map<String, dynamic>> datosFiltrados = [];
  String? mesSeleccionado;
  List<String> meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];
  String url = Url().apiUrl;
  String ip = Url().ip;

  @override
  void initState() {
    super.initState();
    fetchDatosHidrologico();
  }

  Future<String> obtNombreObservador(int idEstacion) async {
    final String apiUrl2 =
        url + '/estacion/nombre_observador/${widget.idEstacion}';

    try {
      final response = await http.get(Uri.parse(apiUrl2));

      if (response.statusCode == 200) {
        // Suponiendo que el nombre del observador se devuelve directamente como un String
        return response.body;
      } else {
        throw Exception(
            'Error al obtener el nombre del observador: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }


  Future<void> fetchDatosHidrologico() async {
    final response = await http.get(
      Uri.parse(
          url + '/estacion/lista_datos_hidrologica/${widget.idEstacion}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        datos = List<Map<String, dynamic>>.from(json.decode(response.body));
        datosFiltrados = datos; // Inicialmente, no se filtra nada
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load datos hidrologicos');
    }
  }

  Future<void> exportToExcel(List<Map<String, dynamic>> datosList,
    String nombreMunicipio,
    String nombreEstacion,
    String departamento,
    String nombreObservador,) async {
  try {
    var excel = excel_pkg.Excel.createExcel();
    var sheet = excel['Sheet1'];

    // Escribir la información inicial en las celdas específicas
      sheet.cell(CellIndex.indexByString("A1")).value =
          nombreMunicipio; // Municipio
      sheet.cell(CellIndex.indexByString("A2")).value =
          "Estación:"; // Etiqueta Estación
      sheet.cell(CellIndex.indexByString("B2")).value =
          nombreEstacion; // Nombre Estación
      sheet.cell(CellIndex.indexByString("A3")).value =
          "Departamento:"; // Etiqueta Departamento
      sheet.cell(CellIndex.indexByString("B3")).value =
          departamento; // Nombre Departamento
      sheet.cell(CellIndex.indexByString("A4")).value =
          "Observador:"; // Etiqueta Observador
      sheet.cell(CellIndex.indexByString("B4")).value =
          nombreObservador; // Nombre Observador

    // Escribir los encabezados
    sheet.appendRow([
      'Fecha',
      'Limnimetro',  
    ]);

    // Escribir los datos
    for (var dato in datosList) {
      sheet.appendRow([
        formatDateTime(dato['fechaReg']?.toString()),
        dato['limnimetro'] ?? '',
      ]);
    }

    var fileBytes = excel.save();
    if (fileBytes == null) {
      throw Exception('No se pudo generar el archivo Excel.');
    }

    if (kIsWeb) {
      // Código para la web (debes tener implementado el código para descargar archivos en la web)
      await downloadExcelMobile(fileBytes, "DatosHidrologicos.xlsx");
    } else {
      // Código para dispositivos móviles
      final directory = await getExternalStorageDirectory(); // O usa getApplicationDocumentsDirectory si prefieres
      final filePath = '${directory!.path}/DatosHidrologicos.xlsx';
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
      String nombreObservador = await obtNombreObservador(widget.idEstacion);
      exportToExcel(datosFiltrados, widget.nombreMunicipio,
          widget.nombreEstacion, "La Paz", nombreObservador);
    } catch (e) {
      print('Error al exportar los datos: $e');
    }
  }

  Future<void> exportToCSV(
  List<Map<String, dynamic>> datosList,
  String nombreMunicipio,
  String nombreEstacion,
  String departamento,
  String nombreObservador,
) async {
  try {
    List<List<dynamic>> rows = [
      [
        "ID",
        "Fecha Registro"
        "Limnimetro",
        
      ]
    ];

    for (var dato in datosList) {
      List<dynamic> row = [
        dato['idHidrologica']?.toString() ?? ' ',
        formatDateTime(dato['fechaReg']?.toString()),
        dato['limnimetro'] ?? '',
      ];
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);
    List<int> fileBytes = utf8.encode(csv);

    if (fileBytes.isEmpty) {
      throw Exception('No se pudo generar el archivo CSV.');
    }

    if (kIsWeb) {
      // Código para la web
      await downloadForWeb(fileBytes, "DatosHidrologicos.csv");
    } else {
      // Código para dispositivos móviles
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/DatosMeteorologicos.csv';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      OpenFile.open(filePath);
    }
    print('Archivo listo para descargar');
  } catch (e) {
    print('Error al guardar el archivo: ${e.toString()}');
  }
}



  void exportarDatoCSV() async {
    try {
      String nombreObservador = await obtNombreObservador(widget.idEstacion);
      exportToCSV(datosFiltrados, widget.nombreMunicipio, widget.nombreEstacion,
          "La Paz", nombreObservador);
    } catch (e) {
      print('Error al exportar los datos: $e');
    }
  }

  String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Fecha no disponible';
    }
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
    } catch (e) {
      print('Error al parsear la fecha: $dateTimeString');
      return 'Fecha inválida';
    }
  }

  void filtrarDatosPorMes(String? mes) {
    if (mes == null || mes.isEmpty) {
      setState(() {
        datosFiltrados = datos;
      });
      return;
    }

    int mesIndex = meses.indexOf(mes) + 1; // Meses son 1-indexados en DateTime

    setState(() {
      datosFiltrados = datos.where((dato) {
        try {
          DateTime fecha = DateTime.parse(dato['fechaReg']);
          return fecha.month == mesIndex;
        } catch (e) {
          print('Error al parsear la fecha: ${dato['fechaReg']}');
          return false;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.nombreEstacionMunicipio,
        nombreMunicipio: widget.nombreMunicipio,
        nombreEstacion: widget.nombreEstacion), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(isHomeScreen: false, idUsuario: 0,estado: PerfilEstado.nombreEstacionMunicipio,), // Indicamos que es la pantalla principal
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'images/fondo.jpg'), // Ruta de la imagen de fondo
                fit: BoxFit
                    .cover, // Ajustar la imagen para cubrir todo el contenedor
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(height: 10),
                  Container(
                    height: 90,
                    color: Color.fromARGB(
                        51, 25, 25, 26), // Fondo negro con 20% de opacidad
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage("images/47.jpg"),
                        ),
                        SizedBox(width: 15),
                        Flexible(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10.0,
                            runSpacing: 5.0,
                            children: [
                              Text(
                                "Bienvenido Invitado",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                        '| Municipio de: ${widget.nombreMunicipio}',
                                        style: GoogleFonts.lexend(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12))),
                              Text(
                                '| Estación Hidrológica: ${widget.nombreEstacion}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(208, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width *
                        0.5, // Ajusta el ancho según tus necesidades
                    child: DropdownButton<String>(
                      value: mesSeleccionado,
                      hint: Text(
                        'Seleccione un mes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          mesSeleccionado = newValue;
                          filtrarDatosPorMes(newValue);
                        });
                      },
                      items: meses.map<DropdownMenuItem<String>>((String mes) {
                        return DropdownMenuItem<String>(
                          value: mes,
                          child: Text(
                            mes,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 185, 223,
                                  255), // Cambia el color del texto en el DropdownMenuItem
                            ),
                          ),
                        );
                      }).toList(),
                      dropdownColor: Colors.grey[
                          800], // Cambia el color de fondo del menú desplegable
                      style: const TextStyle(
                        color: Colors
                            .white, // Cambia el color del texto del DropdownButton
                      ),
                      iconEnabledColor:
                          Colors.white, // Cambia el color del icono desplegable
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
  builder: (context, constraints) {
    // Check if the screen width is less than a certain threshold
    if (constraints.maxWidth < 600) { // Adjust this value as needed
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: exportarDato,
            icon: Icon(Icons.downloading, color: Colors.white),
            label: Text(
              'Exportar Excel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFF58D68D), // Color plomo
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
          ),
          const SizedBox(height: 5),
          TextButton.icon(
            onPressed: exportarDatoCSV,
            icon: Icon(Icons.downloading, color: Colors.white),
            label: Text(
              'Exportar CSV',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFF3498db), // Color plomo
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
          ),
          //const SizedBox(height: 5),
        ],
      );
    } else {
      // For larger screens, display buttons in a row
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: exportarDato,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              'Exportar Excel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFF58D68D), // Color plomo
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
          ),
          const SizedBox(width: 5),
          TextButton.icon(
            onPressed: exportarDatoCSV,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              'Exportar CSV',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFF3498db), // Color plomo
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Border radius
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
          ),
          
        ],
      );
    }
  },
)

,

                  const SizedBox(height: 10),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Expanded(
                          child: SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: [
                                  DataColumn(
                                    label: Text(
                                      'Fecha',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Limnimetro',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: datosFiltrados.map((dato) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          formatDateTime(
                                              dato['fechaReg'].toString()),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          dato['limnimetro'].toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                  // Añadido Footer aquí
                  const SizedBox(height: 20),
                  Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


