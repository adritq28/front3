class Zona {
  //final int id;
  final int idZona;
  final String nombre;
  final int idMunicipio;
  final double latitud;
  final double longitud;

  Zona({
    //required this.id,
    required this.idZona,
    required this.nombre,
    required this.idMunicipio,
    required this.latitud,
    required this.longitud
  });

  factory Zona.fromJson(Map<String, dynamic> json) {
    return Zona(
      //id: json['idDatosEst'] ?? 0,
      idZona: json['idZona'] ?? 0,
      nombre: (json['nombre'] ?? ''),
      idMunicipio: json['idMunicipio'] ?? 0,
      longitud: (json['longitud'] ?? 0.0).toDouble(),
      latitud: (json['latitud'] ?? 0.0).toDouble(),
      //edit: json['edit'] != null ? json['edit'] == true : false,
      
    );
  }

  Map<String, dynamic> toJson() => {
        //'idPronostico': idPronostico,
        'idZona': idZona,
        'nombre': nombre,
        'idMunicipio': idMunicipio,
      };

  String toStringZona() {
    return "Zona ["+ idZona.toString() +
        ", nombre=" +
        nombre +
        ", idMunicipio=" +
        idMunicipio.toString() +
        "]";
  }
}