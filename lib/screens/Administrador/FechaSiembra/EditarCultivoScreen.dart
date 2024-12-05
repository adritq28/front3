import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/Footer.dart';
import 'package:helvetasfront/dateTime/DateTimePicker.dart';
import 'package:helvetasfront/decorations/custom_decorations.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';
import 'package:helvetasfront/services/CultivoService.dart';
import 'package:helvetasfront/url.dart';

class EditarCultivoScreen extends StatefulWidget {
  final int idCultivo;
  final String nombre;
  final String fechaSiembra;
  final String fechaReg;
  final String tipo;

  const EditarCultivoScreen(
      {required this.idCultivo,
      required this.nombre,
      required this.fechaSiembra,
      required this.fechaReg,
      required this.tipo});

  @override
  _EditarCultivoScreenState createState() => _EditarCultivoScreenState();
}

class _EditarCultivoScreenState extends State<EditarCultivoScreen> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController fechaSiembraController = TextEditingController();
  TextEditingController fechaRegController = TextEditingController();
  TextEditingController tipoController = TextEditingController();

  String url = Url().apiUrl;
  String ip = Url().ip;

  @override
  void initState() {
    super.initState();
    nombreController.text = widget.nombre;
    fechaSiembraController.text = widget.fechaSiembra;
    fechaRegController.text = widget.fechaReg;
    tipoController.text = widget.tipo;
  }

  final CultivoService cultivoService = CultivoService();

  Future<void> _guardarCambios() async {
    bool success = await cultivoService.guardarCambios(
      idCultivo: widget.idCultivo,
      nombre: nombreController.text,
      fechaSiembra: fechaSiembraController.text,
      fechaReg: fechaRegController.text,
      tipo: tipoController.text,
    );

    if (success) {
      Navigator.pop(context, true); // Si los cambios se guardaron
    } else {
      Navigator.pop(context, false); // Si hubo error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.soloNombreTelefono,),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomNavBar(
            isHomeScreen: false, idUsuario: 0, estado: PerfilEstado.soloNombreTelefono,),
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
                          controller: nombreController,
                          decoration: getInputDecoration(
                            'Nombre Cultivo',
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
                        child: GestureDetector(
                          onTap: () async {
                            String? selectedDate =
                                await DateTimePicker.selectDateTime(
                                    context, fechaSiembraController);
                            if (selectedDate != null) {
                              setState(() {
                                fechaSiembraController.text = selectedDate;
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: fechaSiembraController,
                              decoration: getInputDecoration(
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
                        onPressed: _guardarCambios,
                        child: Text('Guardar Cambios'),
                      ),
                    ),
                  ),
                ],
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
