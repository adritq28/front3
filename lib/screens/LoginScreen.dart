import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/model/UsuarioEstacion.dart';
import 'package:helvetasfront/screens/Invitados/MunicipiosScreen.dart';
import 'package:helvetasfront/screens/Meteorologia/ListaUsuarioEstacionScreen.dart';
import 'package:helvetasfront/screens/Promotor/PromotorScreen.dart';
import 'package:helvetasfront/services/EstacionService.dart';
import 'package:helvetasfront/services/PromotorService.dart';
import 'package:helvetasfront/services/UsuarioService.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(LoginScreen());
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final UsuarioService _datosService2 = UsuarioService();
  late Future<List<UsuarioEstacion>> _futureUsuarioEstacion;
  final EstacionService _datosService3 = EstacionService();
  late UsuarioService miModelo4;
  late List<UsuarioEstacion> _usuarioEstacion = [];
  //String phoneNumber = "59167078314";

  String url = Url().apiUrl;
  String ip = Url().ip;


  @override
  void initState() {
    super.initState();
  }

  void _showPasswordDialog(BuildContext context) {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
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
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      color: Color(0xFF34495e),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Container(
              width: 400,
              height: 300,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
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
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
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
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Llama a la función para mostrar el dialogo de número de teléfono
                      _showWhatsAppPhoneNumberDialog(context, 123); // Pasa el ID del usuario aquí
                    },
                    child: Text(
                      'Olvidé mi contraseña',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
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
                      backgroundColor: Color(0xFFd35400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                      backgroundColor: Color(0xFF1abc9c),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    ),
                    child: Text('OK',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    onPressed: () async {
                      String nombreUsuario = usernameController.text;
                      String password = passwordController.text;

                      // Llamar a la función login y verificar el resultado
                      Map<String, dynamic> resultadoLogin =
                          await Provider.of<UsuarioService>(context,
                                  listen: false)
                              .login(nombreUsuario, password, context);

                      if (resultadoLogin['success']) {
                        int idUsuario = resultadoLogin['idUsuario'];
                        await _datosService3.actualizarUltimoAcceso(idUsuario);
                      }

                      // Limpiar los campos
                      usernameController.clear();
                      passwordController.clear();
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


void _showWhatsAppPhoneNumberDialog(BuildContext context, int userId) {
  TextEditingController phoneController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
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
                'Ingrese su número de teléfono',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: Color(0xFF34495e),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: 400,
          height: 150,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Número de teléfono',
                  labelStyle: TextStyle(color: Colors.blueGrey, fontSize: 20),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              String phoneNumber = phoneController.text;

              if (phoneNumber.isNotEmpty) {
                // Llamar a tu backend para enviar el código de verificación
                bool success = await sendVerificationCode(userId, phoneNumber);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Código de verificación enviado!'),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Hubo un error al enviar el código.'),
                  ));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Por favor ingrese un número de teléfono.'),
                ));
              }
            },
            child: Text('Enviar código'),
          ),
        ],
      );
    },
  );
}

Future<bool> sendVerificationCode(int userId, String phoneNumber) async {
  final url2 = Uri.parse(url + '/api/sendVerificationCode?userId=$userId&phoneNumber=$phoneNumber');

  try {
    final response = await http.post(url2);

    if (response.statusCode == 200) {
      print('Código de verificación enviado.');
      return true;
    } else {
      print('Error al enviar el código: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error de conexión: $e');
    return false;
  }
}






// Future<void> sendVerificationCodeToWhatsApp(String phoneNumber) async {
//   final url = Uri.parse('http://yourbackend.com/api/sendVerificationCode?phoneNumber=$phoneNumber');

//   final response = await http.post(url);

//   if (response.statusCode == 200) {
//     // Código enviado exitosamente
//     print('Código de verificación enviado.');
//   } else {
//     // Error al enviar el código
//     print('Error al enviar el código.');
//   }
// }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            // Fondo de pantalla con imagen
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'images/fondo.jpg'), // Ruta de la imagen de fondo
                  fit: BoxFit
                      .cover, // Ajustar la imagen para cubrir todo el contenedor
                ),
              ),
            ),
            Positioned(
              top: 35,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      _showPasswordDialog(context);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.white),
                        SizedBox(height: 5),
                        Text(
                          'Admin',
                          style: GoogleFonts.gantari(
                            textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 35),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 75),
                  LoginForm(),
                  SizedBox(height: 55),
                  Footer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 600 ? 20 : 30;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Text(
        //     'Sistema Pachayatiña',
        //     textAlign: TextAlign.center, // Alinea el texto al centro
        //     style: GoogleFonts.lexend(
        //       textStyle: TextStyle(
        //         fontWeight: FontWeight.bold,
        //         color: Colors.white,
        //         fontSize: fontSize, // Tamaño del texto ajustado
        //       ),
        //     ),
        //   ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'SISTEMA DE DATOS PACHA',
                style: GoogleFonts.kodchasan(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: fontSize,
                  ),
                ),
              ),
              TextSpan(
                text: 'YATIÑA',
                style: GoogleFonts.gantari(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Image.asset(
            'images/logo4.png', // Ruta de la imagen
            width: 300, // Ancho de la imagen
          ),
        ),
        Container(
          width: 300, // Define el ancho máximo del botón
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListaUsuarioEstacionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF8F9F9),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(
              Icons.badge, // Icono a agregar
              size: 24, // Tamaño del icono
              color: Color(0xFF164092), // Color del icono
            ),
            label: Text(
              "Soy Observador",
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF164092),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: 300, // Define el ancho máximo del botón
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF8F9F9),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ChangeNotifierProvider(
                    create: (context) => PromotorService(),
                    child:
                        PromotorScreen(), // Aquí envuelve la pantalla en el Provider
                  );
                }),
              );
            },
            icon: Icon(
              Icons.assignment_ind, // Icono a agregar
              size: 24, // Tamaño del icono
              color: Color(0xFF164092), // Color del icono
            ),
            label: Text(
              "Soy Promotor",
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF164092),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: 300, // Define el ancho máximo del botón
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ChangeNotifierProvider(
                    create: (context) => EstacionService(),
                    child:
                        MunicipiosScreen(), // Aquí envuelve la pantalla en el Provider
                  );
                }),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF8F9F9),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(
              Icons.account_circle, // Icono a agregar
              size: 24, // Tamaño del icono
              color: Color(0xFF164092), // Color del icono
            ),
            label: Text(
              "Entrar como invitado",
              style: GoogleFonts.lexend(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF164092),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
