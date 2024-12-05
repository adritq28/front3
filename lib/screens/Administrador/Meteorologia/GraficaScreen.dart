import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:helvetasfront/CustomDrawer.dart';
import 'package:helvetasfront/CustomNavBar.dart';
import 'package:helvetasfront/screens/perfil/PerfilScreen.dart';

class GraficaScreen extends StatelessWidget {
  final List<Map<String, dynamic>> datos;

  GraficaScreen({required this.datos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
drawer: CustomDrawer(idUsuario: 0,estado: PerfilEstado.soloNombreTelefono,), // Drawer para pantallas pequeñas
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60), // Altura del AppBar
        child: CustomNavBar(isHomeScreen: false, idUsuario: 0, estado: PerfilEstado.soloNombreTelefono,), // Indicamos que es la pantalla principal
      ),
      body: Container(
        color: Color.fromARGB(221, 0, 24, 68), // Fondo oscuro
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  backgroundColor: Color.fromARGB(221, 1, 16, 76), // Fondo del gráfico oscuro
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      margin: 8,
                      getTextStyles: (context, value) => TextStyle(
                        color: Colors.white, // Cambiar color de texto a blanco
                        fontWeight: FontWeight.bold,
                      ),
                      getTitles: (value) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return '${date.day}/${date.month}';
                      },
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      margin: 12,
                      getTextStyles: (context, value) => TextStyle(
                        color: Colors.white, // Cambiar color de texto a blanco
                        fontWeight: FontWeight.bold,
                      ),
                      getTitles: (value) {
                        return value.toString();
                      },
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: datos.map((dato) {
                        final dateStr = dato['fechaReg']?.toString();
                        final tempMaxStr = dato['tempMax']?.toString();
                        if (dateStr != null && tempMaxStr != null) {
                          final date = DateTime.tryParse(dateStr);
                          final tempMax = double.tryParse(tempMaxStr);
                          if (date != null && tempMax != null) {
                            return FlSpot(date.millisecondsSinceEpoch.toDouble(), tempMax);
                          }
                        }
                        return null;
                      }).whereType<FlSpot>().toList(),
                      isCurved: true,
                      colors: [Colors.redAccent], // Color de la línea
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: datos.map((dato) {
                        final dateStr = dato['fechaReg']?.toString();
                        final tempMinStr = dato['tempMin']?.toString();
                        if (dateStr != null && tempMinStr != null) {
                          final date = DateTime.tryParse(dateStr);
                          final tempMin = double.tryParse(tempMinStr);
                          if (date != null && tempMin != null) {
                            return FlSpot(date.millisecondsSinceEpoch.toDouble(), tempMin);
                          }
                        }
                        return null;
                      }).whereType<FlSpot>().toList(),
                      isCurved: true,
                      colors: [Colors.blueAccent], // Color de la línea
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: datos.map((dato) {
                        final dateStr = dato['fechaReg']?.toString();
                        final tempAmbStr = dato['tempAmb']?.toString();
                        if (dateStr != null && tempAmbStr != null) {
                          final date = DateTime.tryParse(dateStr);
                          final tempAmb = double.tryParse(tempAmbStr);
                          if (date != null && tempAmb != null) {
                            return FlSpot(date.millisecondsSinceEpoch.toDouble(), tempAmb);
                          }
                        }
                        return null;
                      }).whereType<FlSpot>().toList(),
                      isCurved: true,
                      colors: [Colors.greenAccent], // Color de la línea
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegend(Colors.redAccent, 'Temp Max'),
                _buildLegend(Colors.blueAccent, 'Temp Min'),
                _buildLegend(Colors.greenAccent, 'Temp Amb'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
