import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/url.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AnadirDatoMeteorologicoScreen extends StatefulWidget {
  final int idEstacion;

  const AnadirDatoMeteorologicoScreen({
    required this.idEstacion,
  });

  @override
  _AnadirDatoMeteorologicoScreenState createState() =>
      _AnadirDatoMeteorologicoScreenState();
}

class _AnadirDatoMeteorologicoScreenState
    extends State<AnadirDatoMeteorologicoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tempMaxController = TextEditingController();
  final TextEditingController _tempMinController = TextEditingController();
  final TextEditingController _pcpnController = TextEditingController();
  final TextEditingController _tempAmbController = TextEditingController();
  final TextEditingController _dirVientoController = TextEditingController();
  final TextEditingController _velVientoController = TextEditingController();
  final TextEditingController _taevapController = TextEditingController();
  final TextEditingController _fechaRegController = TextEditingController();
  String url = Url().apiUrl;
  String ip = Url().ip;
  
  @override
  void dispose() {
    _tempMaxController.dispose();
    _tempMinController.dispose();
    _pcpnController.dispose();
    _tempAmbController.dispose();
    _dirVientoController.dispose();
    _velVientoController.dispose();
    _taevapController.dispose();
    _fechaRegController.dispose();
    super.dispose();
  }

  Future<void> guardarDato() async {
    if (_formKey.currentState!.validate()) {
      // Validar y asegurarse de que _fechaRegController.text tenga un valor
      final fechaReg =
          _fechaRegController.text.isNotEmpty ? _fechaRegController.text : null;

      final newDato = {
        'idEstacion': widget.idEstacion,
        'tempMax': _tempMaxController.text.isEmpty
            ? null
            : double.parse(_tempMaxController.text),
        'tempMin': _tempMinController.text.isEmpty
            ? null
            : double.parse(_tempMinController.text),
        'pcpn': _pcpnController.text.isEmpty
            ? null
            : double.parse(_pcpnController.text),
        'tempAmb': _tempAmbController.text.isEmpty
            ? null
            : double.parse(_tempAmbController.text),
        'dirViento': _dirVientoController.text,
        'velViento': _velVientoController.text.isEmpty
            ? null
            : double.parse(_velVientoController.text),
        'taevap': _taevapController.text.isEmpty
            ? null
            : double.parse(_taevapController.text),
        'fechaReg':
            _fechaRegController.text.isEmpty ? null : _fechaRegController.text,
      };

      final response = await http.post(
        Uri.parse(url+'/datosEstacion/addDatosEstacion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newDato),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dato añadido correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        final errorMessage = response.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir dato: $errorMessage')),
        );
      }
    }
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

  Future<void> _selectDateTime() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final DateTime dateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        setState(() {
          _fechaRegController.text =
              DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(dateTime);
        });
      }
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tempMaxController,
                            decoration: _getInputDecoration(
                                'Temp Max', Icons.thermostat),
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa la temperatura máxima';
                                }
                                final double? tempMax = double.tryParse(value);
                                if (tempMax == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (tempMax < -5 || tempMax > 35) {
                                  return 'La temperatura debe estar entre -18 y 15';
                                }
                                return null;
                              },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _tempMinController,
                            decoration: _getInputDecoration(
                                'Temp Min', Icons.thermostat),
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa la temperatura mínima';
                                }
                                final double? tempMin = double.tryParse(value);
                                if (tempMin == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (tempMin < -18 || tempMin > 15) {
                                  return 'La temperatura debe estar entre -18 y 15';
                                }
                                return null;
                              },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _pcpnController,
                            decoration: _getInputDecoration(
                                'Precipitación', Icons.water),
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null; // Permitir campo vacío
                              }
                              final double? precipitation =
                                  double.tryParse(value);
                              if (precipitation == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (precipitation < 0 || precipitation > 70) {
                                return 'La precipitación debe estar entre 0 y 50';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _tempAmbController,
                            decoration: _getInputDecoration(
                                'Temp Ambiente', Icons.thermostat),
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null; // Permitir campo vacío
                              }
                              final double? tempAmb = double.tryParse(value);
                              if (tempAmb == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (tempAmb < 0 || tempAmb > 90) {
                                return 'La temperatura ambiente debe estar entre 0 y 90';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dirVientoController,
                            decoration:
                                _getInputDecoration('Dir Viento', Icons.air),
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            )
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _velVientoController,
                            decoration:
                                _getInputDecoration('Vel Viento', Icons.speed),
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                              if (value == null || value.isEmpty) {
                                // Permitir campo vacío
                                return null;
                              }

                              final double? dirviento = double.tryParse(value);
                              if (dirviento == null) {
                                return 'Por favor ingresa un número válido';
                              }
                              if (dirviento < 0 || dirviento > 20) {
                                return 'La velocidad del viento debe estar entre 0 y 20';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _taevapController,
                            decoration:
                                _getInputDecoration('Evaporación', Icons.speed),
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                if (value == null || value.isEmpty) {
                                  // Permitir campo vacío
                                  return null;
                                }
                                final double? evaporacion =
                                    double.tryParse(value);
                                if (evaporacion == null) {
                                  return 'Por favor ingresa un número válido';
                                }
                                if (evaporacion < 0 || evaporacion > 80) {
                                  return 'La evaporacion debe estar entre 0 y 80';
                                }
                                return null;
                              }
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap:
                                _selectDateTime, // Mostrar el selector de fecha y hora al tocar el TextField
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _fechaRegController,
                                decoration: _getInputDecoration(
                                  'Fecha y Hora',
                                  Icons.calendar_today,
                                ),
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color.fromARGB(255, 201, 219, 255),
                                ),
                                keyboardType: TextInputType.datetime,
                              ),
                            ),
                          ),
                        ),
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
                          onPressed: guardarDato,
                          child: Text('Añadir Dato'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
