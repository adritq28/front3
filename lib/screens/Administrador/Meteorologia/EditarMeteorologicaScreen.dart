import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;

class EditarMeteorologicaScreen extends StatefulWidget {
  final int idDatosEst;
  final double tempMax;
  final double tempMin;
  final double pcpn;
  final double tempAmb;
  final String dirViento;
  final double velViento;
  final double taevap;
  final String fechaReg;

  const EditarMeteorologicaScreen({
    required this.idDatosEst,
    required this.tempMax,
    required this.tempMin,
    required this.pcpn,
    required this.tempAmb,
    required this.dirViento,
    required this.velViento,
    required this.taevap,
    required this.fechaReg,
  });

  @override
  _EditarMeteorologicaScreenState createState() =>
      _EditarMeteorologicaScreenState();
}

class _EditarMeteorologicaScreenState extends State<EditarMeteorologicaScreen> {
  TextEditingController tempMaxController = TextEditingController();
  TextEditingController tempMinController = TextEditingController();
  TextEditingController pcpnController = TextEditingController();
  TextEditingController tempAmbController = TextEditingController();
  TextEditingController dirVientoController = TextEditingController();
  TextEditingController velVientoController = TextEditingController();
  TextEditingController taevapController = TextEditingController();
  TextEditingController fechaRegController = TextEditingController();
  String url = Url().apiUrl;
  String ip = Url().ip;
  
  @override
  void initState() {
    super.initState();
    tempMaxController.text = widget.tempMax.toString();
    tempMinController.text = widget.tempMin.toString();
    pcpnController.text = widget.pcpn.toString();
    tempAmbController.text = widget.tempAmb.toString();
    dirVientoController.text = widget.dirViento;
    velVientoController.text = widget.velViento.toString();
    taevapController.text = widget.taevap.toString();
    fechaRegController.text = widget.fechaReg;
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
  final url2 = Uri.parse(url+'/estacion/editar');
  final headers = {'Content-Type': 'application/json'};

  // Crear un mapa de datos a enviar, manejando los campos vacíos
  final data = {
    'idDatosEst': widget.idDatosEst,
    'tempMax': tempMaxController.text.isEmpty ? null : double.parse(tempMaxController.text),
    'tempMin': tempMinController.text.isEmpty ? null : double.parse(tempMinController.text),
    'pcpn': pcpnController.text.isEmpty ? null : double.parse(pcpnController.text),
    'tempAmb': tempAmbController.text.isEmpty ? null : double.parse(tempAmbController.text),
    'dirViento': dirVientoController.text,
    'velViento': velVientoController.text.isEmpty ? null : double.parse(velVientoController.text),
    'taevap': taevapController.text.isEmpty ? null : double.parse(taevapController.text),
    'fechaReg': fechaRegController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.soloNombreTelefono,), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(isHomeScreen: false, idUsuario: 0, estado: PerfilEstado.soloNombreTelefono,), // Indicamos que es la pantalla principal
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
                      Expanded(
                        child: TextField(
                          controller: tempAmbController,
                          decoration: _getInputDecoration(
                            'Temperatura Ambiente',
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
                          controller: dirVientoController,
                          decoration: _getInputDecoration(
                            'Dirección Viento',
                            Icons.air,
                          ),
                          style: TextStyle(
                            fontSize: 17.0,
                            color: Color.fromARGB(255, 201, 219, 255),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: velVientoController,
                          decoration: _getInputDecoration(
                            'Velocidad Viento',
                            Icons.speed,
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
                          controller: taevapController,
                          decoration: _getInputDecoration(
                            'Evaporación',
                            Icons.speed,
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
                      // Expanded(
                      //   child: TextField(
                      //     controller: fechaRegController,
                      //     decoration: _getInputDecoration(
                      //       'Fecha y Hora',
                      //       Icons.calendar_today,
                      //     ),
                      //     style: TextStyle(
                      //       fontSize: 17.0,
                      //       color: Color.fromARGB(255, 201, 219, 255),
                      //     ),
                      //     keyboardType: TextInputType.datetime,
                      //   ),
                      // ),
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
