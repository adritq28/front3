import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/textos.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AnadirUsuarioScreen extends StatefulWidget {
  final int? idUsuario;

  const AnadirUsuarioScreen({
    required this.idUsuario,
  });

  @override
  _AnadirUsuarioScreenState createState() => _AnadirUsuarioScreenState();
}

class _AnadirUsuarioScreenState extends State<AnadirUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController imagenController = TextEditingController();
  final TextEditingController nombreUsuarioController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apePatController = TextEditingController();
  final TextEditingController apeMatController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController ciController = TextEditingController();
  final TextEditingController adminController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController rolController = TextEditingController();

  final TextEditingController municipioController = TextEditingController();
  final TextEditingController estacionController = TextEditingController();
  final TextEditingController tipoEstacionController = TextEditingController();
  final TextEditingController zonaController = TextEditingController();
  final TextEditingController nombreCultivoController = TextEditingController();

  final TextEditingController nombreNuevoMunicipioController =
      TextEditingController();

  List<TextEditingController> municipioControllers = [];
  List<TextEditingController> estacionControllers = [];
  List<TextEditingController> tipoEstacionControllers = [];
  List<TextEditingController> zonaControllers = [];
  List<TextEditingController> nombreCultivoControllers = [];
  //TextEditingController estadoController = TextEditingController();

  bool isAdmin = false;
  bool isEstado = false;
  bool delete = false;
  bool edit = false;
  bool estado = true;
  String url = Url().apiUrl;
  File? _image; // Declarar la variable _image
  bool isLoading = true;
  List<Map<String, dynamic>> datosUsuario = [];
  String? imagenUsuario;
  List<Map<String, dynamic>> estaciones = [];
  List<String> tiposEstacion = ['Meteorológica', 'Hidrológica'];
  String? municipioSeleccionado;
  //String? estacionSeleccionada;
  String? tipoEstacionSeleccionada;
  int? idEstacionSeleccionada;
  int? idMunicipioSeleccionada;
  String? zonaSeleccionada;
  String? nombreCultivoSeleccionada;
  String? nombreZonaSeleccionada;
  int? idZonaSeleccionada;
  int? idCultivoSeleccionada;
  int? idUsuarioSeleccionada;
  String? rolSeleccionado;
  Map<String, List<Map<String, dynamic>>> estacionesPorMunicipio = {};
  Map<String, List<Map<String, dynamic>>> zonasPorMunicipio = {};
  List<Map<String, dynamic>> zonas = [];
  //Map<String, dynamic>? estacionSeleccionada;
  String? estacionSeleccionada;

  List<Map<String, dynamic>> municipios = [];
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  //File? _image; // Para almacenar la imagen seleccionada en móviles
  Uint8List? imageBytes; // Para almacenar los bytes de la imagen en web
  String? imageName;

  bool mostrarFormularioNuevoMunicipio = false;
  bool mostrarFormularioNuevaEstacion = false;

  bool mostrarFormularioNuevoMunicipioZ = false;
  bool mostrarFormularioNuevaZona = false;

  final TextEditingController nombreNuevaEstacion = TextEditingController();
  final TextEditingController latitud = TextEditingController();
  final TextEditingController longitud = TextEditingController();
  final TextEditingController altura = TextEditingController();
  String? tipoEstacion;
  final TextEditingController nombreNuevaZona = TextEditingController();
  bool isButtonDisabledUsuario = false;
  bool isButtonDisabledMunicipio = false;
  bool isButtonDisabledEstacion = false;
  bool isButtonDisabledObservador = false;
  bool isButtonDisabledPromotor = false;
  bool isButtonDisabledZona = false;

  //File? imagen;

  @override
  void initState() {
    super.initState();
    // tempMaxController.text = widget.tempMax.toString();
    // tempMinController.text = widget.tempMin.toString();
    // pcpnController.text = widget.pcpn.toString();
    // fechaController.text = widget.fecha;
    fetchMunicipio();
    fetchEstaciones();
    fetchZonas();
    // fetchMunicipio();
  }

  @override
  void dispose() {
    imagenController.dispose();
    nombreController.dispose();
    apePatController.dispose();
    apeMatController.dispose();
    ciController.dispose();
    telefonoController.dispose();
    rolController.dispose(); // Inicializar el Switch con el valor de admin
    //_image = File('images/${widget.imagen}');
    //fetchDatosUsuario(); // Esta línea puede causar problemas si la ruta es incorrecta
    //fetchEstaciones();
    //fetchMunicipio();
    //municipioSeleccionado = municipioController.text;
    super.dispose();
  }

  void _guardarCambiosPromotor() async {
    if (idMunicipioSeleccionada != null) {
      try {
        // Preparar los datos a enviar, incluyendo idMunicipioSeleccionada
        // Map<String, dynamic> datos = {
        //   'idUsuario': idUsuarioSeleccionada,
        //   'idMunicipio': idMunicipioSeleccionada,
        //   //'zona': zonaController.text,
        // };
        print('1 pppp' + idMunicipioSeleccionada.toString());
        // Realiza la petición para guardar los cambios (ejemplo)
        // final response = await http.post(
        //   Uri.parse(url + '/ruta_de_guardado'),
        //   headers: {"Content-Type": "application/json"},
        //   body: json.encode(datos),
        // );
        final newDato = {
          'idUsuario': idUsuarioSeleccionada,
          'idMunicipio': idMunicipioSeleccionada,
        };
        final response = await http.post(
          Uri.parse(url + '/promotor/addPromotor'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(newDato),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dato añadido correctamente')),
          );
          //Navigator.pop(context, true);
        } else {
          final errorMessage = response.body;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al añadir dato: $errorMessage')),
          );
        }
      } catch (e) {
        // Manejar excepción
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar los datos')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debe seleccionar un municipio válido')),
      );
    }
  }

  void guardarDatosSeleccionados(String municipio, dynamic idEstacion) async {
    if (idEstacion == null) {
      print('Error: idEstacion es null');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: idEstacion no seleccionado')),
      );

      return; // Detener si idEstacion es null
    }
    print('tipoEstacionSeleccionada: $tipoEstacionSeleccionada');
    print('municipioSeleccionado: $municipioSeleccionado');
    //print('estacionSeleccionada: ${estacionesPorMunicipio[municipioSeleccionado]?.firstWhere((estacion) => estacion['nombre'] == estacionSeleccionada)['idEstacion']}');

    // Continúa con el proceso de guardado si todo es válido
    print('Guardando selección con idEstacion: $idEstacion');
    print('Guardando selección con idUsuario: $idUsuarioSeleccionada');

    // Lógica para guardar la selección aquí
    if (_formKey.currentState!.validate()) {
      final newDato = {
        'idUsuario': idUsuarioSeleccionada,
        'idEstacion': idEstacionSeleccionada
      };

      final response = await http.post(
        Uri.parse(url + '/observador/addObservador'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newDato),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dato añadido correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        final errorMessage = response.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir dato: $errorMessage')),
        );
      }
    }
  }

  Future<void> guardarDato() async {
    if (_formKey.currentState!.validate()) {
      try {
        DateTime fechaActual = DateTime.now();

        final newDato = {
          'nombreUsuario': nombreUsuarioController.text.isEmpty
              ? ''
              : nombreUsuarioController.text,
          'nombre':
              nombreController.text.isEmpty ? null : nombreController.text,
          'apePat':
              apePatController.text.isEmpty ? null : apePatController.text,
          'apeMat':
              apeMatController.text.isEmpty ? null : apeMatController.text,
          'telefono':
              telefonoController.text.isEmpty ? null : telefonoController.text,
          'ci': ciController.text.isEmpty ? null : ciController.text,
          'password': ciController.text.isEmpty ? null : ciController.text,
          'fechaCreacion': fechaActual.toIso8601String(),
          'ultimoAcceso': fechaActual.toIso8601String(),
          'estado': isEstado,
          'rol': rolSeleccionado,
          'delete': delete,
          'edit': edit,
          'imagen': imageName
        };

        print('Datos a enviar: ${jsonEncode(newDato)}');

        var request = http.MultipartRequest(
          'POST',
          Uri.parse(url + '/usuario/addUsuario'),
        );

        // Añadir los datos al request
        request.fields.addAll(
            newDato.map((key, value) => MapEntry(key, value.toString())));

        // Añadir la imagen si se seleccionó
        if (_image != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'imagen', // Este es el nombre que el backend debe recibir
            _image!.path,
          ));
        } else if (imageBytes != null) {
          // En caso de que sea web y tengas bytes de imagen
          request.files.add(http.MultipartFile.fromBytes(
            'imagen',
            imageBytes!,
            filename: imageName, // Usa el nombre de la imagen
          ));
        }

        var response = await request.send();

        if (response.statusCode == 201) {
          // Convertir el response a una cadena
          final responseData = await response.stream.bytesToString();

          // Intentar decodificar como JSON
          try {
            final decodedResponse = json.decode(responseData);
            final idUsuario = decodedResponse['idUsuario'];

            setState(() {
              idUsuarioSeleccionada = idUsuario;
            });

            print('ID del usuario creado: $idUsuario');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Usuario añadido correctamente. ID: $idUsuario')),
            );
          } catch (e) {
            // Si no es JSON, mostrar el texto directamente
            print('Respuesta no es JSON: $responseData');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData)),
            );
          }
        } else {
          // En caso de error, mostrar mensaje con el cuerpo de la respuesta
          final errorResponse = await response.stream.bytesToString();
          print('Error: ${response.statusCode}');
          print('Response body: $errorResponse');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al añadir usuario: $errorResponse')),
          );
        }
      } catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un error al añadir el usuario')),
        );
      }
      nombreUsuarioController.clear();
      nombreController.clear();
      apePatController.clear();
      apeMatController.clear();
      ciController.clear();
      rolController.clear();
      telefonoController.clear();
    }
  }

  Future<void> fetchMunicipio() async {
    try {
      final response =
          await http.get(Uri.parse(url + '/municipio/lista_municipio'));
      if (response.statusCode == 200) {
        setState(() {
          // Store both 'idEstacion' and 'nombreMunicipio' in a map
          municipios = List<Map<String, dynamic>>.from(
              json.decode(response.body).map((municipio) => {
                    'idMunicipio': municipio['idMunicipio'],
                    'nombreMunicipio': municipio['nombreMunicipio']
                  }));
        });
      } else {
        throw Exception('Failed to load municipios');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los municipios')),
      );
    }
  }

  Future<void> fetchZonas() async {
    try {
      final response = await http.get(Uri.parse(url + '/zona/lista_zonas'));
      if (response.statusCode == 200) {
        setState(() {
          zonas = List<Map<String, dynamic>>.from(json.decode(response.body));
          zonasPorMunicipio = agruparZonasPorMunicipio(zonas);
        });
      } else {
        throw Exception('Failed to load estaciones');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las estaciones')),
      );
    }
  }

  Map<String, List<Map<String, dynamic>>> agruparZonasPorMunicipio(
      List<Map<String, dynamic>> zonas) {
    Map<String, List<Map<String, dynamic>>> agrupadas = {};

    for (var zona in zonas) {
      String nombreMunicipio = zona['nombreMunicipio'];
      int idMunicipio =
          zona['idMunicipio']; // Obtener el idMunicipio de cada estación

      // Verifica si el municipio ya tiene una lista de estaciones
      if (!agrupadas.containsKey(nombreMunicipio)) {
        agrupadas[nombreMunicipio] = [];
      }

      // Agrega la estación con su idMunicipio a la lista de su municipio correspondiente
      agrupadas[nombreMunicipio]!.add({
        'nombreZona': zona['nombreZona'],
        'idZona': zona['idZona'],
        'idMunicipio': zona['idMunicipio'], // Incluye el idMunicipio
        'nombreMunicipio': nombreMunicipio,
      });
    }

    return agrupadas;
  }

  Future<void> fetchEstaciones() async {
    try {
      final response =
          await http.get(Uri.parse(url + '/estacion/lista_estaciones'));
      if (response.statusCode == 200) {
        setState(() {
          estaciones =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          estacionesPorMunicipio = agruparEstacionesPorMunicipio(estaciones);
        });
      } else {
        throw Exception('Failed to load estaciones');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las estaciones')),
      );
    }
  }

  Map<String, List<Map<String, dynamic>>> agruparEstacionesPorMunicipio(
      List<Map<String, dynamic>> estaciones) {
    Map<String, List<Map<String, dynamic>>> agrupadas = {};

    for (var estacion in estaciones) {
      String nombreMunicipio = estacion['nombreMunicipio'];
      int idMunicipio =
          estacion['idMunicipio']; // Obtener el idMunicipio de cada estación

      // Verifica si el municipio ya tiene una lista de estaciones
      if (!agrupadas.containsKey(nombreMunicipio)) {
        agrupadas[nombreMunicipio] = [];
      }

      // Agrega la estación con su idMunicipio a la lista de su municipio correspondiente
      agrupadas[nombreMunicipio]!.add({
        'nombreEstacion': estacion['nombreEstacion'],
        'tipoEstacion': estacion['tipoEstacion'],
        'idEstacion': estacion['idEstacion'],
        'idMunicipio': idMunicipio, // Incluye el idMunicipio
        'nombreMunicipio': nombreMunicipio,
      });
    }

    return agrupadas;
  }

  Widget _buildAdminSwitch() {
    return TextField(
      decoration: InputDecoration(
        labelText: '¿Es Admin?',
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
        prefixIcon: Icon(Icons.admin_panel_settings, color: Colors.white),
        suffixIcon: Switch(
          value: isAdmin,
          onChanged: (value) {
            setState(() {
              isAdmin = value; // Cambia el valor del switch de admin
            });
          },
        ),
      ),
      style: TextStyle(
        fontSize: 17.0,
        color: Color.fromARGB(255, 201, 219, 255),
      ),
      readOnly: true,
    );
  }

  Widget _buildEstadoSwitch() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Estado',
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
        prefixIcon: Icon(Icons.toggle_on, color: Colors.white),
        suffixIcon: Switch(
          value: isEstado,
          onChanged: (value) {
            setState(() {
              isEstado = value; // Cambia el valor del switch de estado
            });
          },
        ),
      ),
      style: TextStyle(
        fontSize: 17.0,
        color: Color.fromARGB(255, 201, 219, 255),
      ),
      readOnly: true,
    );
  }

  Widget _buildDropdownTiposEstacion() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: Color.fromARGB(255, 3, 50, 112),
          value: tipoEstacionSeleccionada,
          hint: Text(
            'Seleccione tipo de estación',
            style: GoogleFonts.lexend(
              textStyle: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 15.0,
              ),
            ),
          ),
          onChanged: (String? newValue) {
            setState(() {
              tipoEstacionSeleccionada = newValue;
              municipioSeleccionado = null;
              estacionSeleccionada = null;
            });
          },
          items: tiposEstacion.map<DropdownMenuItem<String>>((String tipo) {
            return DropdownMenuItem<String>(
              value: tipo,
              child: Text(
                tipo,
                style: GoogleFonts.lexend(
                  textStyle: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15.0,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Construir dropdown para municipios
  Widget _buildDropdownEstaciones() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: Color.fromARGB(255, 3, 50, 112),
          value: estacionSeleccionada != null &&
                  estacionesPorMunicipio[municipioSeleccionado]?.any(
                          (estacion) =>
                              estacion['nombreEstacion'] ==
                              estacionSeleccionada) ==
                      true
              ? estacionSeleccionada
              : null, // Acepta nulo si no está en la lista
          hint: Text(
            'Seleccione una estación',
            style: GoogleFonts.lexend(
              textStyle: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 15.0,
              ),
            ),
          ),
          onChanged: (String? newValue) {
            setState(() {
              estacionSeleccionada = newValue;
              mostrarFormularioNuevaEstacion = (newValue == 'Otro');

              // Si hay una estación seleccionada y está en estacionesPorMunicipio
              if (newValue != null &&
                  estacionesPorMunicipio[municipioSeleccionado]!.any(
                      (estacion) => estacion['nombreEstacion'] == newValue)) {
                // Buscar la estación seleccionada para obtener el idEstacion
                var estacionSeleccionadaData =
                    estacionesPorMunicipio[municipioSeleccionado]!.firstWhere(
                        (estacion) => estacion['nombreEstacion'] == newValue);

                // Asignar el idEstacion de la estación seleccionada
                idEstacionSeleccionada = estacionSeleccionadaData['idEstacion'];
                print('idEstacionSeleccionada: $idEstacionSeleccionada');
              }
            });
          },
          items: [
            // Agregar la opción "Otro" solo si no está ya en las estaciones
            if (estacionesPorMunicipio[municipioSeleccionado] != null &&
                !estacionesPorMunicipio[municipioSeleccionado]!
                    .any((estacion) => estacion['nombreEstacion'] == 'Otro'))
              DropdownMenuItem<String>(
                value: 'Otro',
                child: Text(
                  'Otro',
                  style: GoogleFonts.lexend(
                    textStyle: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            // Agregar las estaciones correspondientes al municipio seleccionado
            ...?estacionesPorMunicipio[municipioSeleccionado]
                ?.map<DropdownMenuItem<String>>((mapaEstacion) {
              // Concatenar nombre y tipo de estación para mostrar
              String estacion2 =
                  '${mapaEstacion['nombreEstacion']} - ${mapaEstacion['tipoEstacion']}';
              String nombreEstacion =
                  mapaEstacion['nombreEstacion'] ?? 'Estación no disponible';

              return DropdownMenuItem<String>(
                value:
                    nombreEstacion, // Aquí solo usamos el nombre para la selección
                child: Text(
                  estacion2, // Mostramos nombre + tipo en el menú desplegable
                  style: GoogleFonts.lexend(
                    textStyle: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

// Estilo del InputDecoration

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  Future<void> _selectImage() async {
  print('Botón presionado');

  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null) {
    if (kIsWeb) {
      print('Imagen seleccionada (Web): ${result.files.single.name}');
      setState(() {
        imageBytes = result.files.single.bytes; // Bytes de la imagen
        imageName = result.files.single.name;  // Nombre de la imagen
      });
    } else {
      print('Imagen seleccionada (Móvil): ${result.files.single.path}');
      setState(() {
        _image = File(result.files.single.path!); // Archivo de la imagen
        imageName = result.files.single.name;     // Nombre del archivo
      });
    }
  } else {
    print('No se seleccionó ninguna imagen');
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

  // Future<void> _guardarCambios() async {
  //   final url2 = Uri.parse(url + '/usuario/editar');
  //   final headers = {'Content-Type': 'application/json'};

  //   // Crear un mapa de datos a enviar, manejando los campos vacíos
  //   final data = {
  //     //'idUsuario': widget.idUsuario,
  //     'imagen': imagenController.text.isNotEmpty ? imagenController.text : null,
  //     'nombre': nombreController.text.isEmpty ? null : nombreController.text,
  //     'apePat': apePatController.text.isEmpty ? null : apePatController.text,
  //     'apeMat': apeMatController.text,
  //     'ci': ciController.text.isEmpty ? null : ciController.text,
  //     'admin': isAdmin,
  //     'telefono': telefonoController.text,
  //     'estado': isEstado,
  //   };

  //   final body = jsonEncode(data);

  //   final response = await http.post(url2, headers: headers, body: body);

  //   if (response.statusCode == 200) {
  //     print('Datos actualizados correctamente');
  //     Navigator.pop(context, true); // Indica que se guardaron cambios
  //   } else {
  //     print('Error al actualizar los datos');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:
          CustomDrawer(idUsuario: 0, estado: PerfilEstado.soloNombreTelefono),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomNavBar(
            isHomeScreen: false,
            idUsuario: 0,
            estado: PerfilEstado.soloNombreTelefono),
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    height: 70,
                    color: Color.fromARGB(91, 4, 18, 43),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
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
                              Text('| Admin | Seccion Añadir',
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
                  Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    if (imageBytes != null || _image != null) ...[
      // Mostrar la imagen seleccionada
      ClipOval(
        child: kIsWeb
            ? Image.memory(
                imageBytes!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
            : Image.file(
                _image!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
      ),
      const SizedBox(height: 10),
      Text(
        'Imagen seleccionada: ${imageName ?? 'Sin nombre'}',
        style: const TextStyle(color: Colors.green, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    ] else ...[
      const SizedBox(height: 10), // Espacio entre la imagen y el botón
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _selectImage, // Acción cuando se presiona
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8), // Bordes redondeados
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26, // Sombra
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min, // Ajustar el tamaño al contenido
              children: [
                Icon(Icons.image, color: Colors.white), // Icono de imagen
                SizedBox(width: 8), // Espacio entre el icono y el texto
                Text(
                  'Seleccionar Imagen',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      )
    ],
  ],
)
,

                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          // Si el ancho de la pantalla es mayor a 600px (pantallas grandes)
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: nombreController,
                                      decoration: _getInputDecoration(
                                          'Nombre', Icons.person),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, ingresa tu nombre'; // Mensaje de error
                                        }
                                        if (value.length < 3) {
                                          return 'El nombre debe tener al menos 3 caracteres';
                                        }
                                        return null; // Devuelve null si es válido
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: apePatController,
                                      decoration: _getInputDecoration(
                                          'Apellido Paterno', Icons.person),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, ingresa tu apellido paterno'; // Mensaje de error
                                        }
                                        if (value.length < 3) {
                                          return 'El nombre debe tener al menos 3 caracteres';
                                        }
                                        return null; // Devuelve null si es válido
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: apeMatController,
                                      decoration: _getInputDecoration(
                                          'Apellido Materno', Icons.person),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Por favor, ingresa tu apellido materno'; // Mensaje de error
                                        }
                                        if (value.length < 3) {
                                          return 'El nombre debe tener al menos 3 caracteres';
                                        }
                                        return null; // Devuelve null si es válido
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: ciController,
                                      decoration: _getInputDecoration(
                                          'CI', Icons.card_membership),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
  if (value == null || value.isEmpty) {
    return 'El CI no puede estar vacío'; // Validar que no esté vacío
  }
  if (value.length < 5) {
    return 'El CI debe tener al menos 5 caracteres'; // Validar longitud mínima de 5 caracteres
  }
  if (!RegExp(
          r'^[A-Za-z0-9]+$') // Expresión regular que permite letras y números
      .hasMatch(value)) {
    return 'El CI debe contener solo letras y números'; // Validar que solo contenga letras y números
  }
  return null; // Si todo está bien, devuelve null
}
,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: telefonoController,
                                      decoration: _getInputDecoration(
                                          'Teléfono', Icons.phone),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'El teléfono no puede estar vacío'; // Validar que no esté vacío
                                        }
                                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                                          return 'El teléfono solo debe contener números'; // Validar que solo tenga dígitos
                                        }
                                        if (value.length < 8 ||
                                            value.length > 15) {
                                          return 'El teléfono debe tener entre 8 y 15 dígitos'; // Validar longitud
                                        }
                                        return null; // Si todo está bien, retorna null
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _buildAdminSwitch(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    // constraints: BoxConstraints(
                                    //   maxHeight: 500.0, // O algún tamaño razonable para restringir la altura
                                    // ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // Asegura que la columna ocupe el espacio mínimo necesario
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        DropdownButtonFormField<String>(
                                          value: rolSeleccionado,
                                          decoration: _getInputDecoration(
                                            'Rol',
                                            Icons.person_outline,
                                          ),
                                          style: TextStyle(
                                            fontSize: 17.0,
                                            color: Color.fromARGB(
                                                255, 201, 219, 255),
                                          ),
                                          items: [
                                            DropdownMenuItem(
                                              value: '1',
                                              child: Text('Administrador'),
                                            ),
                                            DropdownMenuItem(
                                              value: '2',
                                              child: Text('Observador'),
                                            ),
                                            DropdownMenuItem(
                                              value: '3',
                                              child: Text('Promotor'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              rolSeleccionado = value;
                                            });
                                          },
                                          dropdownColor:
                                              Color.fromARGB(255, 35, 47, 62),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Por favor, selecciona un rol';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _buildEstadoSwitch(),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              TextFormField(
                                controller: nombreController,
                                decoration:
                                    _getInputDecoration('Nombre', Icons.person),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingresa tu nombre'; // Mensaje de error
                                  }
                                  if (value.length < 3) {
                                    return 'El nombre debe tener al menos 3 caracteres';
                                  }
                                  return null; // Devuelve null si es válido
                                },
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: apePatController,
                                decoration: _getInputDecoration(
                                    'Apellido Paterno', Icons.person),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingresa tu apellido paterno'; // Mensaje de error
                                  }
                                  if (value.length < 3) {
                                    return 'El nombre debe tener al menos 3 caracteres';
                                  }
                                  return null; // Devuelve null si es válido
                                },
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: apeMatController,
                                decoration: _getInputDecoration(
                                    'Apellido Materno', Icons.person),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, ingresa tu apellido materno'; // Mensaje de error
                                  }
                                  if (value.length < 3) {
                                    return 'El nombre debe tener al menos 3 caracteres';
                                  }
                                  return null; // Devuelve null si es válido
                                },
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: ciController,
                                decoration: _getInputDecoration(
                                    'CI', Icons.card_membership),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
  if (value == null || value.isEmpty) {
    return 'El CI no puede estar vacío'; // Validar que no esté vacío
  }
  if (value.length < 5) {
    return 'El CI debe tener al menos 5 caracteres'; // Validar longitud mínima de 5 caracteres
  }
  if (!RegExp(
          r'^[A-Za-z0-9]+$') // Expresión regular que permite letras y números
      .hasMatch(value)) {
    return 'El CI debe contener solo letras y números'; // Validar que solo contenga letras y números
  }
  return null; // Si todo está bien, devuelve null
}

                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: telefonoController,
                                decoration: _getInputDecoration(
                                    'Teléfono', Icons.phone),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El teléfono no puede estar vacío'; // Validar que no esté vacío
                                  }
                                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                                    return 'El teléfono solo debe contener números'; // Validar que solo tenga dígitos
                                  }
                                  if (value.length < 8 || value.length > 15) {
                                    return 'El teléfono debe tener entre 8 y 15 dígitos'; // Validar longitud
                                  }
                                  return null; // Si todo está bien, retorna null
                                },
                              ),
                              SizedBox(height: 20),
                              _buildAdminSwitch(),
                              SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                value: rolSeleccionado,
                                decoration: InputDecoration(
                                  labelText: 'Rol',
                                  icon: Icon(Icons.person_outline),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: '1',
                                    child: Text('Administrador'),
                                  ),
                                  DropdownMenuItem(
                                    value: '2',
                                    child: Text('Observador'),
                                  ),
                                  DropdownMenuItem(
                                    value: '3',
                                    child: Text('Promotor'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    rolSeleccionado = value;
                                    // Cambiar el estado para mostrar campos adicionales según el rol
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, selecciona un rol';
                                  }
                                  return null;
                                },
                              ),

                              // Campos adicionales basados en el rol seleccionado

                              // Botón para enviar el formulario
                              // SizedBox(height: 20),
                              // ElevatedButton(
                              //   onPressed: () {
                              //     guardarDato(); // Llamar a la función para guardar el usuario
                              //   },
                              //   child: Text('Guardar Usuario'),
                              // ),
                              // SizedBox(height: 20),
                              // _buildEstadoSwitch(),
                            ],
                          );
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 30),
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
                        onPressed: isButtonDisabledUsuario
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    isButtonDisabledUsuario =
                                        true; // Desactivar el botón si todo es válido
                                  });
                                  guardarDato(); // Ejecutar la acción de guardar
                                } else {
                                  // Mostrar mensaje si hay campos inválidos
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Por favor, corrige los errores.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        icon: Icon(Icons.save_as_outlined, color: Colors.white),
                        label: Text(
                          'Añadir Usuario',
                          style: getTextStyleNormal20(),
                        ),
                      ),
                    ),
                  ),

                  // Text(
                  //   rolSeleccionado == '2'
                  //       ? 'EDITAR DATOS OBSERVADOR'
                  //       : 'EDITAR DATOS PROMOTOR',
                  //   style: getTextStyleNormal20(),
                  // ),

                  // const SizedBox(height: 30),
                  // Container(
                  //   height: 70,
                  //   color: Color.fromARGB(91, 4, 18, 43),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       const SizedBox(height: 10),
                  //       Flexible(
                  //         child: Wrap(
                  //           alignment: WrapAlignment.center,
                  //           spacing: 10.0,
                  //           runSpacing: 5.0,
                  //           children: [
                  //             Text(
                  //               // rolSeleccionado == null
                  //               //     ? '' // Si rolSeleccionado es null, no muestra nada
                  //               //     : rolSeleccionado == '1'
                  //               //         ? '' // Cuando el rolSeleccionado es '1', no muestra nada
                  //               //         : rolSeleccionado == '2'
                  //               //             ? 'CREAR DATOS OBSERVADOR' // Cuando el rolSeleccionado es '2'
                  //               //             : 'CREAR DATOS PROMOTOR', // Cuando el rolSeleccionado es '3'
                  //               // style: getTextStyleNormal20(),
                  //               ''
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  //const SizedBox(height: 20),
                  //if (rolSeleccionado == '1') _buildAdminFields(),
                  
                  if (rolSeleccionado == '2') _buildEstacionesList(),
                  if (rolSeleccionado == '3') _buildPromotorFields(),
                  //_buildUserInfoGrid(), // Aquí se muestra la grilla
                  const SizedBox(height: 20),
                  //_buildEstacionesList()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFile(String labelText, String valueText, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        initialValue: valueText,
        decoration: _getInputDecoration(labelText, icon),
        //readOnly: true,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildEditableField(
      String labelText, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller:
            controller, // Usar el controlador para obtener el valor editable
        decoration: _getInputDecoration(labelText, icon),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> _guardarCambiosObservador() async {
    // Captura los valores editados por el usuario utilizando el índice

    // Implementar lógica para guardar los cambios en el backend o localmente
  }

  Widget _buildEstacionesList() {
    if (rolSeleccionado == '2') {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!mostrarFormularioNuevoMunicipio) ...[
                Container(
                  height: 70,
                  color: Color.fromARGB(91, 4, 18, 43),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.0,
                          runSpacing: 5.0,
                          children: [
                            Text(
                              'CREAR DATOS OBSERVADOR',
                              style: getTextStyleNormal20(),
                            ),
                          ],
                        ),
                      ),
                      //Spacer(),
                    ],
                  ),
                ),
                SizedBox(height: 30), // Espaciado adicional
                Text(
                  'Seleccione un municipio y una estación:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 234, 240, 255),
                  ),
                ),
                SizedBox(height: 10),
                // _buildDropdownTiposEstacion(),
                // SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildDropdownMunicipios()),
                    SizedBox(width: 10),
                    Expanded(child: _buildDropdownEstaciones()),
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
                      // onPressed: (municipioSeleccionado != null &&
                      //         estacionSeleccionada != null)
                      //     ? () {
                      //         if (estacionSeleccionada != null) {
                      //           guardarDatosSeleccionados(
                      //               municipioSeleccionado!,
                      //               //estacionSeleccionada!['idEstacion'],
                      //               idEstacionSeleccionada);
                      //         }
                      //       }
                      //     : null,
                      onPressed: isButtonDisabledObservador
    ? null
    : () {
        if (municipioSeleccionado == null || idEstacionSeleccionada == null) {
          // Mostrar mensaje si hay valores nulos
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Debe seleccionar un municipio y una estación antes de continuar.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Continuar con la lógica si los valores no son nulos
          setState(() {
            isButtonDisabledObservador = true; // Desactivar el botón
          });
          guardarDatosSeleccionados(
            municipioSeleccionado!,
            idEstacionSeleccionada,
          );
        }
      },
                      icon: Icon(Icons.save_as_outlined, color: Colors.white),
                      label: Text(
                        'Añadir Observador',
                        style: getTextStyleNormal20(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
              if (mostrarFormularioNuevoMunicipio) ...[
                Column(
                  children: [
                    _buildNuevoMunicipioForm(),
                    _buildNuevaEstacionForm(),
                  ],
                ),
              ],
              if (mostrarFormularioNuevaEstacion) ...[
                Column(
                  children: [
                    _buildNuevaEstacionForm(),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Widget _buildDropdownMunicipios() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: Color.fromARGB(255, 3, 50, 112),
          value: municipioSeleccionado != null &&
                  estacionesPorMunicipio.keys.contains(municipioSeleccionado)
              ? municipioSeleccionado
              : null, // Acepta nulo si no está en la lista
          hint: Text(
            'Seleccione un municipio',
            style: GoogleFonts.lexend(
              textStyle: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 15.0,
              ),
            ),
          ),
          onChanged: (String? newValue) {
            mostrarFormularioNuevaEstacion = false;
            setState(() {
              municipioSeleccionado = newValue;
              estacionSeleccionada = null;
              mostrarFormularioNuevoMunicipio = (newValue == 'Otro');

              // Si hay un municipio seleccionado y está en estacionesPorMunicipio
              if (newValue != null &&
                  estacionesPorMunicipio.containsKey(newValue)) {
                // Obtén la lista de estaciones asociada a ese municipio
                var estacionesDelMunicipio = estacionesPorMunicipio[newValue];

                // Si la lista no está vacía, obtenemos el idMunicipio de la primera estación
                if (estacionesDelMunicipio != null &&
                    estacionesDelMunicipio.isNotEmpty) {
                  var idMunicipio = estacionesDelMunicipio[0]['idMunicipio'];
                  print(estacionesDelMunicipio[0]
                      ['idMunicipio']); // Puedes acceder al idMunicipio
                  idMunicipioSeleccionada =
                      idMunicipio; // Asignar el idMunicipio a tu variable
                }
              }
            });
          },
          items: [
            ...estacionesPorMunicipio.keys
                .map<DropdownMenuItem<String>>((String municipio) {
              return DropdownMenuItem<String>(
                value: municipio,
                child: Text(
                  municipio,
                  style: GoogleFonts.lexend(
                    textStyle: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              );
            }).toList(),
            DropdownMenuItem<String>(
              value: 'Otro',
              child: Text(
                'Otro',
                style: GoogleFonts.lexend(
                  textStyle: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
          
        ),
      ),
    );
  }

  Widget _buildNuevoMunicipioForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Container(
            height: 70,
            color: Color.fromARGB(91, 4, 18, 43),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10.0,
                    runSpacing: 5.0,
                    children: [
                      Text(
                        'CREAR NUEVO MUNICIPIO', // Cuando el rolSeleccionado es '3'
                        style: getTextStyleNormal20(),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Aquí cancelamos el formulario y volvemos a la selección original
                    setState(() {
                      mostrarFormularioNuevoMunicipio = false;
                      mostrarFormularioNuevoMunicipioZ = false;
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.white),
                  tooltip: 'Cerrar',
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: nombreNuevoMunicipioController,
            decoration: _getInputDecoration('Nombre del Municipio', Icons.abc),
            style: TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),

          // SizedBox(height: 10),
          // ElevatedButton(
          //   onPressed: () async {
          //     // Lógica para seleccionar la imagen (debes implementar `_pickImage`)
          //     // imagen = await _pickImage();
          //   },
          //   child: Text('Subir Imagen'),
          // ),
          // SizedBox(height: 10),

          const SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ClipOval(
              //   child: _buildImage(), // Método que gestiona la imagen
              // ),
              const SizedBox(height: 10), // Espacio entre la imagen y el botón
              MouseRegion(
                cursor: SystemMouseCursors
                    .click, // Cambia el cursor a la mano (puntero de click)
                child: GestureDetector(
                  onTap: _selectImage, // Acción cuando se presiona
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius:
                          BorderRadius.circular(8), // Bordes redondeados
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26, // Sombra
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize:
                          MainAxisSize.min, // Ajustar el tamaño al contenido
                      children: [
                        Icon(Icons.image,
                            color: Colors.white), // Icono de imagen
                        SizedBox(width: 8), // Espacio entre el icono y el texto
                        Text(
                          'Seleccionar Imagen',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16), // Estilo del texto
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),

          SizedBox(height: 10),
          /////
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
                onPressed: isButtonDisabledMunicipio
                    ? null
                    : () {
                        setState(() {
                          isButtonDisabledMunicipio =
                              true; // Desactivar el botón
                        });
                        _guardarNuevoMunicipio();
                      },
                icon: Icon(Icons.save_as_outlined, color: Colors.white),
                label: Text(
                  'Guardar municipio',
                  style: getTextStyleNormal20(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarNuevoMunicipio() async {
    if (_formKey.currentState!.validate()) {
      try {
        DateTime fechaActual = DateTime.now();

        final newDato = {
          'nombre': nombreNuevoMunicipioController.text,
          'delete': delete,
          'edit': edit,
          'imagen': imageName,
          'fechaCreacion': fechaActual
              .toIso8601String(), // Asegúrate de enviar el nombre de la imagen aquí
        };
        print('Datos a enviar: ${jsonEncode(newDato)}');

        var request = http.MultipartRequest(
          'POST',
          Uri.parse(url + '/municipio/addMunicipio'),
        );

        // Añadir los datos al request
        request.fields.addAll(
            newDato.map((key, value) => MapEntry(key, value.toString())));

        // Añadir la imagen si se seleccionó
        if (_image != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'imagen', // Este es el nombre que el backend debe recibir
            _image!.path,
          ));
        } else if (imageBytes != null) {
          // En caso de que sea web y tengas bytes de imagen
          request.files.add(http.MultipartFile.fromBytes(
            'imagen',
            imageBytes!,
            filename: imageName, // Usa el nombre de la imagen
          ));
        }

        var response = await request.send();

        if (response.statusCode == 201) {
          // Convertir el response a una cadena
          final responseData = await response.stream.bytesToString();

          // Intentar decodificar como JSON
          try {
            final decodedResponse = json.decode(responseData);
            final idMunicipio = decodedResponse['idMunicipio'];

            setState(() {
              idMunicipioSeleccionada = idMunicipio;
            });

            print('ID del municipio creado: $idMunicipio');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Municipio añadido correctamente. ID: $idMunicipio')),
            );
          } catch (e) {
            // Si no es JSON, mostrar el texto directamente
            print('Respuesta no es JSON: $responseData');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData)),
            );
          }
        } else {
          // En caso de error, mostrar mensaje con el cuerpo de la respuesta
          final errorResponse = await response.stream.bytesToString();
          print('Error: ${response.statusCode}');
          print('Response body: $errorResponse');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al añadir muncipio: $errorResponse')),
          );
        }
      } catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un error al añadir el municipio')),
        );
      }
      nombreNuevoMunicipioController.clear();
    }
  }

  Widget _buildNuevaEstacionForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Container(
            height: 70,
            color: Color.fromARGB(91, 4, 18, 43),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10.0,
                    runSpacing: 5.0,
                    children: [
                      Text(
                        'CREAR NUEVA ESTACION', // Cuando el rolSeleccionado es '3'
                        style: getTextStyleNormal20(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: nombreNuevaEstacion,
            decoration: _getInputDecoration('Nombre de Estacion', Icons.abc),
            style: TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: latitud,
            decoration: _getInputDecoration('Latitud', Icons.abc),
            style: TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: longitud,
            decoration: _getInputDecoration('Longitud', Icons.abc),
            style: TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: altura,
            decoration: _getInputDecoration('Altura', Icons.abc),
            style: TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          SizedBox(height: 20),
          _buildDropdownTiposEstacion(),
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
                // onPressed: () {
                //   print("Botón presionado");
                //   // Llama a la función de guardar
                //   _guardarNuevaEstacion();
                // },
                onPressed: isButtonDisabledEstacion
                    ? null
                    : () {
                        setState(() {
                          isButtonDisabledEstacion =
                              true; // Desactivar el botón
                        });
                        _guardarNuevaEstacion();
                      },
                icon: Icon(Icons.save_as_outlined, color: Colors.white),
                label: Text(
                  'Guardar Estación',
                  style: getTextStyleNormal20(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// void _guardarNuevaEstacion() {
//   // Lógica para guardar la nueva estación aquí
//   // Después de guardar la estación, mostrar el modal

//   // Ejemplo de valores de prueba
//   String municipio = 'Municipio Ejemplo'; // Obtén el municipio seleccionado
//   String estacion = nombreNuevaEstacion.text; // Obtén el nombre de la estación

//   // Mostrar el diálogo modal con el mensaje
//   _mostrarModal(municipio, estacion);
// }

  void _mostrarModal(String municipio, String estacion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 3, 50, 112),
          title: Text(
            'Estación Creada',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'El observador se añadirá al municipio $municipio y la estación $estacion.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                guardarDatosSeleccionados(nombreNuevoMunicipioController.text,
                    idEstacionSeleccionada); // Cierra el modal
                Navigator.of(context).pop();
              },
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
              },
              child: Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _guardarNuevaEstacion() async {
    if (_formKey.currentState!.validate()) {
      try {
        DateTime fechaActual = DateTime.now();

        final newDato = {
          'nombre': nombreNuevaEstacion.text,
          'latitud': latitud.text,
          'longitud': longitud.text,
          'altura': altura.text,
          'estado': estado,
          'idMunicipio': idMunicipioSeleccionada,
          'tipoEstacion': tipoEstacionSeleccionada,
          'delete': delete,
          'edit': edit,
          'fechaCreacion': fechaActual.toIso8601String(),
        };

        print('Datos a enviar: ${jsonEncode(newDato)}');

        // Realizar una solicitud POST con contenido tipo JSON
        var response = await http.post(
          Uri.parse(url + '/estacion/addEstacion'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(newDato),
        );

        if (response.statusCode == 201) {
          // Si el servidor responde correctamente
          final responseData = json.decode(response.body);
          final idEstacion = responseData['idEstacion'];

          setState(() {
            idEstacionSeleccionada = idEstacion;
          });
          _mostrarModal(
              nombreNuevoMunicipioController.text, nombreNuevaEstacion.text);
          print('ID de la estación creada: $idEstacion');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Estación añadida correctamente. ID: $idEstacion')),
          );
        } else {
          // En caso de error, mostrar el mensaje de error
          print('Error: ${response.statusCode}');
          print('Response body: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al añadir estación: ${response.body}')),
          );
        }
      } catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un error al añadir la estación')),
        );
      }
    }
    nombreNuevaEstacion.clear();
    latitud.clear();
    longitud.clear();
    altura.clear();
  }

  // Campos adicionales para Promotor (rol 3)
  Widget _buildPromotorFields() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!mostrarFormularioNuevoMunicipioZ) ...[
              Container(
                height: 70,
                color: Color.fromARGB(91, 4, 18, 43),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10.0,
                        runSpacing: 5.0,
                        children: [
                          Text(
                            'CREAR DATOS PROMOTOR',
                            style: getTextStyleNormal20(),
                          ),
                        ],
                      ),
                    ),
                    //Spacer(),
                  ],
                ),
              ),
              SizedBox(height: 30), // Espaciado adicional
              Text(
                'Seleccione un municipio:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 234, 240, 255),
                ),
              ),
              SizedBox(height: 10),
              // _buildDropdownTiposEstacion(),
              // SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildDropdownMunicipiosZ()),
                  SizedBox(width: 10),
                  Expanded(child: _buildDropdownZona()),
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
                    // onPressed: (municipioSeleccionado != null)
                    //     ? () {
                    //         _guardarCambiosPromotor();
                    //       }
                    //     : null,
                    onPressed: isButtonDisabledPromotor
    ? null
    : () {
        if (_buildDropdownMunicipiosZ() == null || zonaSeleccionada == null) {
          // Mostrar mensaje si hay valores nulos
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Debe seleccionar un municipio y una zona antes de continuar.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Continuar con la lógica si los valores no son nulos
          setState(() {
            isButtonDisabledPromotor = true; // Desactivar el botón
          });
          _guardarCambiosPromotor();
        }
      },

                    icon: Icon(Icons.save_as_outlined, color: Colors.white),
                    label: Text(
                      'Añadir Promotor',
                      style: getTextStyleNormal20(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
            if (mostrarFormularioNuevoMunicipioZ) ...[
              Column(
                children: [
                  _buildNuevoMunicipioForm(),
                  _buildNuevaZonaForm(),
                ],
              ),
            ],
            if (mostrarFormularioNuevaZona) ...[
              Column(
                children: [
                  _buildNuevaZonaForm(),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownMunicipiosZ() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: Color.fromARGB(255, 3, 50, 112),
          value: municipioSeleccionado != null &&
                  zonasPorMunicipio.keys.contains(municipioSeleccionado)
              ? municipioSeleccionado
              : null, // Acepta nulo si no está en la lista
          hint: Text(
            'Seleccione un municipio',
            style: GoogleFonts.lexend(
              textStyle: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 15.0,
              ),
            ),
          ),
          onChanged: (String? newValue) {
            mostrarFormularioNuevaZona = false;
            setState(() {
              municipioSeleccionado = newValue;
              zonaSeleccionada = null;
              mostrarFormularioNuevoMunicipioZ = (newValue == 'Otro');

              // Si hay un municipio seleccionado y está en estacionesPorMunicipio
              if (newValue != null && zonasPorMunicipio.containsKey(newValue)) {
                // Obtén la lista de estaciones asociada a ese municipio
                var zonasDelMunicipio = zonasPorMunicipio[newValue];

                // Si la lista no está vacía, obtenemos el idMunicipio de la primera estación
                if (zonasDelMunicipio != null && zonasDelMunicipio.isNotEmpty) {
                  var idMunicipio = zonasDelMunicipio[0]['idMunicipio'];
                  print(zonasDelMunicipio[0]
                      ['idMunicipio']); // Puedes acceder al idMunicipio
                  idMunicipioSeleccionada =
                      idMunicipio; // Asignar el idMunicipio a tu variable
                }
              }
            });
          },
          items: [
            ...zonasPorMunicipio.keys
                .map<DropdownMenuItem<String>>((String municipio) {
              return DropdownMenuItem<String>(
                value: municipio,
                child: Text(
                  municipio,
                  style: GoogleFonts.lexend(
                    textStyle: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              );
            }).toList(),
            DropdownMenuItem<String>(
              value: 'Otro',
              child: Text(
                'Otro',
                style: GoogleFonts.lexend(
                  textStyle: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownZona() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: Color.fromARGB(255, 3, 50, 112),
          value: zonaSeleccionada != null &&
                  zonasPorMunicipio[municipioSeleccionado]?.any(
                          (zona) => zona['nombreZona'] == zonaSeleccionada) ==
                      true
              ? zonaSeleccionada
              : null, // Acepta nulo si no está en la lista
          hint: Text(
            'Visualice una zona o añada con la opcion "Otro"',
            style: GoogleFonts.lexend(
              textStyle: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 15.0,
              ),
            ),
          ),
          onChanged: (String? newValue) {
            setState(() {
              zonaSeleccionada = newValue;
              // Solo si selecciona "Otro", permite ingresar al formulario
              mostrarFormularioNuevaZona = (newValue == 'Otro');
              if (mostrarFormularioNuevaZona) {
                // Aquí puedes abrir el formulario o hacer la navegación
                //_buildNuevaZonaForm();a
                print('Navegar al formulario de nueva zona');
              }

              if (newValue != null &&
                  zonasPorMunicipio[municipioSeleccionado]!
                      .any((zona) => zona['nombreZona'] == newValue)) {
                var zonasDelMunicipio =
                    zonasPorMunicipio[municipioSeleccionado];

                if (zonasDelMunicipio != null && zonasDelMunicipio.isNotEmpty) {
                  var idZona = zonasDelMunicipio[0]['idZona'];
                  idZonaSeleccionada = idZona;
                }
              }
            });
          },
          items: [
            if (zonasPorMunicipio[municipioSeleccionado] != null &&
                !zonasPorMunicipio[municipioSeleccionado]!
                    .any((zonas) => zonas['nombreZona'] == 'Otro'))
              DropdownMenuItem<String>(
                value: 'Otro',
                child: Text(
                  'Otro',
                  style: GoogleFonts.lexend(
                    textStyle: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ...?zonasPorMunicipio[municipioSeleccionado]
                ?.map<DropdownMenuItem<String>>((mapaEstacion) {
              String zona = mapaEstacion['nombreZona'] ?? 'Zona no disponible';
              return DropdownMenuItem<String>(
                value: zona,
                child: Text(
                  zona,
                  style: GoogleFonts.lexend(
                    textStyle: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 15.0,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNuevaZonaForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Container(
            height: 70,
            color: Color.fromARGB(91, 4, 18, 43),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10.0,
                    runSpacing: 5.0,
                    children: [
                      Text(
                        'CREAR NUEVA ZONA',
                        style: getTextStyleNormal20(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: nombreNuevaZona,
            decoration: _getInputDecoration('Nombre de Zona', Icons.abc),
            style: TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: latitud,
            decoration: _getInputDecoration('Latitud', Icons.abc),
            style: TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: longitud,
            decoration: _getInputDecoration('Longitud', Icons.abc),
            style: TextStyle(
              fontSize: 17.0,
              color: Color.fromARGB(255, 201, 219, 255),
            ),
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
                // onPressed: () {
                //   _guardarNuevaZona();
                // },

                onPressed: isButtonDisabledZona
                    ? null
                    : () {
                        setState(() {
                          isButtonDisabledZona = true; // Desactivar el botón
                        });
                        _guardarNuevaZona();
                      },
                icon: Icon(Icons.save, color: Colors.white),
                label: Text(
                  'Guardar Zona',
                  style: getTextStyleNormal20(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarNuevaZona() async {
    if (_formKey.currentState!.validate()) {
      try {
        DateTime fechaActual = DateTime.now();

        final newDato = {
          'nombre': nombreNuevaZona.text,
          'latitud': latitud.text,
          'longitud': longitud.text,
          'idMunicipio': idMunicipioSeleccionada,
          'delete': delete,
          'edit': edit,
          'fechaCreacion': fechaActual.toIso8601String(),
        };

        print('Datos a enviar: ${jsonEncode(newDato)}');

        // Realizar una solicitud POST con contenido tipo JSON
        var response = await http.post(
          Uri.parse(url + '/zona/addZona'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(newDato),
        );

        if (response.statusCode == 201) {
          // Si el servidor responde correctamente
          final responseData = json.decode(response.body);
          final idZona = responseData['idZona'];

          setState(() {
            idZonaSeleccionada = idZona;
          });
          _mostrarModalZ(
              nombreNuevoMunicipioController.text, nombreNuevaZona.text);
          print('ID de la zona creada: $idZona');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Zona añadida correctamente. ID: $idZona')),
          );
        } else {
          // En caso de error, mostrar el mensaje de error
          print('Error: ${response.statusCode}');
          print('Response body: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al añadir zona: ${response.body}')),
          );
        }
      } catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un error al añadir la zona')),
        );
      }
    }
    nombreNuevaZona.clear();
    latitud.clear();
    longitud.clear();
    altura.clear();
  }

  void _mostrarModalZ(String municipio, String zona) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 3, 50, 112),
          title: Text(
            'Zona Creada',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'El promotor se añadirá al municipio $municipio y la zona $zona.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _guardarCambiosPromotor(); // Cierra el modal
                Navigator.of(context).pop();
              },
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal
              },
              child: Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Función para enviar el formulario
  void _submitForm() {
    // Aquí envías los datos al backend
    // Puedes validar los campos o guardar el usuario
    print('Rol seleccionado: $rolSeleccionado');
    print('Nombre: ${nombreController.text}');
    //('Email: ${emailController.text}');
    print('Teléfono: ${telefonoController.text}');
    // Validar y enviar más datos si es necesario
  }
}
