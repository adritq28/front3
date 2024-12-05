import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/model/Promotor.dart';
import 'package:helvetasfront/screens/OpcionZonaScreen.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:helvetasfront/services/PromotorService.dart';
import 'package:provider/provider.dart';

class PromotorScreen extends StatefulWidget {
  @override
  _PromotorScreenState createState() => _PromotorScreenState();
}

class _PromotorScreenState extends State<PromotorScreen> {
  final PromotorService _datosService2 = PromotorService();
  late Future<List<Promotor>> _futurePromotor;
  final EstacionService _datosService3 = EstacionService();
  late PromotorService miModelo4;
  late List<Promotor> _Promotor = [];
  late List<String> _municipios = []; // Lista de municipios
  String? _selectedMunicipio;

  @override
  void initState() {
    super.initState();
    miModelo4 = Provider.of<PromotorService>(context, listen: false);
    _cargarPromotor();
  }

  Future<void> _cargarPromotor() async {
    try {
      await miModelo4.getPromotor();
      List<Promotor> a = miModelo4.lista11;
      setState(() {
        _Promotor = a;
        _municipios = a.map((e) => e.nombreMunicipio).toSet().toList();
      });
    } catch (e) {
      print('Error al cargar los datossss: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        idUsuario: 0,
        estado: PerfilEstado.nombreZonaCultivo,
      ), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(
          isHomeScreen: false,
          showProfileButton: true,
          idUsuario: 0,
          estado: PerfilEstado.nombreZonaCultivo,
        ), // Indicamos que es la pantalla principal
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'images/fondo.jpg', // Cambia esto por la ruta de tu imagen
              fit: BoxFit.cover,
            ),
          ),
          // Contenido de la pantalla
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                SizedBox(height: 10),
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
                            Text('PROMOTORES DE TIEMPO Y CLIMA',
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
                  'MUNICIPIOS: ',
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
                                  255, 238, 238, 255), // Color del texto
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
    List<Promotor> usuariosFiltrados = _selectedMunicipio == null
        ? _Promotor
        : _Promotor.where((u) => u.nombreMunicipio == _selectedMunicipio)
            .toList();

    double isSmallScreen = MediaQuery.of(context)
        .size
        .width; // Ajusta este valor según tus necesidades

    return ListView.builder(
        itemCount: (usuariosFiltrados.length / 2).ceil(),
        itemBuilder: (context, index) {
          int firstIndex = index * 2;
          int secondIndex = firstIndex + 1;

          var firstDato = usuariosFiltrados[firstIndex];
          var secondDato = secondIndex < usuariosFiltrados.length
              ? usuariosFiltrados[secondIndex]
              : null;
          bool isWideScreen = isSmallScreen > 600;

          return isWideScreen
              ? Row(
                  children: [
                    Expanded(
                      child: buildPromotorCard(context, firstDato),
                    ),
                    if (secondDato != null)
                      Expanded(
                        child: buildPromotorCard(context, secondDato),
                      ),
                  ],
                )
              : Column(
                  children: [
                    buildPromotorCard(context, firstDato),
                    if (secondDato != null)
                      buildPromotorCard(context, secondDato),
                  ],
                );
        });
  }

  Widget buildPromotorCard(BuildContext context, Promotor dato) {
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
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
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
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Municipio: ${dato.nombreMunicipio.toUpperCase()}",
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  color: Color.fromARGB(255, 0, 7, 40),
                  fontSize: 16,
                ),
              ),
            ),
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

  void mostrarDialogoContrasena(BuildContext context, Promotor dato) {
    final TextEditingController _passwordController = TextEditingController();
    bool _obscureText = true;

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
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
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
                              _obscureText = !_obscureText;
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
                            final esValido = await _datosService3
                                .validarContrasena(password, dato.idUsuario);
                            if (esValido) {
                              Navigator.of(context).pop(); // Cierra el diálogo
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  print(dato.idUsuario);
                                  return ChangeNotifierProvider(
                                    create: (context) => PromotorService(),
                                    child: OpcionZonaScreen(
                                      idUsuario: dato.idUsuario,
                                      idZona: dato.idZona,
                                      nombreZona: dato.nombreZona,
                                      nombreMunicipio: dato.nombreMunicipio,
                                      nombreCompleto: dato.nombreCompleto,
                                      telefono: dato.telefono,
                                      idCultivo: dato.idCultivo,
                                      nombreCultivo: dato.nombreCultivo,
                                      tipo: dato.tipo,
                                      imagen: dato.imagen,
                                      imagenP: dato.imagenP,
                                    ),
                                  );
                                }),
                              );
                            } else {
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
                          }
                    ),
                  ],
                ),
              ]
            );
          },
        );
      },
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
        prefixIcon: Icon(
          prefixIcon,
          color: Color.fromARGB(255, 97, 173, 255),
        ), // Icono al inicio del campo
        border: OutlineInputBorder(
          // Borde del campo
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // Sin bordes visibles
        ),
        enabledBorder: OutlineInputBorder(
          // Borde cuando el campo está habilitado pero no seleccionado
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Colors.blue, width: 2), // Bordes azules
        ),
        focusedBorder: OutlineInputBorder(
          // Borde cuando el campo está seleccionado
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Colors.blue, width: 2), // Bordes azules
        ),
      ),
      // onSaved: (value) {
      //   _labelText = value!;
      // },
      onSaved: onSaved,
    );
  }
}
