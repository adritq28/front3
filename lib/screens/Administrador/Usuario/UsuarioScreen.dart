import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/Administrador/Usuario/AnadirUsuarioScreen.dart';
import 'package:helvetasfront/screens/Administrador/Usuario/EditarUsuarioScreen.dart';
import 'package:helvetasfront/screens/Administrador/Usuario/VisualizarUsuarioScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class UsuarioScreen extends StatefulWidget {
  final int idUsuario;
  final String nombre;
  final String apeMat;
  final String apePat;
  final String ci;
  final String imagen;

  const UsuarioScreen({
    required this.idUsuario,
    required this.nombre,
    required this.apeMat,
    required this.apePat,
    required this.ci,
    required this.imagen,
  });

  @override
  _UsuarioScreenState createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  List<Map<String, dynamic>> datos = [];
  bool isLoading = true;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  List<Map<String, dynamic>> datosFiltrados = [];
  String url = Url().apiUrl;
  String ip = Url().ip;
  //List<Map<String, dynamic>> datos = []; // Tus datos originales
  String? rolSeleccionado;
  final List<String> roles = ["ADMIN", "OBSERVADOR", "PROMOTOR", "TODOS"];

  @override
  void initState() {
    super.initState();
    fetchDatosUsuario();
  }

  void reloadData() {
    fetchDatosUsuario();
  }

  Future<void> fetchDatosUsuario() async {
    setState(() {
      isLoading =
          true; // Establece isLoading a true antes de hacer la solicitud
    });

    final response = await http.get(
      Uri.parse(url + '/usuario/lista_usuario'),
    );

    if (response.statusCode == 200) {
      // Decodifica la respuesta y la almacena en la lista 'datos'
      List<Map<String, dynamic>> fetchedData =
          List<Map<String, dynamic>>.from(json.decode(response.body));

      setState(() {
        datos = fetchedData; // Actualiza la lista de datos
        isLoading =
            false; // Cambia isLoading a false después de obtener los datos
      });
    } else {
      setState(() {
        isLoading = false; // Cambia isLoading a false si hay un error
      });
      throw Exception('Failed to load datos de usuario');
    }
  }

  void editarDato(int index) async {
    try {
      Map<String, dynamic> dato = datos[index];

      // Asegurar que 'admin' es bool o false
      bool isAdmin = dato.containsKey('admin') && dato['admin'] != null
          ? dato['admin'] as bool
          : false;

      bool cambiosGuardados = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditarUsuarioScreen(
            idUsuario: dato['idUsuario'] ??
                0, // Proporciona un valor por defecto para idUsuario
            nombre: dato['nombre'] ?? '', // Usa '' si es nulo
            imagen: dato['imagen'] ??
                'default_image.png', // Imagen por defecto si no hay imagen
            apePat: dato['apePat'] ?? '', // Usa '' si es nulo
            apeMat: dato['apeMat'] ?? '', // Usa '' si es nulo
            ci: dato['ci'] ?? '', // Usa '' si es nulo
            admin:
                dato['admin'] ?? false, // Si no hay valor de admin, usa false
            telefono: dato['telefono'] ?? '',
            rol: dato['rol'] ?? '',
            estado: dato['estado'] ?? false,
            password: dato['password'] ?? '',
          ),
        ),
      );

      if (cambiosGuardados == true) {
        fetchDatosUsuario();
      }
    } catch (e) {
      print('Error al editar dato: $e'); // Captura cualquier error
    }
  }

  void visualizarDato(int index) {
    try {
      Map<String, dynamic> dato = datos[index];

      // Permitir valores nulos, reemplazándolos con una cadena vacía si es necesario
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisualizarUsuarioScreen(
              idUsuario: dato['idUsuario'] ?? 0,
              nombre: dato['nombre'] ?? '',
              imagen: dato['imagen'] ?? 'default_image.png',
              apePat: dato['apePat'] ?? '',
              apeMat: dato['apeMat'] ?? '',
              ci: dato['ci'] ?? '',
              admin: dato['admin'] ?? false,
              telefono: dato['telefono'] ?? '',
              rol: dato['rol'] ?? ''),
        ),
      );
      print('Visualizar dato en la posición $index');
    } catch (e) {
      print('Error al intentar visualizar el dato en la posición $index: $e');
    }
  }

  void eliminarDato(int index) async {
    Map<String, dynamic> dato = datos[index];
    int idUsuario = dato['idUsuario'];

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

                final url2 = Uri.parse(url + '/usuario/eliminar/${idUsuario}');
                final headers = {'Content-Type': 'application/json'};
                final response = await http.delete(url2, headers: headers);

                if (response.statusCode == 200) {
                  setState(() {
                    datos.removeAt(index);
                    datos = datos
                        .where((dato) => dato['idUsuario'] != idUsuario)
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
  print("Valor de idUsuario: ${widget.idUsuario}");
  bool? result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AnadirUsuarioScreen(idUsuario: widget.idUsuario),
    ),
  );

  if (result == true) {
    fetchDatosUsuario();
  }
}


  String obtenerRol(String rol) {
    switch (rol) {
      case '1':
        return "ADMIN";
      case '2':
        return "OBSERVADOR";
      case '3':
        return "PROMOTOR";
      default:
        return "DESCONOCIDO"; // En caso de que no coincida con ningún valor conocido
    }
  }

  List<Map<String, dynamic>> filtrarDatosPorRol() {
    if (rolSeleccionado == null || rolSeleccionado == "TODOS") {
      return datos; // Devuelve todos los datos si no hay filtro
    } else {
      return datos
          .where((dato) => obtenerRol(dato['rol']) == rolSeleccionado)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: 0,
        estado: PerfilEstado.soloNombreTelefono,
      ), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(
          isHomeScreen: false,
          idUsuario: 0,
          estado: PerfilEstado.soloNombreTelefono,
        ), // Indicamos que es la pantalla principal
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
                  Container(
                    height: 70,
                    color: Color.fromARGB(91, 4, 18, 43),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage("images/${widget.imagen}"),
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
                                  ))),
                              Text(
                                  '| ${widget.nombre} ${widget.apePat} ${widget.apeMat}',
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
                  Container(
                    // decoration: BoxDecoration(
                    //   color: Colors.black.withOpacity(0.3),
                    //   borderRadius: BorderRadius.circular(10.0),
                    //   border: Border.all(color: Colors.white),
                    // ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        dropdownColor: Color.fromARGB(255, 3, 50, 112),
                        hint: Text(
                          'Selecciona un rol',
                          style: GoogleFonts.lexend(
                            textStyle: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                        value: rolSeleccionado,
                        items: roles.map((String rol) {
                          return DropdownMenuItem<String>(
                            value: rol,
                            child: Text(rol, style: GoogleFonts.lexend(
                  textStyle: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15.0,
                  ),
                ),),
                          );
                        }).toList(),
                        onChanged: (String? nuevoRol) {
                          setState(() {
                            rolSeleccionado = nuevoRol;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 200, // Define el ancho deseado del botón
                        child: TextButton.icon(
                          onPressed: anadirDato,
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text(
                            'Añadir',
                            style: GoogleFonts.lexend(
                              textStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 142, 146, 143),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Expanded(
                          child: SingleChildScrollView(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                dataRowHeight: 60,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Id Usuario',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Imagen',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Nombre',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Ap. Paterno',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Ap. Materno',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'CI',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Rol',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Telefono',
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
                                rows: filtrarDatosPorRol().map((dato) {
                                  int index = datos.indexOf(dato);
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          dato['idUsuario'].toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        dato['imagen'] != null
                                            ? Image.network(
                                                url +
                                                    '/usuario/images/${dato['imagen']}', // Cambia 'tu-ip-servidor' por tu dirección IP o dominio
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.white,
                                                  );
                                                },
                                              )
                                            : Icon(
                                                Icons.image_not_supported,
                                                color: Colors.white,
                                              ),
                                      ),

                                      DataCell(
                                        Text(
                                          dato['nombre'].toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          dato['apePat'].toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          dato['apeMat'] != null
                                              ? dato['apeMat'].toString()
                                              : "", // Verificar si es null
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          dato['ci'].toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      // DataCell(
                                      //   dato['admin'] == true
                                      //       ? Icon(
                                      //           Icons
                                      //               .admin_panel_settings, // Icono para admin
                                      //           color: Colors.white,
                                      //         )
                                      //       : Icon(
                                      //           Icons
                                      //               .person, // Icono para usuario no admin
                                      //           color: Colors.white,
                                      //         ),
                                      // ),
                                      DataCell(
                                        Text(
                                          obtenerRol(dato[
                                              'rol']), // Llamada a la función que traduce el número a texto
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          dato['telefono'].toString(),
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => editarDato(index),
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: Container(
                                                  padding: EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Color(0xFFF0B27A),
                                                  ),
                                                  child: Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 24,
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
                                                  padding: EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Color(0xFF58D68D),
                                                  ),
                                                  child: Icon(
                                                    Icons.remove_red_eye_sharp,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            GestureDetector(
                                              onTap: () => eliminarDato(index),
                                              child: MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: Container(
                                                  padding: EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Color(0xFFEC7063),
                                                  ),
                                                  child: Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _guardarCambiosObservador() async {
  // Captura los valores editados por el usuario utilizando el índice
  // String municipioEditado = municipioControllers[index].text;
  // String estacionEditada = estacionControllers[index].text;
  // String tipoEstacionEditada = tipoEstacionControllers[index].text;

  // print('1 Municipio: $municipioEditado');
  // print('1 Estación: $estacionEditada');
  // print('1 Tipo Estación: $tipoEstacionEditada');
  // print('1 aaaa' + idEstacionSeleccionada.toString());
  // print('1 pppp' + idMunicipioSeleccionada.toString());

  // final url2 = Uri.parse(url + '/estacion/editar_estacion');
  // final headers = {'Content-Type': 'application/json'};

  // // Crear un mapa de datos a enviar, manejando los campos vacíos
  // final data = {
  //   'idEstacion': idEstacionSeleccionada,
  //   'idMunicipio': idMunicipioSeleccionada,
  //   'nombre': estacionEditada.isEmpty ? null : estacionEditada,
  //   'tipoEstacion': tipoEstacionEditada.isEmpty ? null : tipoEstacionEditada,
  // };

  // final body = jsonEncode(data);
  // final response = await http.post(url2, headers: headers, body: body);
  // print('aaaa' + idEstacionSeleccionada.toString());
  // print('pppp' + idMunicipioSeleccionada.toString());

  // if (response.statusCode == 200) {
  //   print('Datos actualizados correctamente');
  //   Navigator.pop(context, true); // Indica que se guardaron cambios
  // } else {
  //   print('Error al actualizar los datos');
  // }

  // // Aquí puedes enviar los datos editados al servidor o actualizarlos localmente
  // print('Municipio: $municipioEditado');
  // print('Estación: $estacionEditada');
  // print('Tipo Estación: $tipoEstacionEditada');

  // Implementar lógica para guardar los cambios en el backend o localmente
}
