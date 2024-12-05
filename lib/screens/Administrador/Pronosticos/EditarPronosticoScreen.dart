import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class EditarPronosticoScreen extends StatefulWidget {
  final int idPonostico;
  final double tempMax;
  final double tempMin;
  final double pcpn;
  final String fecha;

  const EditarPronosticoScreen({
    required this.idPonostico,
    required this.tempMax,
    required this.tempMin,
    required this.pcpn,
    required this.fecha,
  });

  @override
  _EditarPronosticoScreenState createState() =>
      _EditarPronosticoScreenState();
}

class _EditarPronosticoScreenState extends State<EditarPronosticoScreen> {
  TextEditingController tempMaxController = TextEditingController();
  TextEditingController tempMinController = TextEditingController();
  TextEditingController pcpnController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  String url = Url().apiUrl;
  String ip = Url().ip;
  
  @override
  void initState() {
    super.initState();
    tempMaxController.text = widget.tempMax.toString();
    tempMinController.text = widget.tempMin.toString();
    pcpnController.text = widget.pcpn.toString();
    fechaController.text = widget.fecha;
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
  final url2 = Uri.parse(url+'/datos_pronostico/editar');
  final headers = {'Content-Type': 'application/json'};

  final body = jsonEncode({
    'idPronostico': widget.idPonostico,
    'tempMax': tempMaxController.text.isEmpty ? null : double.parse(tempMaxController.text),
    'tempMin': tempMinController.text.isEmpty ? null : double.parse(tempMinController.text),
    'pcpn': pcpnController.text.isEmpty ? null : double.parse(pcpnController.text),
    'fecha': fechaController.text,
  });

  final response = await http.post(url2, headers: headers, body: body);

  if (response.statusCode == 200) {
    print('Datos actualizados correctamente');
    Navigator.pop(context, true);
  } else {
    print('Error al actualizar los datos: ${response.body}');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.soloNombreTelefono,),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomNavBar(isHomeScreen: false, idUsuario: 0, estado: PerfilEstado.soloNombreTelefono,),
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tempMaxController,
                          decoration: _getInputDecoration(
                            'Temperatura Máxima',
                            Icons.thermostat,
                          ),
                          style: TextStyle(
                            fontSize: 17.0,
                            color: Color.fromARGB(255, 201, 219, 255),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: tempMinController,
                          decoration: _getInputDecoration(
                            'Temperatura Mínima',
                            Icons.thermostat,
                          ),
                          style: TextStyle(
                            fontSize: 17.0,
                            color: Color.fromARGB(255, 201, 219, 255),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
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
                          controller: pcpnController,
                          decoration: _getInputDecoration(
                            'Precipitación',
                            Icons.water,
                          ),
                          style: TextStyle(
                            fontSize: 17.0,
                            color: Color.fromARGB(255, 201, 219, 255),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 203, 230, 255),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _guardarCambios,
                        child: Text('Guardar Cambios'),
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
