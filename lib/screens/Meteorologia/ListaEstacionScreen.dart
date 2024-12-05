import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/screens/Administrador/Meteorologia/EditarMeteorologicaScreen.dart';
import 'package:helvetasfront/screens/Administrador/Meteorologia/GraficaScreen.dart';
import 'package:helvetasfront/screens/Administrador/Meteorologia/VisualizarMeteorologicaScreen.dart';
import 'package:helvetasfront/screens/VoiceTextField.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/textos.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ListaEstacionScreen extends StatefulWidget {
  final int idUsuario;
  final String nombreMunicipio;
  final String nombreEstacion;
  final String tipoEstacion;
  final String nombreCompleto;
  final String telefono;
  final int idEstacion;
  final bool codTipoEstacion;
  final String imagen;

  ListaEstacionScreen(
      {required this.idUsuario,
      required this.nombreMunicipio,
      required this.nombreEstacion,
      required this.tipoEstacion,
      required this.nombreCompleto,
      required this.telefono,
      required this.idEstacion,
      required this.codTipoEstacion,
      required this.imagen});

  @override
  _ListaEstacionScreenState createState() => _ListaEstacionScreenState();
}

class _ListaEstacionScreenState extends State<ListaEstacionScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  List<Map<String, dynamic>> datos = [];
  bool isLoading = true;
  List<Map<String, dynamic>> datosFiltrados = [];
  String? mesSeleccionado;
  List<String> meses = [
    'Todos',
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

  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tempMaxController = TextEditingController();
  final TextEditingController _tempMinController = TextEditingController();
  final TextEditingController _pcpnController = TextEditingController();
  final TextEditingController _tempAmbController = TextEditingController();
  final TextEditingController _dirVientoController = TextEditingController();
  final TextEditingController _velVientoController = TextEditingController();
  final TextEditingController _taevapController = TextEditingController();
  late DateTime fechaReg = DateTime.now();
  String url = Url().apiUrl;
  String ip = Url().ip;
  String? _selectedDirection = 'N';
  bool _isButtonDisabled = false;

  // Formateador para obtener solo la fecha (sin la hora)
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    fetchDatosMeteorologicos();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkButtonStatus(widget.idUsuario);
    });
  }

  @override
  void dispose() {
    _tempMaxController.dispose();
    _tempMinController.dispose();
    _pcpnController.dispose();
    _tempAmbController.dispose();
    _dirVientoController.dispose();
    _velVientoController.dispose();
    _taevapController.dispose();
    fechaReg;
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }

  Future<void> _checkButtonStatus(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastClickDate = prefs.getString('lastClickDate_$userId');
      final todayDate = DateTime.now().toIso8601String().split('T').first;

      setState(() {
        _isButtonDisabled = lastClickDate == todayDate;
      });
    } catch (e) {
      print('Error checking button status: $e');
    }
  }

  Future<void> _handleButtonPress(String userId) async {
    if (_isButtonDisabled) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('lastClickDate_$userId', todayDate);
    setState(() {
      _isButtonDisabled = true;
    });
    guardarDato();
  }

  Future<void> guardarDato() async {
    if (_formKey.currentState!.validate()) {
      // Prepare the new data
      final newDato = {
        'idEstacion': widget.idEstacion,
        'tempMax': _tempMaxController.text.isEmpty
            ? null
            : double.parse(_tempMaxController.text),
        'tempMin': _tempMinController.text.isEmpty
            ? null
            : double.parse(_tempMinController.text),
        'pcpn': _pcpnController.text.isEmpty
            ? null
            : double.parse(_pcpnController.text),
        'tempAmb': _tempAmbController.text.isEmpty
            ? null
            : double.parse(_tempAmbController.text),
        'dirViento': _dirVientoController.text,
        'velViento': _velVientoController.text.isEmpty
            ? null
            : double.parse(_velVientoController.text),
        'taevap': _taevapController.text.isEmpty
            ? null
            : double.parse(_taevapController.text),
        'fechaReg': DateTime.now().toIso8601String(),
      };

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Confirme los datos ingresados por favor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: Color(0xFF34495e),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- Temperatura máxima: ${newDato['tempMax']?.toString() ?? 'N/A'} °C',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 600 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- Temperatura mínima: ${newDato['tempMin']?.toString() ?? 'N/A'} °C',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 600 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- Precipitación: ${newDato['pcpn']?.toString() ?? 'N/A'} mm',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 600 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- Temperatura ambiente: ${newDato['tempAmb']?.toString() ?? 'N/A'} °C',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 600 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- Dirección del viento: ${newDato['dirViento']?.toString() ?? 'N/A'}',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 600 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- Velocidad del viento: ${newDato['velViento']?.toString() ?? 'N/A'} km/h',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 600 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- Tasa de evaporación: ${newDato['taevap']?.toString() ?? 'N/A'} mm/h',
                    style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 600 ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFe74c3c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF1abc9c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                ),
                onPressed: () async {
                  // Proceed with saving the data
                  final response = await http.post(
                    Uri.parse(url + '/datosEstacion/addDatosEstacion'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(newDato),
                  );

                  if (response.statusCode == 201) {
                    await fetchDatosMeteorologicos();
                    Navigator.of(context).pop();

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFFf0f0f0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text(
                            'Dato guardado correctamente',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              color: Color(0xFF34495e),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Dato añadido correctamente. AVISO: Este formulario estará habilitado para EDITAR el dato hasta las 00:00 horas del día de hoy.',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width < 600
                                  ? 14
                                  : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1abc9c),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 20),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                            ),
                          ],
                        );
                      },
                    );

                    // Clear fields after saving
                    _tempMaxController.clear();
                    _tempMinController.clear();
                    _pcpnController.clear();
                    _tempAmbController.clear();
                    _dirVientoController.clear();
                    _velVientoController.clear();
                    _taevapController.clear();
                  } else {
                    final errorMessage = response.body;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error al añadir dato: $errorMessage')),
                    );
                  }
                },
                child: const Text('Sí',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ],
          );
        },
      );
    }

    // Store the last click date in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'lastClickDate', DateTime.now().toIso8601String().split('T').first);
    setState(() {
      _isButtonDisabled = true;
    });
  }

  void visualizarDato(int index) {
    try {
      Map<String, dynamic> dato = datos[index];

      // Assign default values for fields that are null
      int idDatosEst = dato['idDatosEst'] ?? 0;
      double tempMax = dato['tempMax'] ?? 0.0;
      double tempMin = dato['tempMin'] ?? 0.0;
      double pcpn = dato['pcpn'] ?? 0.0;
      double tempAmb = dato['tempAmb'] ?? 0.0; // Default value if null
      String dirViento = dato['dirViento'] ?? '';
      double velViento = dato['velViento'] ?? 0.0; // Default value if null
      double taevap = dato['taevap'] ?? 0.0; // Default value if null
      String fechaReg = dato['fechaReg'] ?? '';

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
            fechaReg: fechaReg,
          ),
        ),
      );
      print('Visualizar dato en la posición $index');
    } catch (e) {
      print('Error al intentar visualizar el dato en la posición $index: $e');
    }
  }

  void editarDato(int index) async {
    Map<String, dynamic> dato = datos[index];

    bool? cambiosGuardados = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarMeteorologicaScreen(
          idDatosEst: dato['idDatosEst'],
          tempMax: dato['tempMax'] ??
              0.0, // Asegúrate de que los valores no sean null
          tempMin: dato['tempMin'] ?? 0.0,
          pcpn: dato['pcpn'] ?? 0.0,
          tempAmb: dato['tempAmb'] ?? 0.0,
          dirViento: dato['dirViento'] ?? '',
          velViento: dato['velViento'] ?? 0.0,
          taevap: dato['taevap'] ?? 0.0,
          fechaReg: dato['fechaReg'] ?? '',
        ),
      ),
    ); //??
    //false; // Si no se devuelve ningún valor (null), asignar false

    // Solo recargar datos si se hicieron cambios
    if (cambiosGuardados == true) {
      fetchDatosMeteorologicos();
    }
  }

  bool _esUltimoRegistroDelDia(
      Map<String, dynamic> dato, List<Map<String, dynamic>> datosFiltrados) {
    final fechaActual = DateTime.now();
    final fechaDato = DateTime.parse(dato['fechaReg']);
    final esMismoDia = fechaDato.year == fechaActual.year &&
        fechaDato.month == fechaActual.month &&
        fechaDato.day == fechaActual.day;

    // Comprueba si es el último dato ingresado hoy
    return esMismoDia &&
        dato ==
            datosFiltrados.lastWhere(
                (d) => DateTime.parse(d['fechaReg']).day == fechaActual.day);
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
    if (mes == null || mes.isEmpty || mes == 'Todos') {
      setState(() {
        datosFiltrados = datos;
      });
      return;
    }

    int mesIndex = meses.indexOf(mes); // Restar 1 para ajustar el índice

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

  Future<void> fetchDatosMeteorologicos() async {
    final response = await http.get(
      Uri.parse(
          url + '/estacion/lista_datos_meteorologica/${widget.idEstacion}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        datos = List<Map<String, dynamic>>.from(json.decode(response.body));
        datosFiltrados = datos; // Inicialmente, no se filtra nada
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load datos meteorologicos');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final String fechaActual = dateFormat.format(DateTime.now());
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: widget.idUsuario,
        estado: PerfilEstado.nombreEstacionMunicipio,
        nombreMunicipio: widget.nombreMunicipio, // Pasar nombreMunicipio
        nombreEstacion: widget.nombreEstacion,
      ), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(
          isHomeScreen: false,
          showProfileButton: true, idUsuario: widget.idUsuario,
          estado: PerfilEstado.nombreEstacionMunicipio,
          nombreMunicipio: widget.nombreMunicipio, // Pasar nombreMunicipio
          nombreEstacion: widget.nombreEstacion,
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
          const SizedBox(height: 90),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
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
                        backgroundImage: AssetImage("images/${widget.imagen}"),
                      ),
                      SizedBox(width: 15),
                      Flexible(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.0,
                          runSpacing: 5.0,
                          children: [
                            Text("Bienvenid@",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lexend(
                                    textStyle: TextStyle(
                                  color: Colors.white60,
                                  //fontWeight: FontWeight.bold,
                                ))),
                            Text(' ${widget.nombreCompleto}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lexend(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12))),
                            Text('| Municipio de: ${widget.nombreMunicipio}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lexend(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12))),
                            Text('| Estacion de: ${widget.nombreEstacion}',
                                textAlign: TextAlign.center,
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
                SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(width: 5),
                            Container(
                              width: 200,
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
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GraficaScreen(
                                            datos: datosFiltrados),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.show_chart,
                                      color: Colors.white),
                                  label: Text(
                                    'Ver Gráfica',
                                    style: getTextStyleNormal20(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        //const SizedBox(width: 10),
                        formDatosEstacion(),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Si el ancho de la pantalla es menor que 600 px, es un dispositivo móvil
                            bool isMobile = constraints.maxWidth < 600;
                            final textStyle = getTextStyle(constraints);

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: isMobile
                                    ? 20
                                    : 30, // Espaciado entre columnas
                                dataRowHeight:
                                    isMobile ? 40 : 56, // Altura de las filas
                                headingRowHeight: isMobile
                                    ? 40
                                    : 56, // Altura de la fila de encabezado
                                columns: [
                                  DataColumn(
                                      label: Text('Nro', style: textStyle)),
                                  DataColumn(
                                      label: Text('Fecha', style: textStyle)),
                                  DataColumn(
                                      label:
                                          Text('Temp Max', style: textStyle)),
                                  DataColumn(
                                      label:
                                          Text('Temp Min', style: textStyle)),
                                  DataColumn(
                                      label: Text('Precipitacion',
                                          style: textStyle)),
                                  DataColumn(
                                      label: Text('Temp. Ambiente',
                                          style: textStyle)),
                                  DataColumn(
                                      label:
                                          Text('Dir Viento', style: textStyle)),
                                  DataColumn(
                                      label:
                                          Text('Vel Viento', style: textStyle)),
                                  DataColumn(
                                      label: Text('Evaporacion',
                                          style: textStyle)),
                                  DataColumn(
                                      label:
                                          Text('Acciones', style: textStyle)),
                                ],
                                rows: List<DataRow>.generate(
                                    datosFiltrados.length, (index) {
                                  final dato = datosFiltrados[index];
                                  final esUltimoRegistroHoy =
                                      _esUltimoRegistroDelDia(
                                          dato, datosFiltrados);

                                  return DataRow(
                                    cells: [
                                      DataCell(Center(
                                          child: Text((index + 1).toString(),
                                              style: textStyle))),
                                      DataCell(Center(
                                          child: Text(
                                              formatDateTime(
                                                  dato['fechaReg']?.toString()),
                                              style: textStyle))),
                                      DataCell(Center(
                                          child: Text(
                                              dato['tempMax'].toString(),
                                              style: textStyle))),
                                      DataCell(Center(
                                          child: Text(
                                              dato['tempMin'].toString(),
                                              style: textStyle))),
                                      DataCell(Center(
                                          child: Text(
                                              dato['pcpn']?.toString() ?? ' ',
                                              style: textStyle))),
                                      DataCell(Center(
                                          child: Text(
                                              dato['tempAmb']?.toString() ??
                                                  ' ',
                                              style: textStyle))),
                                      DataCell(Center(
                                          child: Text(
                                              dato['dirViento']?.toString() ??
                                                  ' ',
                                              style: textStyle))),
                                      DataCell(Center(
                                          child: Text(
                                              dato['velViento']?.toString() ??
                                                  ' ',
                                              style: textStyle))),
                                      DataCell(Center(
                                          child: Text(
                                              dato['taevap']?.toString() ?? ' ',
                                              style: textStyle))),
                                      DataCell(
                                        Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center, // Center the Row
                                            children: [
                                              const SizedBox(width: 5),
                                              GestureDetector(
                                                onTap: dateFormat.format(DateTime
                                                            .parse(datos[index][
                                                                'fechaReg'])) ==
                                                        fechaActual
                                                    ? () => editarDato(index)
                                                    : null,
                                                child: MouseRegion(
                                                  cursor: dateFormat.format(
                                                              DateTime.parse(datos[
                                                                      index][
                                                                  'fechaReg'])) ==
                                                          fechaActual
                                                      ? SystemMouseCursors
                                                          .click // Show hand cursor if active
                                                      : SystemMouseCursors
                                                          .basic, // Show default cursor if disabled
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        isMobile ? 5 : 7),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: dateFormat.format(
                                                                  DateTime.parse(
                                                                      datos[index]
                                                                          [
                                                                          'fechaReg'])) ==
                                                              fechaActual
                                                          ? Color(
                                                              0xFFF0B27A) // Active color
                                                          : const Color
                                                              .fromARGB(
                                                              107,
                                                              158,
                                                              158,
                                                              158), // Disabled color
                                                    ),
                                                    child: Icon(
                                                      Icons.edit,
                                                      color: Color.fromARGB(
                                                          192, 255, 255, 255),
                                                      size: isMobile ? 20 : 24,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              GestureDetector(
                                                onTap: () =>
                                                    visualizarDato(index),
                                                child: MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        isMobile ? 5 : 7),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Color(0xFF58D68D),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .remove_red_eye_sharp,
                                                      color: Colors.white,
                                                      size: isMobile ? 20 : 24,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget formDatosEstacion() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Condicional para decidir si mostrar en una o dos columnas
            bool isSmallScreen = constraints.maxWidth < 600;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 15),
                // Aquí hacemos la fila o columna condicional
                isSmallScreen
                    ? Column(
                        children: [
                          // Inputs en una columna para pantallas pequeñas
                          VoiceTextField(
                            controller: _tempMaxController,
                            labelText: 'Temp Max',
                            icon: Icons.thermostat,
                            style: getTextStyForm(),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa la temperatura máxima';
                              }
                              final double? tempMax = double.tryParse(value);
                              if (tempMax == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (tempMax < -5 || tempMax > 35) {
                                return 'La temperatura debe estar entre -18 y 15';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _tempMinController,
                            decoration: _getInputDecoration(
                                'Temp Min', Icons.thermostat),
                            style: getTextStyForm(),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa la temperatura mínima';
                              }
                              final double? tempMin = double.tryParse(value);
                              if (tempMin == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (tempMin < -18 || tempMin > 15) {
                                return 'La temperatura debe estar entre -18 y 15';
                              }
                              return null;
                            },
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: VoiceTextField(
                              controller: _tempMaxController,
                              labelText: 'Temp Max',
                              icon: Icons.thermostat,
                              style: getTextStyForm(),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa la temperatura máxima';
                                }
                                final double? tempMax = double.tryParse(value);
                                if (tempMax == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (tempMax < -5 || tempMax > 35) {
                                  return 'La temperatura debe estar entre -18 y 15';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: TextFormField(
                              controller: _tempMinController,
                              decoration: _getInputDecoration(
                                  'Temp Min', Icons.thermostat),
                              style: getTextStyForm(),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa la temperatura mínima';
                                }
                                final double? tempMin = double.tryParse(value);
                                if (tempMin == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (tempMin < -18 || tempMin > 15) {
                                  return 'La temperatura debe estar entre -18 y 15';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 15),
                // Repetir esta estructura para otros campos también
                isSmallScreen
                    ? Column(
                        children: [
                          TextFormField(
                            controller: _pcpnController,
                            decoration: _getInputDecoration(
                                'Precipitación', Icons.water),
                            style: getTextStyForm(),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null; // Permitir campo vacío
                              }
                              final double? precipitation =
                                  double.tryParse(value);
                              if (precipitation == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (precipitation < 0 || precipitation > 70) {
                                return 'La precipitación debe estar entre 0 y 50';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _tempAmbController,
                            decoration: _getInputDecoration(
                                'Temp Ambiente', Icons.thermostat),
                            style: getTextStyForm(),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null; // Permitir campo vacío
                              }
                              final double? tempAmb = double.tryParse(value);
                              if (tempAmb == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (tempAmb < 0 || tempAmb > 90) {
                                return 'La temperatura ambiente debe estar entre 0 y 90';
                              }
                              return null;
                            },
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pcpnController,
                              decoration: _getInputDecoration(
                                  'Precipitación', Icons.water),
                              style: getTextStyForm(),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null; // Permitir campo vacío
                                }
                                final double? precipitation =
                                    double.tryParse(value);
                                if (precipitation == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (precipitation < 0 || precipitation > 70) {
                                  return 'La precipitación debe estar entre 0 y 50';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: TextFormField(
                              controller: _tempAmbController,
                              decoration: _getInputDecoration(
                                  'Temp Ambiente', Icons.thermostat),
                              style: getTextStyForm(),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null; // Permitir campo vacío
                                }
                                final double? tempAmb = double.tryParse(value);
                                if (tempAmb == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (tempAmb < 0 || tempAmb > 90) {
                                  return 'La temperatura ambiente debe estar entre 0 y 90';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 15),
                isSmallScreen
                    ? Column(
                        children: [
                          //Expanded(
                          DropdownButtonFormField<String>(
                            value: _selectedDirection, // Default value
                            decoration:
                                _getInputDecoration('Dir Viento', Icons.air),
                            dropdownColor: Color.fromARGB(255, 3, 50, 112),
                            items: ['N', 'S', 'E', 'O', 'NO', 'NE', 'SO', 'SE']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: getTextStyForm(),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedDirection = newValue!;
                                _dirVientoController.text = newValue;
                              });
                            },
                            style: getTextStyForm(),
                          ),

                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _velVientoController,
                            decoration:
                                _getInputDecoration('Vel Viento', Icons.speed)
                                    .copyWith(
                              errorStyle: TextStyle(
                                color: Color.fromARGB(255, 255, 193,
                                    79), // Cambia este color al que desees para el texto de error
                              ),
                            ),
                            style: getTextStyForm(),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // Permitir campo vacío
                                return null;
                              }

                              final double? dirviento = double.tryParse(value);
                              if (dirviento == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (dirviento < 0 || dirviento > 20) {
                                return 'La velocidad del viento debe estar entre 0 y 20';
                              }
                              return null;
                            },
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedDirection, // Default value
                              decoration:
                                  _getInputDecoration('Dir Viento', Icons.air),
                              dropdownColor: Color.fromARGB(255, 3, 50, 112),
                              items: [
                                'N',
                                'S',
                                'E',
                                'O',
                                'NO',
                                'NE',
                                'SO',
                                'SE'
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: getTextStyForm(),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedDirection = newValue!;
                                  _dirVientoController.text = newValue;
                                });
                              },
                              style: getTextStyForm(),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: TextFormField(
                              controller: _velVientoController,
                              decoration:
                                  _getInputDecoration('Vel Viento', Icons.speed)
                                      .copyWith(
                                errorStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 193,
                                      79), // Cambia este color al que desees para el texto de error
                                ),
                              ),
                              style: getTextStyForm(),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  // Permitir campo vacío
                                  return null;
                                }
                                final double? dirviento =
                                    double.tryParse(value);
                                if (dirviento == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (dirviento < 0 || dirviento > 20) {
                                  return 'La velocidad del viento debe estar entre 0 y 20';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 15),
                isSmallScreen
                    ? Column(
                        children: [
                          //Expanded(
                          TextFormField(
                              controller: _taevapController,
                              decoration: _getInputDecoration(
                                      'Evaporación', Icons.speed)
                                  .copyWith(
                                errorStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 193,
                                      79), // Cambia este color al que desees para el texto de error
                                ),
                              ),
                              style: getTextStyForm(),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  // Permitir campo vacío
                                  return null;
                                }
                                final double? evaporacion =
                                    double.tryParse(value);
                                if (evaporacion == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (evaporacion < 0 || evaporacion > 80) {
                                  return 'La evaporacion debe estar entre 0 y 80';
                                }
                                return null;
                              }),
                          const SizedBox(height: 15),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                                controller: _taevapController,
                                decoration: _getInputDecoration(
                                        'Evaporación', Icons.speed)
                                    .copyWith(
                                  errorStyle: TextStyle(
                                    color: Color.fromARGB(255, 255, 193,
                                        79), // Cambia este color al que desees para el texto de error
                                  ),
                                ),
                                style: getTextStyForm(),
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    // Permitir campo vacío
                                    return null;
                                  }

                                  final double? evaporacion =
                                      double.tryParse(value);
                                  if (evaporacion == null) {
                                    return 'Por favor ingresa un número válido';
                                  }
                                  if (evaporacion < 0 || evaporacion > 80) {
                                    return 'La evaporacion debe estar entre 0 y 80';
                                  }
                                  return null;
                                }),
                          ),
                          //const SizedBox(width: 15),
                        ],
                      ),
                SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 240,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF17A589),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: guardarDato,
                      icon: Icon(Icons.save_as_outlined, color: Colors.white),
                      label: Text(
                        'Guardar',
                        style: getTextStyleNormal20(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        //color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10.0),
                        //border: Border.all(color: Colors.white),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: Color.fromARGB(255, 3, 50, 112),
                        value: mesSeleccionado,
                        hint: Text(
                          'Registros anteriores - Seleccione un mes',
                          style: GoogleFonts.lexend(
                            textStyle: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            mesSeleccionado = newValue;
                            filtrarDatosPorMes(newValue);
                          });
                        },
                        items:
                            meses.map<DropdownMenuItem<String>>((String mes) {
                          return DropdownMenuItem<String>(
                            value: mes,
                            child: Text(
                              mes,
                              style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        //dropdownColor: Colors.grey[800],
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        iconEnabledColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final void Function(String?)? onSaved;

  const MyTextField({
    Key? key,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Color.fromARGB(255, 225, 255, 246), // Color de fondo
        hintText: hintText, // Texto de sugerencia
        hintStyle: const TextStyle(
            color: Color.fromARGB(
                255, 180, 255, 231)), // Estilo del texto de sugerencia
        labelText: labelText, // Etiqueta del campo
        labelStyle:
            const TextStyle(color: Colors.blue), // Estilo de la etiqueta
        prefixIcon: Icon(prefixIcon,
            color:
                Color.fromARGB(255, 97, 173, 255)), // Icono al inicio del campo
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // Sin bordes visibles
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Colors.blue, width: 2), // Bordes azules
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Colors.blue, width: 2), // Bordes azules
        ),
      ),
      onSaved: onSaved,
    );
  }
}
