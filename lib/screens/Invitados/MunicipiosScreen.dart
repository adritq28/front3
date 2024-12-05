import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/screens/Invitados/ListaEstacionScreen.dart';
import 'package:helvetasfront/screens/Invitados/ZonasScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:helvetasfront/services/MunicipioService.dart';
import 'package:provider/provider.dart';

class MunicipiosScreen extends StatefulWidget {
  @override
  _MunicipiosScreenState createState() => _MunicipiosScreenState();
}

class _MunicipiosScreenState extends State<MunicipiosScreen> {
  late EstacionService miModelo4;

  @override
  void initState() {
    super.initState();
    miModelo4 = Provider.of<EstacionService>(context, listen: false);
    _cargarMunicipio();
  }

  Future<void> _cargarMunicipio() async {
    try {
      await miModelo4.getMunicipio2();
      setState(() {});
    } catch (e) {
      print('Error al cargar los datos: $e');
    }
  }

  void _mostrarModal(int idMunicipio, String nombreMunicipio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(226, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
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
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return ChangeNotifierProvider(
                                create: (context) => EstacionService(),
                                child: EstacionScreen(
                                  idMunicipio: idMunicipio,
                                  nombreMunicipio: nombreMunicipio,
                                ),
                              );
                            }),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, color: Colors.white),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Estaciones Hidrometeorologicas',
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
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return ChangeNotifierProvider(
                                create: (context) => MunicipioService(),
                                child: ZonasScreen(
                                  idMunicipio: idMunicipio,
                                  nombreMunicipio: nombreMunicipio,
                                  //nombreCultivo: nombreCultivo,
                                ),
                              );
                            }),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wb_sunny, color: Colors.white),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Pronóstico Agrometeorológico',
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
      backgroundColor: Color(0xFF164092),
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
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            height: 90,
            color: Color.fromARGB(
                91, 4, 18, 43), // Fondo negro con 20% de opacidad
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
                      Text("Bienvenido Invitado",
                          style: GoogleFonts.lexend(
                              textStyle: TextStyle(
                            color: Colors.white60,
                            //fontWeight: FontWeight.bold,
                          ))),
                      Text('| Lista de Municipios',
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

          const SizedBox(height: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10.0),
              child: op2(context),
            ),
          ),
          Footer(), // Agrega el footer aquí
        ],
      ),
    );
  }

  Widget op2(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: miModelo4.lista114.length,
            itemBuilder: (context, index) {
              final dato = miModelo4.lista114[index];
              return GestureDetector(
                onTap: () {
                  _mostrarModal(dato.idMunicipio, dato.nombreMunicipio);
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                    image: DecorationImage(
                        image: AssetImage(
                            "images/${dato.imagen}"), // Imagen de fondo
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.4),
                        BlendMode.darken,
                        ),
                      ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dato.nombreMunicipio,
                        style: GoogleFonts.lexend(
                          textStyle: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 209, 103),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white70,
                            size: 20,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Más información",
                            style: GoogleFonts.lexend(
                              textStyle: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 220,
                            child: ElevatedButton(
                              onPressed: () {
                                _mostrarModal(dato.idMunicipio, dato.nombreMunicipio);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFbb8fce),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                                shadowColor: Colors.purpleAccent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 20, color: Colors.white,),
                                  SizedBox(width: 10),
                                  Text(
                                    'Seleccionar Opción',
                                    style: GoogleFonts.lexend(
                                      textStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

//   Widget footer() {
//     return Container(
//       padding: EdgeInsets.all(10),
//       //color: Color(0xFF123456), // Color del footer
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             '© 2024 Helvetas. Todos los derechos reservados.',
//             style: GoogleFonts.lexend(
//               textStyle: TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
}
