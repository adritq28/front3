import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/Administrador/Meteorologia/AnadirDatoMeteorologicoScreen.dart';
import 'package:helvetasfront/screens/Administrador/Meteorologia/EditarMeteorologicaScreen.dart';
import 'package:helvetasfront/screens/Administrador/Meteorologia/GraficaScreen.dart';
import 'package:helvetasfront/screens/Administrador/Meteorologia/VisualizarMeteorologicaScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DatosMeteorologicaScreen extends StatefulWidget {
  final int idEstacion;
  final String nombreMunicipio;
  final String nombreEstacion;

  const DatosMeteorologicaScreen({
    required this.idEstacion,
    required this.nombreMunicipio,
    required this.nombreEstacion,
  });

  @override
  _DatosMeteorologicaScreenState createState() =>
      _DatosMeteorologicaScreenState();
}

class _DatosMeteorologicaScreenState extends State<DatosMeteorologicaScreen> {
  List<Map<String, dynamic>> datos = [];
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

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  late EstacionService miModelo4;
  String url = Url().apiUrl;
  String ip = Url().ip;
  
  @override
  void initState() {
    super.initState();
    fetchDatosMeteorologicos();
  }

  Future<void> fetchDatosMeteorologicos() async {
    final response = await http.get(
      Uri.parse(
          url+'/estacion/lista_datos_meteorologica/${widget.idEstacion}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        datos = List<Map<String, dynamic>>.from(json.decode(response.body));
        datosFiltrados = datos;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load datos meteorologicos');
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

    int mesIndex = meses.indexOf(mes) + 1;

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

  void editarDato(int index) async {
    Map<String, dynamic> dato = datos[index];

    bool? cambiosGuardados = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarMeteorologicaScreen(
          idDatosEst: dato['idDatosEst'],
          tempMax: dato['tempMax']?? 0.0,
          tempMin: dato['tempMin']?? 0.0,
          pcpn: dato['pcpn']?? 0.0,
          tempAmb: dato['tempAmb']?? 0.0,
          dirViento: dato['dirViento']?? '',
          velViento: dato['velViento']?? 0.0,
          taevap: dato['taevap']?? 0.0,
          fechaReg: dato['fechaReg']?? '',
        ),
      ),
    );

    if (cambiosGuardados == true) {
      fetchDatosMeteorologicos();
    }
  }

  void visualizarDato(int index) {
  try {
    Map<String, dynamic> dato = datos[index];
    int idDatosEst = dato['idDatosEst'] ?? 0;
    double tempMax = dato['tempMax'] ?? 0.0;
    double tempMin = dato['tempMin'] ?? 0.0;
    double pcpn = dato['pcpn'] ?? 0.0;
    double tempAmb = dato['tempAmb'] ?? 0.0; // Default value if null
    String dirViento = dato['dirViento'] ?? '';
    double velViento = dato['velViento'] ?? 0.0; // Default value if null
    double taevap = dato['taevap'] ?? 0.0; // Default value if null
    String fechaReg = dato['fechaReg'] ?? '';

    // Intentar parsear la fecha
    DateTime fechaRegistro;
    try {
      fechaRegistro = DateTime.parse(fechaReg);
    } catch (e) {
      print('Error al parsear la fecha: $e');
      fechaRegistro = DateTime.now(); // o asigna un valor por defecto
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisualizarMeteorologicaScreen(
          idDatosEst: idDatosEst,
          tempMax: tempMax,
          tempMin: tempMin,
          pcpn: pcpn,
          tempAmb: tempAmb,
          dirViento: dirViento,
          velViento: velViento,
          taevap: taevap,
          fechaReg: fechaRegistro.toIso8601String(), // Conviértelo a String si es necesario
        ),
      ),
    );
    print('Visualizar dato en la posición $index');
  } catch (e) {
    print('Error al intentar visualizar el dato en la posición $index: $e');
  }
}

  void eliminarDato(int index) async {
    Map<String, dynamic> dato = datosFiltrados[index];
    int idDatosEst = dato['idDatosEst'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro que deseas eliminar estos datos?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () async {
                Navigator.of(context).pop();

                final url2 = Uri.parse(
                    url+'/estacion/eliminar/$idDatosEst');
                final headers = {'Content-Type': 'application/json'};
                final response = await http.delete(url2, headers: headers);

                if (response.statusCode == 200) {
                  setState(() {
                    datos.removeAt(index);
                    datosFiltrados = datosFiltrados
                        .where((dato) => dato['idDatosEst'] != idDatosEst)
                        .toList();
                  });
                  print('Dato eliminado correctamente');
                } else {
                  print('Error al intentar eliminar el dato');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void anadirDato() async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AnadirDatoMeteorologicoScreen(idEstacion: widget.idEstacion)),
    );

    if (result == true) {
      fetchDatosMeteorologicos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.soloNombreTelefono,), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(isHomeScreen: false, idUsuario: 0, estado: PerfilEstado.soloNombreTelefono,), // Indicamos que es la pantalla principal
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
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage("images/47.jpg"),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Municipio de: ${widget.nombreMunicipio}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(208, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Estación Meteorológica: ${widget.nombreEstacion}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(208, 255, 255, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  // Dentro de tu Widget build donde tienes los botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: anadirDato,
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Añadir',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 142, 146, 143),
                        ),
                      ),
                      const SizedBox(width: 5),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GraficaScreen(datos: datosFiltrados),
                            ),
                          );
                        },
                        icon: Icon(Icons.show_chart, color: Colors.white),
                        label: Text(
                          'Gráfica',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 142, 146, 143),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Expanded(
                          child: kIsWeb
                              ? Scrollbar(
                                  thumbVisibility:
                                      true, // Mostrar la barra de desplazamiento en la web
                                  controller: _horizontalScrollController,
                                  child: SingleChildScrollView(
                                    controller: _horizontalScrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      controller: _verticalScrollController,
                                      child: SingleChildScrollView(
                                        controller: _verticalScrollController,
                                        scrollDirection: Axis.vertical,
                                        child: DataTable(
                                          columns: const [
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
                                                'Temp Max',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Temp Min',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Precipitación',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Temp Ambiente',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Dir Viento',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Vel Viento',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Evaporación',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Acciones',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                          rows: datosFiltrados.map((dato) {
                                            int index =
                                                datosFiltrados.indexOf(dato);
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Text(
                                                    formatDateTime(
                                                        dato['fechaReg']
                                                            ?.toString()),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['tempMax'].toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['tempMin'].toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['pcpn'].toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['tempAmb'].toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['dirViento']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['velViento']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['taevap'].toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () =>
                                                            editarDato(index),
                                                        child: MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .click,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    7),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: Color(
                                                                  0xFFF0B27A),
                                                            ),
                                                            child: Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.white,
                                                              size: 24,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      GestureDetector(
                                                        onTap: () =>
                                                            visualizarDato(
                                                                index),
                                                        child: MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .click,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    7),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: Color(
                                                                  0xFF58D68D),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .remove_red_eye_sharp,
                                                              color:
                                                                  Colors.white,
                                                              size: 24,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      GestureDetector(
                                                        onTap: () =>
                                                            eliminarDato(index),
                                                        child: MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .click,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    7),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: Color(
                                                                  0xFFEC7063),
                                                            ),
                                                            child: Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.white,
                                                              size: 24,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    controller: _horizontalScrollController,
                                    child: SingleChildScrollView(
                                      controller: _horizontalScrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: DataTable(
                                          columns: const [
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
                                                'Temp Max',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Temp Min',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Precipitación',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Temp Ambiente',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Dir Viento',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Vel Viento',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Evaporación',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Acciones',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                          rows: datosFiltrados.map((dato) {
                                            int index =
                                                datosFiltrados.indexOf(dato);
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Text(
                                                    formatDateTime(
                                                        dato['fechaReg']
                                                            ?.toString()),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['tempMax'].toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['tempMin'].toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['pcpn'].toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['tempAmb'].toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['dirViento']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['velViento']
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    dato['taevap'].toString(),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () =>
                                                            editarDato(index),
                                                        child: MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .click,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    7),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: Color(
                                                                  0xFFF0B27A),
                                                            ),
                                                            child: Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.white,
                                                              size: 24,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      GestureDetector(
                                                        onTap: () =>
                                                            visualizarDato(
                                                                index),
                                                        child: MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .click,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    7),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: Color(
                                                                  0xFF58D68D),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .remove_red_eye_sharp,
                                                              color:
                                                                  Colors.white,
                                                              size: 24,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      GestureDetector(
                                                        onTap: () =>
                                                            eliminarDato(index),
                                                        child: MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .click,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    7),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: Color(
                                                                  0xFFEC7063),
                                                            ),
                                                            child: Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.white,
                                                              size: 24,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                        
                                      ),
                                      
                                    ),
                                    
                                  ),
                                  
                                ),
                                
                        ),
                ],
              ),
              
            ),
            
          ),
        ],
      ),
      
    );
  }
}
