import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/Administrador/FechaSiembra/DatosFechaSiembraScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/textos.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class EditarUsuarioScreen extends StatefulWidget {
  final int idUsuario;
  final String nombre;
  final String imagen;
  final String apePat;
  final String apeMat;
  final String ci;
  final bool admin;
  final String telefono;
  final String rol;
  final bool estado;
  final String password;

  const EditarUsuarioScreen(
      {required this.idUsuario,
      required this.nombre,
      required this.imagen,
      required this.apePat,
      required this.apeMat,
      required this.ci,
      required this.admin,
      required this.telefono,
      required this.rol,
      required this.estado,
      required this.password});

  @override
  _EditarUsuarioScreenState createState() => _EditarUsuarioScreenState();
}

class _EditarUsuarioScreenState extends State<EditarUsuarioScreen> {
  TextEditingController imagenController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController apePatController = TextEditingController();
  TextEditingController apeMatController = TextEditingController();
  TextEditingController ciController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  TextEditingController rolController = TextEditingController();
  TextEditingController municipioController = TextEditingController();
  TextEditingController estacionController = TextEditingController();
  TextEditingController tipoEstacionController = TextEditingController();
  TextEditingController zonaController = TextEditingController();
  TextEditingController nombreCultivoController = TextEditingController();

  List<TextEditingController> municipioControllers = [];
  List<TextEditingController> estacionControllers = [];
  List<TextEditingController> tipoEstacionControllers = [];
  List<TextEditingController> zonaControllers = [];
  List<TextEditingController> nombreCultivoControllers = [];
  //TextEditingController estadoController = TextEditingController();

  bool isAdmin = false;
  bool isEstado = false; // Variable para el Switch
  String url = Url().apiUrl;
  File? _image; // Declarar la variable _image
  bool isLoading = true;
  List<Map<String, dynamic>> datosUsuario = [];
  String? imagenUsuario;
  List<Map<String, dynamic>> estaciones = [];
  List<String> tiposEstacion = ['Meteorológica', 'Hidrológica'];
  String? municipioSeleccionado;
  String? estacionSeleccionada;
  String? tipoEstacionSeleccionada;
  int? idEstacionSeleccionada;
  int? idMunicipioSeleccionada;
  String? zonaSeleccionada;
  String? nombreCultivoSeleccionada;
  String? nombreZonaSeleccionada;
  int? idZonaSeleccionada;
  int? idCultivoSeleccionada;
  //String? rolSeleccionado;
  Map<String, List<Map<String, dynamic>>> estacionesPorMunicipio = {};

  List<Map<String, dynamic>> municipios = [];

  @override
  void initState() {
    super.initState();
    imagenController.text = widget.imagen;
    nombreController.text = widget.nombre;
    apePatController.text = widget.apePat;
    apeMatController.text = widget.apeMat;
    ciController.text = widget.ci;
    telefonoController.text = widget.telefono;
    rolController.text = widget.rol;
    isAdmin = widget.admin;
    isEstado = widget.estado;
    passwordController.text = widget.password; // Inicializar el Switch con el valor de admin
    _image = File('images/${widget.imagen}');
    fetchDatosUsuario(); // Esta línea puede causar problemas si la ruta es incorrecta
    //fetchEstaciones();
    fetchMunicipio();
    //municipioSeleccionado = municipioController.text;
  }

  Future<void> guardarDatosSeleccionados(
      String tipoEstacion, String municipio, String estacion) async {
    try {
      // String municipioEditado = municipioController.text;
      // String estacionEditada = estacionController.text;
      // String tipoEstacionEditada = tipoEstacionController.text;
      // final url2 = Uri.parse(url + '/estacion/editar_estacion');
      // final headers = {'Content-Type': 'application/json'};

      final response = await http.post(
        Uri.parse(url + '/estacion/editar_estacion'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'tipoEstacion': tipoEstacion,
          'municipio': municipio,
          'estacion': estacion,
        }),
      );

      if (response.statusCode == 200) {
        // Datos guardados correctamente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Datos guardados exitosamente')),
        );
      } else {
        throw Exception('Error al guardar los datos');
      }
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar los datos: $e')),
      );
    }
  }

  // Future<void> fetchEstaciones() async {
  //   try {
  //     final response =
  //         await http.get(Uri.parse(url + '/estacion/lista_estaciones'));
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         // Cargar las estaciones obtenidas del backend
  //         estaciones =
  //             List<Map<String, dynamic>>.from(json.decode(response.body));

  //         // Agrupar por municipio como lo hacías antes
  //         estacionesPorMunicipio = agruparEstacionesPorMunicipio(estaciones);
  //       });
  //     } else {
  //       throw Exception('Failed to load estaciones');
  //     }
  //   } catch (e) {
  //     // Manejar errores de red o de decodificación
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error al cargar las estaciones')),
  //     );
  //   }
  // }

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

  Map<String, List<Map<String, dynamic>>> agruparEstacionesPorMunicipio(
      List<Map<String, dynamic>> estaciones) {
    Map<String, List<Map<String, dynamic>>> agrupadas = {};
    for (var estacion in estaciones) {
      if (!agrupadas.containsKey(estacion['nombreMunicipio'])) {
        agrupadas[estacion['nombreMunicipio']] = [];
      }
      agrupadas[estacion['nombreMunicipio']]!.add(estacion);
    }
    return agrupadas;
  }

  // Widget _buildEstacionesList() {
  //   // Verifica si el rol es '2'
  //   if (widget.rol == '2') {
  //     return SingleChildScrollView(
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Seleccione un municipio y una estación:',
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.bold,
  //                 color: Color.fromARGB(255, 234, 240, 255),
  //               ),
  //             ),
  //             SizedBox(height: 10),

  //             // Dropdown de Tipo de Estación
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.black.withOpacity(0.3),
  //                 borderRadius: BorderRadius.circular(10.0),
  //                 border: Border.all(color: Colors.white),
  //               ),
  //               child: Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: tiposEstacion.isNotEmpty &&
  //                         tipoEstacionSeleccionada != null &&
  //                         tiposEstacion.contains(tipoEstacionSeleccionada)
  //                     ? DropdownButton<String>(
  //                         isExpanded: true,
  //                         dropdownColor: Color.fromARGB(255, 3, 50, 112),
  //                         value:
  //                             tipoEstacionSeleccionada, // Mostrar valor preseleccionado
  //                         hint: Text(
  //                           'Seleccione tipo de estación',
  //                           style: GoogleFonts.lexend(
  //                             textStyle: TextStyle(
  //                               color: Color.fromARGB(255, 255, 255, 255),
  //                               fontSize: 15.0,
  //                             ),
  //                           ),
  //                         ),
  //                         onChanged: (String? newValue) {
  //                           setState(() {
  //                             tipoEstacionSeleccionada = newValue;
  //                             municipioSeleccionado = null;
  //                             estacionSeleccionada = null;
  //                           });
  //                         },
  //                         items: tiposEstacion
  //                             .map<DropdownMenuItem<String>>((String tipo) {
  //                           return DropdownMenuItem<String>(
  //                             value: tipo,
  //                             child: Text(
  //                               tipo,
  //                               style: GoogleFonts.lexend(
  //                                 textStyle: TextStyle(
  //                                   color: Color.fromARGB(255, 255, 255, 255),
  //                                   fontSize: 15.0,
  //                                 ),
  //                               ),
  //                             ),
  //                           );
  //                         }).toList(),
  //                       )
  //                     : CircularProgressIndicator(), // Muestra un indicador de progreso mientras se cargan los datos
  //               ),
  //             ),

  //             SizedBox(height: 10),

  //             // Row para Municipios y Estaciones
  //             Row(
  //               children: [
  //                 // Dropdown de Municipios
  //                 Expanded(
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.black.withOpacity(0.3),
  //                       borderRadius: BorderRadius.circular(10.0),
  //                       border: Border.all(color: Colors.white),
  //                     ),
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: DropdownButton<String>(
  //                         isExpanded:
  //                             true, // Asegura que ocupe el espacio disponible
  //                         dropdownColor: Color.fromARGB(255, 3, 50, 112),
  //                         value: municipioSeleccionado,
  //                         hint: Text(
  //                           'Seleccione un municipio',
  //                           style: GoogleFonts.lexend(
  //                             textStyle: TextStyle(
  //                               color: Color.fromARGB(255, 255, 255, 255),
  //                               fontSize: 15.0,
  //                             ),
  //                           ),
  //                         ),
  //                         onChanged: (String? newValue) {
  //                           setState(() {
  //                             municipioSeleccionado = newValue;
  //                             estacionSeleccionada = null;
  //                           });
  //                         },
  //                         items: estacionesPorMunicipio.keys
  //                             .map<DropdownMenuItem<String>>(
  //                                 (String municipio) {
  //                           return DropdownMenuItem<String>(
  //                             value: municipio,
  //                             child: Text(
  //                               municipio,
  //                               style: GoogleFonts.lexend(
  //                                 textStyle: TextStyle(
  //                                   color: Color.fromARGB(255, 255, 255, 255),
  //                                   fontSize: 15.0,
  //                                 ),
  //                               ),
  //                             ),
  //                           );
  //                         }).toList(),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 10),

  //                 // Dropdown de Estaciones
  //                 Expanded(
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.black.withOpacity(0.3),
  //                       borderRadius: BorderRadius.circular(10.0),
  //                       border: Border.all(color: Colors.white),
  //                     ),
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: DropdownButton<String>(
  //                         isExpanded:
  //                             true, // Asegura que ocupe el espacio disponible
  //                         dropdownColor: Color.fromARGB(255, 3, 50, 112),
  //                         value: estacionSeleccionada,
  //                         hint: Text(
  //                           'Seleccione una estación',
  //                           style: GoogleFonts.lexend(
  //                             textStyle: TextStyle(
  //                               color: Color.fromARGB(255, 255, 255, 255),
  //                               fontSize: 15.0,
  //                             ),
  //                           ),
  //                         ),
  //                         onChanged: (String? newValue) {
  //                           setState(() {
  //                             estacionSeleccionada = newValue;
  //                           });
  //                         },
  //                         items: municipioSeleccionado != null
  //                             ? estacionesPorMunicipio[municipioSeleccionado]!
  //                                 .map<DropdownMenuItem<String>>(
  //                                     (Map<String, dynamic> estacion) {
  //                                 return DropdownMenuItem<String>(
  //                                   value: estacion['nombreEstacion'],
  //                                   child: Text(
  //                                     estacion['nombreEstacion'],
  //                                     style: GoogleFonts.lexend(
  //                                       textStyle: TextStyle(
  //                                         color: Color.fromARGB(
  //                                             255, 255, 255, 255),
  //                                         fontSize: 15.0,
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 );
  //                               }).toList()
  //                             : [],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             ElevatedButton(
  //               onPressed: (tipoEstacionSeleccionada != null &&
  //                       municipioSeleccionado != null &&
  //                       estacionSeleccionada != null)
  //                   ? () {
  //                       guardarDatosSeleccionados(
  //                         tipoEstacionSeleccionada!,
  //                         municipioSeleccionado!,
  //                         estacionSeleccionada!,
  //                       );
  //                     }
  //                   : null, // Desactiva el botón si no se ha seleccionado todo
  //               child: Text('Guardar Selección'),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   } else {
  //     return SizedBox(); // Si el rol no es '2', muestra un widget vacío
  //   }
  // }

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
      print('Imagen seleccionada: ${result.files.single.path}');
      setState(() {
        _image = File(result.files.single.path!);
      });
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

  Future<void> _guardarCambios() async {
    final url2 = Uri.parse(url + '/usuario/editar');
    final headers = {'Content-Type': 'application/json'};

    // Crear un mapa de datos a enviar, manejando los campos vacíos
    final data = {
      'idUsuario': widget.idUsuario,
      'imagen': imagenController.text.isNotEmpty ? imagenController.text : null,
      'nombre': nombreController.text.isEmpty ? null : nombreController.text,
      'apePat': apePatController.text.isEmpty ? null : apePatController.text,
      'apeMat': apeMatController.text,
      'ci': ciController.text.isEmpty ? null : ciController.text,
      'admin': isAdmin,
      'telefono': telefonoController.text,
      'password': passwordController.text,
      'estado': isEstado,
    };

    final body = jsonEncode(data);

    final response = await http.post(url2, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Datos actualizados correctamente');
      Navigator.pop(context, true); // Indica que se guardaron cambios
    } else {
      print('Error al actualizar los datos');
    }
  }

  Future<void> fetchDatosUsuario() async {
    try {
      final response =
          await http.get(Uri.parse(url + '/usuario/roles/${widget.idUsuario}'));
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is List) {
          setState(() {
            datosUsuario = List<Map<String, dynamic>>.from(responseBody);

            // Verificar los datos recibidos
            print("Datos del usuario recibidos: $datosUsuario");

            if (datosUsuario.isNotEmpty) {
              for (var usuario in datosUsuario) {
                // Crear un controlador nuevo para cada campo y añadirlo a la lista
                municipioControllers.add(
                    TextEditingController(text: usuario['municipio'] ?? 'N/A'));
                estacionControllers.add(
                    TextEditingController(text: usuario['estacion'] ?? 'N/A'));
                tipoEstacionControllers.add(TextEditingController(
                    text: usuario['tipoEstacion'] ?? 'N/A'));
                zonaControllers
                    .add(TextEditingController(text: usuario['zona'] ?? 'N/A'));
                nombreCultivoControllers.add(TextEditingController(
                    text: usuario['cultivoNombre'] ?? 'N/A'));

                // Asignar el valor de cada campo recibido
                municipioSeleccionado = usuario['municipio'];
                estacionSeleccionada = usuario['estacion'];
                tipoEstacionSeleccionada = usuario['tipoEstacion'];
                idEstacionSeleccionada = usuario['idEstacion'];
                idMunicipioSeleccionada = usuario['idMunicipio'];
                idZonaSeleccionada = usuario['idZona'];
                zonaSeleccionada = usuario['zona'];
                nombreCultivoSeleccionada = usuario['cultivoNombre'];
                idCultivoSeleccionada = usuario['idCultivo'];

                // Imprimir valores de depuración
                print("Municipio seleccionado: $municipioSeleccionado");
                //print("Estación seleccionada: $estacionSeleccionada");
                //print("Tipo de estación seleccionada: $tipoEstacionSeleccionada");
                //print("ID Estación: $idEstacionSeleccionada");
                print("ID Municipio: $idMunicipioSeleccionada");
                print("ID Zona: $idZonaSeleccionada");
                print("Zona: $zonaSeleccionada");
                print("Cultivo: $nombreCultivoSeleccionada");
              }

              // Simulación de valores posibles para el tipo de estación
              tiposEstacion = ['Meteorologica', 'Hidrologica'];
              //print("Tipos de estación disponibles: $tiposEstacion");
            }

            isLoading = false;
          });
        } else {
          throw Exception('El formato de la respuesta no es una lista.');
        }
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Error al obtener los datos del usuario');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error en fetchDatosUsuario: $e');
    }
  }

  @override
  void dispose() {
    // Limpiar los controladores cuando ya no sean necesarios
    municipioController?.dispose();
    estacionController?.dispose();
    tipoEstacionController?.dispose();
    zonaController?.dispose();
    nombreCultivoController?.dispose();
    super.dispose();
  }

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
                              Text('| Admin | Seccion Editar',
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
                  //const SizedBox(height: 10),
                  // Mostrar la imagen actual
                  SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: _buildImage(), // Método que gestiona la imagen
                        ),
                        const SizedBox(
                            height: 10), // Espacio entre la imagen y el botón
                        MouseRegion(
                          cursor: SystemMouseCursors
                              .click, // Cambia el cursor a la mano (puntero de click)
                          child: GestureDetector(
                            onTap: _selectImage, // Acción cuando se presiona
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(
                                    8), // Bordes redondeados
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26, // Sombra
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize
                                    .min, // Ajustar el tamaño al contenido
                                children: [
                                  Icon(Icons.image,
                                      color: Colors.white), // Icono de imagen
                                  SizedBox(
                                      width:
                                          8), // Espacio entre el icono y el texto
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
                  ),

                  SizedBox(height: 20),
                  SingleChildScrollView(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          // Si el ancho de la pantalla es mayor a 600px (pantallas grandes)
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: nombreController,
                                      decoration: _getInputDecoration(
                                          'Nombre', Icons.person),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: apePatController,
                                      decoration: _getInputDecoration(
                                          'Apellido Paterno', Icons.person),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: apeMatController,
                                      decoration: _getInputDecoration(
                                          'Apellido Materno', Icons.person),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: ciController,
                                      decoration: _getInputDecoration(
                                          'CI', Icons.card_membership),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: telefonoController,
                                      decoration: _getInputDecoration(
                                          'Teléfono', Icons.phone),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.phone,
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
                                    child: TextField(
                                      controller: rolController,
                                      decoration: _getInputDecoration(
                                          'Rol', Icons.phone),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _buildEstadoSwitch(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: passwordController,
                                      decoration: _getInputDecoration(
                                          'Password', Icons.phone),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        color:
                                            Color.fromARGB(255, 201, 219, 255),
                                      ),
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // Si el ancho de la pantalla es menor o igual a 600px (pantallas pequeñas)
                          return Column(
                            children: [
                              TextField(
                                controller: nombreController,
                                decoration:
                                    _getInputDecoration('Nombre', Icons.person),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: apePatController,
                                decoration: _getInputDecoration(
                                    'Apellido Paterno', Icons.person),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: apeMatController,
                                decoration: _getInputDecoration(
                                    'Apellido Materno', Icons.person),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: ciController,
                                decoration: _getInputDecoration(
                                    'CI', Icons.card_membership),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: telefonoController,
                                decoration: _getInputDecoration(
                                    'Teléfono', Icons.phone),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              SizedBox(height: 20),
                              _buildAdminSwitch(),
                              SizedBox(height: 20),
                              TextField(
                                controller: rolController,
                                decoration:
                                    _getInputDecoration('Rol', Icons.phone),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              SizedBox(height: 20),
                              _buildEstadoSwitch(),
                              SizedBox(height: 20),
                              TextField(
                                controller: passwordController,
                                decoration: _getInputDecoration(
                                    'Password', Icons.phone),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.text,
                              ),
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
                        onPressed: _guardarCambios,
                        icon: Icon(Icons.save_as_outlined, color: Colors.white),
                        label: Text(
                          'Guardar',
                          style: getTextStyleNormal20(),
                        ),
                      ),
                    ),
                  ),

                  // Text(
                  //   widget.rol == '2'
                  //       ? 'EDITAR DATOS OBSERVADOR'
                  //       : 'EDITAR DATOS PROMOTOR',
                  //   style: getTextStyleNormal20(),
                  // ),

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
                                widget.rol == null
                                    ? '' // Si rolSeleccionado es null, no muestra nada
                                    : widget.rol == '1'
                                        ? '' // Cuando el rolSeleccionado es '1', no muestra nada
                                        : widget.rol == '2'
                                            ? 'CREAR DATOS OBSERVADOR' // Cuando el rolSeleccionado es '2'
                                            : 'CREAR DATOS PROMOTOR', // Cuando el rolSeleccionado es '3'
                                style: getTextStyleNormal20(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //const SizedBox(height: 20),
                  _buildUserInfoGrid(), // Aquí se muestra la grilla
                  const SizedBox(height: 20),
                  // _buildEstacionesList()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildUserInfoGrid() {
  //   return Column(
  //     children: datosUsuario.map((usuario) {
  //       if (usuario['rol'] == '2') {
  //         return _buildObservadorCard(usuario);
  //       } else if (usuario['rol'] == '3') {
  //         return _buildPromotorCard(usuario);
  //       }
  //       return SizedBox(); // Devuelve un widget vacío en caso de error
  //     }).toList(),
  //   );
  // }

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

  Widget _buildObservadorCard(Map<String, dynamic> usuario, int index) {
    // Verifica que los controladores no sean nulos antes de mostrar los campos
    if (municipioControllers == null ||
        estacionControllers == null ||
        tipoEstacionControllers == null) {
      return Center(
          child: CircularProgressIndicator()); // Muestra un indicador de carga
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      // decoration: BoxDecoration(
      //   color: Colors.black.withOpacity(0.3),
      //   borderRadius: BorderRadius.circular(10.0),
      //   //border: Border.all(color: Colors.white),
      // ),
      child: Column(
        mainAxisSize: MainAxisSize
            .min, // Esto asegura que el Column no ocupe todo el espacio
        children: [
          SizedBox(height: 30),
          Container(
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
                value: municipioSeleccionado,
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
                  setState(() {
                    // Actualiza el nombre del municipio seleccionado
                    municipioSeleccionado = newValue;

                    // Encuentra y guarda el idMunicipio del municipio seleccionado
                    Map<String, dynamic> municipioSeleccionadoObj =
                        municipios.firstWhere(
                      (municipio) => municipio['nombreMunicipio'] == newValue,
                      orElse: () =>
                          {}, // Devolver un Map vacío en lugar de null
                    );

                    idMunicipioSeleccionada =
                        municipioSeleccionadoObj.isNotEmpty
                            ? municipioSeleccionadoObj['idMunicipio']
                            : null;

                    print('ddddd' + idMunicipioSeleccionada.toString());
                    if (municipioSeleccionadoObj != null) {
                      idMunicipioSeleccionada =
                          municipioSeleccionadoObj['idMunicipio'];
                    } else {
                      idMunicipioSeleccionada =
                          null; // En caso de que no se encuentre el municipio
                    }
                  });
                },
                items: municipios.isNotEmpty
                    ? municipios.map<DropdownMenuItem<String>>(
                        (Map<String, dynamic> municipio) {
                        return DropdownMenuItem<String>(
                          value: municipio['nombreMunicipio'],
                          child: Text(
                            municipio['nombreMunicipio'],
                            style: GoogleFonts.lexend(
                              textStyle: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        );
                      }).toList()
                    : [], // En caso de que la lista esté vacía
              ),
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            child: Column(
              children: [
                // _buildEditableField('Municipio', municipioControllers[index],
                //     Icons.location_city),
                _buildEditableField(
                    'Estación', estacionControllers[index], Icons.dashboard),
                _buildEditableField('Tipo Estación',
                    tipoEstacionControllers[index], Icons.settings),
                SizedBox(height: 10), // Espacio entre los campos
              ],
            ),
          ),
          SizedBox(height: 10),
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
                onPressed: () => _guardarCambiosObservador(index),
                icon: Icon(Icons.save_as_outlined, color: Colors.white),
                label: Text(
                  'Guardar',
                  style: getTextStyleNormal20(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta para el rol de promotor (zona, cultivo, municipio)
  Widget _buildPromotorCard(Map<String, dynamic> usuario, int index) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown para seleccionar el municipio
            Container(
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
                  value: municipioSeleccionado,
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
                    setState(() {
                      municipioSeleccionado = newValue;
                      Map<String, dynamic> municipioSeleccionadoObj =
                          municipios.firstWhere(
                        (municipio) => municipio['nombreMunicipio'] == newValue,
                        orElse: () =>
                            {}, // Devolver un Map vacío en lugar de null
                      );

                      idMunicipioSeleccionada =
                          municipioSeleccionadoObj.isNotEmpty
                              ? municipioSeleccionadoObj['idMunicipio']
                              : null;
                    });
                  },
                  items: municipios.isNotEmpty
                      ? municipios.map<DropdownMenuItem<String>>(
                          (Map<String, dynamic> municipio) {
                          return DropdownMenuItem<String>(
                            value: municipio['nombreMunicipio'],
                            child: Text(
                              municipio['nombreMunicipio'],
                              style: GoogleFonts.lexend(
                                textStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                          );
                        }).toList()
                      : [], // En caso de que la lista esté vacía
                ),
              ),
            ),
            SizedBox(height: 10),
            // Campos de texto editables para Zona y Cultivo específicos de este usuario
            _buildEditableField('Zona', zonaControllers[index], Icons.map),

            // Botones alineados en una fila (Row)
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Alinea botones a los extremos
              children: [
                // Botón Guardar
                Container(
                  width: 240, // Ajusta el ancho si es necesario
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF17A589),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _guardarCambiosPromotor(index),
                    icon: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.save_as_outlined, color: Colors.white),
                    ),
                    label: Text(
                      'Guardar',
                      style: getTextStyleNormal20(),
                    ),
                  ),
                ),

                Container(
                  width: 240, // Ajusta el ancho si es necesario
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Cambia el color aquí
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DatosFechaSiembraScreen(
                            idZona: idZonaSeleccionada ?? 0,
                            nombreMunicipio: municipioSeleccionado ?? '',
                            nombreZona: zonaSeleccionada ?? '',
                          ),
                        ),
                      );
                    },
                    icon: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                    label: Text(
                      'Editar Cultivo',
                      style: getTextStyleNormal20(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_image != null) {
      return Image.asset(
        'images/${widget.imagen}',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'images/1.jpg', // Imagen por defecto si no hay una imagen seleccionada
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
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

  Future<void> _guardarCambiosObservador(int index) async {
    // Captura los valores editados por el usuario utilizando el índice
    String municipioEditado = municipioControllers[index].text;
    String estacionEditada = estacionControllers[index].text;
    String tipoEstacionEditada = tipoEstacionControllers[index].text;

    print('1 Municipio: $municipioEditado');
    print('1 Estación: $estacionEditada');
    print('1 Tipo Estación: $tipoEstacionEditada');
    print('1 aaaa' + idEstacionSeleccionada.toString());
    print('1 pppp' + idMunicipioSeleccionada.toString());

    final url2 = Uri.parse(url + '/estacion/editar_estacion');
    final headers = {'Content-Type': 'application/json'};

    // Crear un mapa de datos a enviar, manejando los campos vacíos
    final data = {
      'idEstacion': idEstacionSeleccionada,
      'idMunicipio': idMunicipioSeleccionada,
      'nombre': estacionEditada.isEmpty ? null : estacionEditada,
      'tipoEstacion': tipoEstacionEditada.isEmpty ? null : tipoEstacionEditada,
    };

    final body = jsonEncode(data);
    final response = await http.post(url2, headers: headers, body: body);
    print('aaaa' + idEstacionSeleccionada.toString());
    print('pppp' + idMunicipioSeleccionada.toString());

    if (response.statusCode == 200) {
      print('Datos actualizados correctamente');
      Navigator.pop(context, true); // Indica que se guardaron cambios
    } else {
      print('Error al actualizar los datos');
    }

    // Aquí puedes enviar los datos editados al servidor o actualizarlos localmente
    print('Municipio: $municipioEditado');
    print('Estación: $estacionEditada');
    print('Tipo Estación: $tipoEstacionEditada');

    // Implementar lógica para guardar los cambios en el backend o localmente
  }

  Future<void> _guardarCambiosPromotor(int index) async {
    // Captura los valores editados por el usuario
    String municipioEditado = municipioControllers[index].text;
    String zonaEditada = zonaControllers[index].text;
    String nombreCultivoEditada = nombreCultivoControllers[index].text;
    //String tipoEstacionEditada = tipoEstacionController.text;
    print('1 ZONA: $zonaEditada');
    print('1 Nombre cultivo: $nombreCultivoEditada');
    print('1 pppp' + idMunicipioSeleccionada.toString());

    final url2 = Uri.parse(url + '/zona/editar_zona');
    final headers = {'Content-Type': 'application/json'};

    // Crear un mapa de datos a enviar, manejando los campos vacíos
    final data = {
      'idZona': idZonaSeleccionada,
      'idMunicipio': idMunicipioSeleccionada,
      //'cultivoNombre': nombreCultivoEditada.isEmpty ? null : nombreCultivoEditada,
      'nombre': zonaEditada.isEmpty ? null : zonaEditada,
    };

    final body = jsonEncode(data);
    final response = await http.post(url2, headers: headers, body: body);

    print('pppp' + idMunicipioSeleccionada.toString());

    if (response.statusCode == 200) {
      print('Datos actualizados correctamente');
      Navigator.pop(context, true); // Indica que se guardaron cambios
    } else {
      print('Error al actualizar los datos');
    }
  }

  // El widget general que muestra la información del usuario
  Widget _buildUserInfoGrid() {
    if (isLoading) {
      return Center(
        child:
            CircularProgressIndicator(), // Mostrar un indicador de carga mientras se obtienen los datos
      );
    }

    return ListView.builder(
      shrinkWrap:
          true, // Esto permitirá que la ListView se adapte a su contenido en un Column
      physics:
          NeverScrollableScrollPhysics(), // Deshabilitar el scroll en caso de estar dentro de otro scrollable widget
      itemCount: datosUsuario.length, // Cantidad de usuarios
      itemBuilder: (context, index) {
        Map<String, dynamic> usuario = datosUsuario[index];

        if (usuario['rol'] == '2') {
          return _buildObservadorCard(usuario, index); // Para rol '2'
        } else if (usuario['rol'] == '3') {
          return _buildPromotorCard(
              usuario, index); // Para rol '3' (usamos el índice)
        }

        return SizedBox(); // Devuelve un widget vacío en caso de no coincidir rol
      },
    );
  }
}
