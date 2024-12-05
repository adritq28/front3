import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/model/Estacion.dart';
import 'package:helvetasfront/screens/Invitados/ListaInvitadoHidrologicaScreen.dart';
import 'package:helvetasfront/screens/Invitados/ListaInvitadoMeteorologicaScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionHidrologicaService.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:provider/provider.dart';

class EstacionScreen extends StatefulWidget {
  final int idMunicipio;
  final String nombreMunicipio;

  EstacionScreen({
    required this.idMunicipio,
    required this.nombreMunicipio,
  });

  @override
  _EstacionScreenState createState() => _EstacionScreenState();
}

class _EstacionScreenState extends State<EstacionScreen> {
  late EstacionService _datosService;
  late Future<List<Estacion>> _futureEstacion;
  late List<Estacion> _estacion = [];

  @override
  void initState() {
    super.initState();
    _datosService = Provider.of<EstacionService>(context, listen: false);
    _cargarEstacion();
  }

  Future<void> _cargarEstacion() async {
    try {
      await _datosService.getEstacion(widget.idMunicipio);
      setState(() {
        _estacion = _datosService.lista115;
      });
    } catch (e) {
      print('Error al cargar los datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.nombreEstacionMunicipio,
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
      backgroundColor: Color(0xFF164092),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                          textAlign: TextAlign.center, 
                              style: GoogleFonts.lexend(
                                  textStyle: TextStyle(
                                color: Colors.white60,
                                //fontWeight: FontWeight.bold,
                              ))),
                          Text('| Municipio de: ${widget.nombreMunicipio}',
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
              const SizedBox(height: 10),
              _buildEstacionesList(),
              const SizedBox(height: 20),
              Footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstacionesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _estacion.length,
      itemBuilder: (context, index) {
        final dato = _estacion[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return ChangeNotifierProvider(
                  create: (context) => dato.codTipoEstacion
                      ? EstacionService()
                      : EstacionHidrologicaService(),
                  child: dato.codTipoEstacion
                      ? ListaInvitadoMeteorologicaScreen(
                          idEstacion: dato.id,
                          nombreEstacion: dato.nombreEstacion,
                          nombreMunicipio: widget.nombreMunicipio,
                        )
                      : ListaInvitadoHidrologicaScreen(
                          idEstacion: dato.id,
                          nombreEstacion: dato.nombreEstacion,
                          nombreMunicipio: widget.nombreMunicipio,
                        ),
                );
              }),
            );
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[200]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 15),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage("images/estacion.png"),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estacion: ${dato.nombreEstacion}',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            color: Colors.blueGrey[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Tipo de Estacion: ${dato.tipoEstacion}',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            color: Colors.blueGrey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.blue),
                  onPressed: () {
                    // Acción al presionar el botón
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
