import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/model/UsuarioEstacion.dart';
import 'package:helvetasfront/screens/Hidrologia/ListaEstacionHidrologicaScreen.dart';
import 'package:helvetasfront/screens/Meteorologia/ListaEstacionScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionHidrologicaService.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:helvetasfront/services/UsuarioService.dart';
import 'package:provider/provider.dart';

class ListaUsuarioEstacionScreen extends StatefulWidget {
  @override
  _ListaUsuarioEstacionScreenState createState() =>
      _ListaUsuarioEstacionScreenState();
}

class _ListaUsuarioEstacionScreenState
    extends State<ListaUsuarioEstacionScreen> {
  final UsuarioService _datosService2 = UsuarioService();
  late Future<List<UsuarioEstacion>> _futureUsuarioEstacion;
  final EstacionService _datosService3 = EstacionService();
  late UsuarioService miModelo4;
  late List<UsuarioEstacion> _usuarioEstacion = [];
  late List<String> _municipios = []; // Lista de municipios
  String? _selectedMunicipio; // Municipio seleccionado

  @override
  void initState() {
    super.initState();
    miModelo4 = Provider.of<UsuarioService>(context, listen: false);
    _cargarUsuarioEstacion();
  }

  Future<void> _cargarUsuarioEstacion() async {
    try {
      await miModelo4.getUsuario();
      List<UsuarioEstacion> a = miModelo4.lista11;
      setState(() {
        _usuarioEstacion = a;
        _municipios = a.map((e) => e.nombreMunicipio).toSet().toList();
      });
    } catch (e) {
      print('Error al cargar los datos5555: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: 0,
        estado: PerfilEstado.nombreEstacionMunicipio,
      ), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(
          isHomeScreen: false,
          showProfileButton: false,
          idUsuario: 0,
          estado: PerfilEstado.nombreEstacionMunicipio,
        ), // Indicamos que es la pantalla principal
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/fondo.jpg', // Cambia esto por la ruta de tu imagen
              fit: BoxFit.cover,
            ),
          ),
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
                      SizedBox(width: 15),
                      Flexible(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.0,
                          runSpacing: 5.0,
                          children: [
                            Text('Bienvenid@ | ',
                                style: GoogleFonts.lexend(
                                    textStyle: TextStyle(
                                  color: Colors.white60,
                                  //fontWeight: FontWeight.bold,
                                ))),
                            Text('OBSERVADORES METEOROLÓGICOS E HIDROLÓGICOS',
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
                SizedBox(height: 15),
                Text(
                  'Municipios: ',
                  style: GoogleFonts.lexend(
                    textStyle: TextStyle(
                      color:
                          Color.fromARGB(255, 239, 239, 240), // Color del texto
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold, // Tamaño de la fuente
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownButton<String>(
                  dropdownColor: Color.fromARGB(255, 3, 50, 112),
                  hint: Text(
                    "Seleccione un Municipio",
                    style: GoogleFonts.lexend(
                      textStyle: TextStyle(
                        color: Color.fromARGB(
                            255, 255, 255, 255), // Color del texto
                        fontSize: 15.0, // Tamaño de la fuente
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  value: _selectedMunicipio,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMunicipio = newValue;
                    });
                  },
                  items:
                      _municipios.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: GoogleFonts.convergence(
                            textStyle: TextStyle(
                              color: Color.fromARGB(
                                  255, 244, 244, 255), // Color del texto
                              fontSize: 15.0, // Tamaño de la fuente
                              //fontWeight: FontWeight.bold,
                            ),
                          )),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    child: op2(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget op2(BuildContext context) {
    List<UsuarioEstacion> usuariosFiltrados = _selectedMunicipio == null
        ? _usuarioEstacion
        : _usuarioEstacion
            .where((u) => u.nombreMunicipio == _selectedMunicipio)
            .toList();

    // Obtener el ancho de la pantalla
    double screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      itemCount: (usuariosFiltrados.length / 2).ceil(),
      itemBuilder: (context, index) {
        int firstIndex = index * 2;
        int secondIndex = firstIndex + 1;

        var firstDato = usuariosFiltrados[firstIndex];
        var secondDato = secondIndex < usuariosFiltrados.length
            ? usuariosFiltrados[secondIndex]
            : null;

        // Verificar si la pantalla es lo suficientemente ancha para mostrar dos cards en una fila
        bool isWideScreen =
            screenWidth > 600; // Puedes ajustar este valor según sea necesario

        return isWideScreen
            ? Row(
                children: [
                  Expanded(
                    child: buildCard(context, firstDato),
                  ),
                  if (secondDato != null)
                    Expanded(
                      child: buildCard(context, secondDato),
                    ),
                ],
              )
            : Column(
                children: [
                  buildCard(context, firstDato),
                  if (secondDato != null) buildCard(context, secondDato),
                ],
              );
      },
    );
  }

  Widget buildCard(BuildContext context, UsuarioEstacion dato) {
    return InkWell(
      onTap: () {
        // Mostrar el diálogo en lugar de navegar a otra pantalla
        mostrarDialogoContrasena(context, dato);
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundImage: AssetImage("images/${dato.imagen}"),
              ),
            ),
            SizedBox(height: 15),
            Text(
              "${dato.nombreCompleto}",
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Estación: ${dato.tipoEstacion.toUpperCase()}",
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              "Municipio: ${dato.nombreMunicipio.toUpperCase()}",
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              "Estación: ${dato.nombreEstacion.toUpperCase()}",
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.assignment_add,
                    size: 50,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    mostrarDialogoContrasena(context, dato);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void mostrarDialogoContrasena(BuildContext context, UsuarioEstacion dato) {
    final TextEditingController _passwordController = TextEditingController();
    bool _obscureText = true; // Mueve fuera del builder para manejar el estado correctamente

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFf0f0f0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Ingrese sus credenciales',
                      textAlign: TextAlign
                          .center, // Asegura que el texto esté centrado
                      style: TextStyle(
                        fontSize: 25, // Tamaño de fuente dinámico
                        color: Color(0xFF34495e),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 400,
                height: 200,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _passwordController,
                      obscureText:
                          _obscureText, // Asegúrate de que esto esté controlado por la variable
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            // Cambiar la visibilidad del texto
                            setState(() {
                              _obscureText =
                                  !_obscureText; // Actualiza la visibilidad del texto
                            });
                          },
                        ),
                        labelStyle:
                            TextStyle(color: Colors.blueGrey, fontSize: 20),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 12.0),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFFd35400), // Color de fondo del botón
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Bordes redondeados del botón
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      ),
                      child: Text('Cancelar',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFF1abc9c), // Color de fondo del botón
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Bordes redondeados del botón
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      ),
                      child: Text('OK',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () async {
                        final password = _passwordController.text;
                        final esValido = await _datosService3.validarContrasena(
                            password, dato.idUsuario);
                        if (esValido) {
                          // Aquí actualizamos el último acceso
                          await _datosService3.actualizarUltimoAcceso(dato.idUsuario);

                          Navigator.of(context).pop(); // Cierra el diálogo

                          // Redirigir a la pantalla correspondiente según el tipo de estación
                          if (dato.codTipoEstacion) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return ChangeNotifierProvider(
                                  create: (context) => EstacionService(),
                                  child: ListaEstacionScreen(
                                    idUsuario: dato.idUsuario,
                                    nombreMunicipio: dato.nombreMunicipio,
                                    nombreEstacion: dato.nombreEstacion,
                                    tipoEstacion: dato.tipoEstacion,
                                    nombreCompleto: dato.nombreCompleto,
                                    telefono: dato.telefono,
                                    idEstacion: dato.idEstacion,
                                    codTipoEstacion: dato.codTipoEstacion,
                                    imagen: dato.imagen,
                                  ),
                                );
                              }),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return ChangeNotifierProvider(
                                  create: (context) =>
                                      EstacionHidrologicaService(),
                                  child: ListaEstacionHidrologicaScreen(
                                    idUsuario: dato.idUsuario,
                                    nombreMunicipio: dato.nombreMunicipio,
                                    nombreEstacion: dato.nombreEstacion,
                                    tipoEstacion: dato.tipoEstacion,
                                    nombreCompleto: dato.nombreCompleto,
                                    telefono: dato.telefono,
                                    idEstacion: dato.idEstacion,
                                    codTipoEstacion: dato.codTipoEstacion,
                                    imagen: dato.imagen,
                                  ),
                                );
                              }),
                            );
                          }
                        } else {
                          // Mostrar error si la contraseña es incorrecta
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Error'),
                                content: Text('Contraseña incorrecta'),
                                actions: [
                                  TextButton(
                                    child: Text('Aceptar'),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Cierra el diálogo
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
