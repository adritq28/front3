import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/dateTime/DateTimePicker.dart';
import 'package:helvetasfront/decorations/custom_decorations.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/CultivoService.dart';
import 'package:helvetasfront/url.dart';

class AnadirCultivoScreen extends StatefulWidget {
  final int idZona;

  const AnadirCultivoScreen({
    required this.idZona,
  });

  @override
  _AnadirCultivoScreenState createState() => _AnadirCultivoScreenState();
}

class _AnadirCultivoScreenState extends State<AnadirCultivoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _fechaSiembraController = TextEditingController();
  String url = Url().apiUrl;
  String ip = Url().ip;

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoController.dispose();
    _fechaSiembraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.soloNombreTelefono,),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomNavBar(isHomeScreen: false, idUsuario: 0, 
        estado: PerfilEstado.soloNombreTelefono,),
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
                            controller: _nombreController,
                            decoration: getInputDecoration(
                                'Nombre Cultivo', Icons.thermostat),
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el nombre del cultivo';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _tipoController,
                            decoration: getInputDecoration(
                                'Tipo Cultivo', Icons.thermostat),
                            style: TextStyle(
                              fontSize: 17.0,
                              color: Color.fromARGB(255, 201, 219, 255),
                            ),
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el tipo de cultivo';
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
                          child: GestureDetector(
                            onTap: () async {
                              final selectedDate =
                                  await DateTimePicker.selectDateTime(
                                      context, _fechaSiembraController);
                              if (selectedDate != null) {
                                setState(() {
                                  _fechaSiembraController.text = selectedDate;
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _fechaSiembraController,
                                decoration: getInputDecoration(
                                  'Fecha y Hora de Siembra',
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
                          onPressed: () => guardarDato(
                              _formKey,
                              url,
                              context,
                              widget.idZona,
                              _nombreController,
                              _tipoController,
                              _fechaSiembraController),
                          child: Text('Añadir Dato'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Footer(),
        ],
      ),
    );
  }
}
