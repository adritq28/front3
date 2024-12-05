import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/model/Municipio.dart';
import 'package:helvetasfront/screens/Invitados/PronosticoAgrometeorologico.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/FenologiaService.dart';
import 'package:helvetasfront/services/MunicipioService.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class ZonasScreen extends StatefulWidget {
  final int idMunicipio;
  final String nombreMunicipio;

  ZonasScreen({
    required this.idMunicipio,
    required this.nombreMunicipio,
  });

  @override
  _ZonasScreenState createState() => _ZonasScreenState();
}

class _ZonasScreenState extends State<ZonasScreen> {
  late Future<void> _futureObtenerZonas;
  late MunicipioService miModelo5;
  late List<Municipio> _Municipio = [];

  @override
  void initState() {
    super.initState();
    miModelo5 = Provider.of<MunicipioService>(context, listen: false);
    _cargarMunicipio();
  }

  Future<void> _cargarMunicipio() async {
    print(widget.idMunicipio);
    try {
      await Provider.of<MunicipioService>(context, listen: false)
          .obtenerZonas(widget.idMunicipio);
    } catch (e) {
      print('Error al cargar los datos: $e');
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
          idUsuario: 0,
          estado: PerfilEstado.nombreEstacionMunicipio,
        ), // Indicamos que es la pantalla principal
      ),
      backgroundColor: Color(0xFF164092),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: op2(context),
      ),
    );
  }

  Widget op2(BuildContext context) {
    return Consumer<MunicipioService>(
      builder: (context, miModelo5, _) {
        // Crear un mapa único de zonas basadas en el nombre de la zona con sus coordenadas
        final zonasMap = {
          for (var dato in miModelo5.lista11)
            dato.nombreZona: {
              'latitud': dato.latitud,
              'longitud': dato.longitud
            }
        };

        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    _buildHeader(),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: zonasMap.length,
                  itemBuilder: (context, index) {
                    final nombreZona = zonasMap.keys.elementAt(index);
                    final latitud = zonasMap[nombreZona]?['latitud'] ?? 0.0;
                    ;
                    final longitud = zonasMap[nombreZona]?['longitud'] ?? 0.0;
                    ;

                    print(
                        'Zona: $nombreZona, Latitud: $latitud, Longitud: $longitud');
                    return _buildZonaCard(
                      context,
                      nombreZona,
                      miModelo5,
                      latitud,
                      longitud,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Footer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildZonaCard(BuildContext context, String nombreZona,
      MunicipioService miModelo5, double latitud, double longitud) {
    return GestureDetector(
      onTap: () {
        // Al hacer clic en una zona, mostrar un diálogo con las fechas de siembra
        _showFechasSiembraDialog(context, nombreZona, miModelo5);
      },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10),
              height: 400, // Cambié la altura para mejor visibilidad
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(
                      latitud, longitud), // Centro del mapa en La Paz, Bolivia
                  zoom: 16.0,
                ),
                nonRotatedChildren: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(latitud,
                            longitud), // Ajuste para centrar el pin en el centro del mapa
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.location_pin,
                            color: Color.fromARGB(255, 209, 54, 244),
                            size: 40,
                          ),
                        ),
                      ),
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(-13.5000, -58.1500), // Otro marcador
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              'Zona: $nombreZona',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Selecciona una fecha de siembra para ver el pronóstico',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////
  void _showFechasSiembraDialog(
      BuildContext context, String nombreZona, MunicipioService miModelo5) {
    // Obtener todas las fechas de siembra para la zona seleccionada
    final fechasSiembra = miModelo5.lista11
        .where((dato) => dato.nombreZona == nombreZona)
        .toList();

    List<String> selectedDates = []; // Para manejar los colores de fondo
    Color hoverColor = Color.fromARGB(151, 196, 148, 251)
        .withOpacity(0.2); // Color al pasar el mouse
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
  // Cambia el cursor a una mano (clic) cuando el mouse pasa sobre el GestureDetector
  SystemMouseCursors.click;
  
  // Cierra el modal
  Navigator.pop(context);

  // Navega a la pantalla PronosticoAgrometeorologico
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return ChangeNotifierProvider(
          create: (context) => FenologiaService(),
          child: PronosticoAgrometeorologico(
            idZona: dato.idZona,
            nombreMunicipio: dato.nombreMunicipio,
            idCultivo: dato.idCultivo,
            nombreZona: dato.nombreZona,
          ),
        );
      },
    ),
  );
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
                                        color:
                                            Color.fromARGB(255, 144, 101, 51),
                                        //.withOpacity(0.1), // Fondo al pasar el mouse
                                        borderRadius: BorderRadius.circular(
                                            10), // Esquinas redondeadas
                                      ),
                                      child: ListTile(
                                        title:
                                            Text('- ' + dato.nombreFechaSiembra,
                                                style: GoogleFonts.lexend(
                                                  textStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                600
                                                            ? 14
                                                            : 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                )),
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

  //////////

  // void _showFechasSiembraDialog(
  //     BuildContext context, String nombreZona, MunicipioService miModelo5) {
  //   // Obtener todas las fechas de siembra para la zona seleccionada
  //   final fechasSiembra = miModelo5.lista11
  //       .where((dato) => dato.nombreZona == nombreZona)
  //       .toList();

  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Fechas de Siembra para $nombreZona"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: fechasSiembra.map((dato) {
  //             return ListTile(
  //               title: Text(dato.nombreFechaSiembra),
  //               onTap: () {
  //                 Navigator.pop(context); // Cerrar el diálogo
  //                 // Ir al pronóstico agrometeorológico con los datos seleccionados
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(builder: (context) {
  //                     return ChangeNotifierProvider(
  //                       create: (context) => FenologiaService(),
  //                       child: PronosticoAgrometeorologico(
  //                         idZona: dato.idZona,
  //                         nombreMunicipio: dato.nombreMunicipio,
  //                         idCultivo: dato.idCultivo,
  //                         nombreZona: dato.nombreZona,
  //                       ),
  //                     );
  //                   }),
  //                 );
  //               },
  //             );
  //           }).toList(),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildHeader() {
    return Container(
      height: 70,
      color: Color.fromARGB(91, 4, 18, 43), // Fondo negro con opacidad
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 30,
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
                  style: GoogleFonts.lexend(
                    textStyle: TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ),
                Text(
                  '| Municipio de: ${widget.nombreMunicipio}',
                  style: GoogleFonts.lexend(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  ' | Lista de Zonas ',
                  style: GoogleFonts.lexend(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Widget _buildInfoTag(String text) {
//   return Container(
//     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//     decoration: BoxDecoration(
//       color: Colors.grey[200],
//       borderRadius: BorderRadius.circular(5),
//     ),
//     child: Text(
//       text,
//       style: TextStyle(fontSize: 12, color: Colors.black87),
//     ),
//   );
// }
}
