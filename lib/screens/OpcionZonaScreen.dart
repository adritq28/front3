import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/model/Promotor.dart';
import 'package:helvetasfront/screens/Promotor/FormFechaSiembra.dart';
import 'package:helvetasfront/screens/Promotor/FormPronostico.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/PromotorService.dart';
import 'package:helvetasfront/services/PronosticoService.dart';
import 'package:helvetasfront/textos.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OpcionZonaScreen extends StatefulWidget {
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

  OpcionZonaScreen(
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
  _OpcionZonaScreenState createState() => _OpcionZonaScreenState();
}

class _OpcionZonaScreenState extends State<OpcionZonaScreen> {
  late PromotorService promotorService;
  late Future<List<Promotor>> _promotorFuture;
  String url = Url().apiUrl;
  String ip = Url().ip;
  List<Map<String, dynamic>> _comunidades = [];

  @override
  void initState() {
    super.initState();
    promotorService = Provider.of<PromotorService>(context, listen: false);
    _promotorFuture = _cargarPromotor();
    //fetchComunidades(widget.idZona);
    _cargarComunidades();
  }

  Future<List<Map<String, dynamic>>> fetchComunidades(int idZona) async {

    try {
      //final response = await http.get(url);
      final response =
        await http.get(Uri.parse(url+'/zona/lista_comunidad/$idZona'));

      if (response.statusCode == 200) {
        // Decodifica el JSON y convierte la lista en una lista de mapas
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener las comunidades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

   Future<void> _cargarComunidades() async {
    try {
      List<Map<String, dynamic>> comunidades = await fetchComunidades(widget.idZona);
      setState(() {
        _comunidades = comunidades;
      });
    } catch (e) {
      print('Error al cargar comunidades: $e');
    }
  }

  Future<List<Promotor>> _cargarPromotor() async {
    try {
      final datosService2 =
          Provider.of<PromotorService>(context, listen: false);
      await datosService2.obtenerListaZonas(widget.idUsuario);
      final lista = datosService2.lista11;
      for (var promotor in lista) {
        print(
            'ID Usuario: ${promotor.idUsuario}, Nombre: ${promotor.nombreCompleto}');
      }

      return lista;
    } catch (e) {
      print('Error al cargar los datos: $e');
      return [];
    }
  }

  Widget _buildZonaCard(
    BuildContext context,
    String nombreZona,
    String imagen,
    String nombreCultivo,
    String tipo,
    String nombreFechaSiembra,
    PromotorService promotorService,
  ) {
    return GestureDetector(
      onTap: () {
        // Al hacer clic en una zona, mostrar un diálogo con las fechas de siembra
        _showFechasSiembraDialog(context, nombreZona, promotorService);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints
                  .maxWidth, // Limita el ancho al del contenedor padre
              maxHeight: constraints.maxHeight,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: AssetImage("images/$imagen"),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      nombreCultivo,
                      style: GoogleFonts.lexend(
                        textStyle: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Text(
                      "Zona: ${nombreZona.toUpperCase()}",
                      style: getTextStyleNormal20n(),
                    ),
                    Text(
                      "Tipo Cultivo: $tipo",
                      style: getTextStyleNormal20n(),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Selecciona una fecha de siembra para ver el pronóstico',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.assignment_add,
                          color: Colors.blueAccent,
                          size: 40, // Tamaño ajustado para pantallas pequeñas
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFechasSiembraDialog(BuildContext context, String nombreZona,
      PromotorService promotorService) {
    // Obtener todas las fechas de siembra para la zona seleccionada
    final fechasSiembra = promotorService.lista11
        .where((dato) => dato.nombreZona == nombreZona)
        .toList();

    List<String> selectedDates = []; // Para manejar los colores de fondo
    Color hoverColor = Color.fromARGB(151, 196, 148, 251).withOpacity(0.2); // Color al pasar el mouse
    Color normalColor = Colors.transparent;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Fondo transparente para el modal
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context)
              .pop(), // Cierra el modal al hacer clic fuera de él
          child: Center(
            child: GestureDetector(
              onTap:
                  () {}, // Evita que los clics en el contenido cierren el modal
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.9), // Fondo blanco con opacidad
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Fechas de Siembra para $nombreZona",
                        style: GoogleFonts.lexend(
                          textStyle: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 9, 64, 142),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: fechasSiembra.map((dato) {
                          return MouseRegion(
                              // Cambia el color al pasar el mouse
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) {
                                setState(() {
                                  // Cambia el color al pasar el mouse
                                  selectedDates.add(dato.nombreFechaSiembra);
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  // Remueve el color al salir del mouse
                                  selectedDates.remove(dato.nombreFechaSiembra);
                                });
                              },
                              child: GestureDetector(
                                onTap: () {
                                  cursor:
                                  SystemMouseCursors.click;
                                  Navigator.pop(context); // Cerrar el modal
                                  // Aquí puedes mostrar más detalles o realizar otra acción
                                  _mostrarModal(
                                      dato); // Muestra otro modal o realiza una acción
                                },
                                child: Container(
                                  // Cambia el fondo al ser tocado
                                  decoration: BoxDecoration(
                                    color: selectedDates
                                            .contains(dato.nombreFechaSiembra)
                                        ? hoverColor
                                        : normalColor, // Cambia el color según la selección
                                    borderRadius: BorderRadius.circular(
                                        10), // Esquinas redondeadas
                                  ),

                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      // Cambia el fondo al ser tocado
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 144, 101, 51),
                                        //.withOpacity(0.1), // Fondo al pasar el mouse
                                        borderRadius: BorderRadius.circular(
                                            10), // Esquinas redondeadas
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          '- ' + dato.nombreFechaSiembra,
                                          style: GoogleFonts.lexend(textStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    600
                                                ? 14
                                                : 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),)
                                          
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ));
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _mostrarModal(Promotor promotor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context)
              .pop(), // Cierra el modal al hacer clic fuera de él
          child: Center(
            child: GestureDetector(
              onTap:
                  () {}, // Para evitar que los clics en el contenido cierren el modal
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(226, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: MediaQuery.of(context).size.width *
                      0.8, // Ajuste de ancho
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Opciones',
                            style: GoogleFonts.lexend(
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 9, 64, 142),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            color: Colors.black,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Cerrar el modal
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return ChangeNotifierProvider(
                                create: (context) => PromotorService(),
                                child: FormFechaSiembra(
                                  idUsuario: promotor.idUsuario,
                                  idZona: promotor.idZona,
                                  nombreZona: promotor.nombreZona ?? '',
                                  nombreMunicipio:
                                      promotor.nombreMunicipio ?? '',
                                  nombreCompleto: promotor.nombreCompleto ?? '',
                                  telefono: promotor.telefono ?? '',
                                  idCultivo: promotor.idCultivo ?? 0,
                                  nombreCultivo: promotor.nombreCultivo ?? '',
                                  tipo: promotor.tipo ?? '',
                                  imagen: promotor.imagen ?? '',
                                  imagenP: widget.imagenP ?? '',
                                ),
                              );
                            }),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey, // Color de fondo plomo
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Bordes redondeados
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20), // Ajuste de tamaño
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.white), // Icono
                            SizedBox(width: 10), // Espacio entre icono y texto
                            Flexible(
                              child: Text(
                                'Registro Fecha Siembra',
                                style: GoogleFonts.lexend(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Cerrar el modal
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return ChangeNotifierProvider(
                                create: (context) => PronosticoService(),
                                child: FormPronostico(
                                  idUsuario: promotor.idUsuario,
                                  idZona: promotor.idZona,
                                  idCultivo: promotor.idCultivo,
                                  nombreZona: promotor.nombreZona ?? '',
                                  nombreMunicipio:
                                      promotor.nombreMunicipio ?? '',
                                  nombreCompleto: promotor.nombreCompleto ?? '',
                                  telefono: promotor.telefono ?? '',
                                  nombreCultivo: promotor.nombreCultivo ?? '',
                                  imagenP: widget.imagenP ?? '',
                                ),
                              );
                            }),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Color de fondo verde
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Bordes redondeados
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20), // Ajuste de tamaño
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wb_sunny, color: Colors.white), // Icono
                            SizedBox(width: 10), // Espacio entre icono y texto
                            Flexible(
                              child: Text(
                                'Registro Pronostico Decenal',
                                style: GoogleFonts.lexend(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: widget.idUsuario,
        estado: PerfilEstado.nombreZonaCultivo,
        nombreZona: widget.nombreZona,
        nombreCultivo: widget.nombreCultivo,
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomNavBar(
          isHomeScreen: false,
          idUsuario: widget.idUsuario,
          estado: PerfilEstado.nombreZonaCultivo,
          nombreZona: widget.nombreZona,
          nombreCultivo: widget.nombreCultivo,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/fondo.jpg',
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
                  color: Color.fromARGB(91, 4, 18, 43),
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
                                style: GoogleFonts.lexend(
                                    textStyle: TextStyle(
                                  color: Colors.white60,
                                ))),
                            Text('| ${widget.nombreCompleto}',
                                style: GoogleFonts.lexend(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))),
                            Text('| Municipio de: ${widget.nombreMunicipio}',
                                style: GoogleFonts.lexend(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Promotor>>(
                    future: _promotorFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay datos disponibles',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        );
                      } else {
                        // Agrupa los datos por nombre de zona y elimina duplicados
                        final zonasUnicas = <String, Promotor>{};
                        for (var promotor in snapshot.data!) {
                          zonasUnicas[promotor.nombreZona] = promotor;
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 1;
                            double width = constraints.maxWidth;

                            if (width >= 1200) {
                              crossAxisCount = 3;
                            } else if (width >= 800) {
                              crossAxisCount = 2;
                            }

                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  childAspectRatio:
                                      width / (crossAxisCount * 400),
                                ),
                                itemCount: zonasUnicas.values.length,
                                itemBuilder: (context, index) {
                                  var promotor =
                                      zonasUnicas.values.elementAt(index);
                                  return _buildZonaCard(
                                    context,
                                    promotor.nombreZona,
                                    promotor.imagen,
                                    promotor.nombreCultivo,
                                    promotor.tipo,
                                    promotor.nombreFechaSiembra,
                                    promotorService,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
