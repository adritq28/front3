class Municipio {
  final int idMunicipio;
  final String nombreMunicipio;
  final int idZona;
  final String nombreZona;
  final String nombreCultivo;
  final int idCultivo;
  final String imagen;
  final double latitud;
  final double longitud;
  final String nombreFechaSiembra;

  Municipio(
      {required this.idMunicipio,
      required this.nombreMunicipio,
      required this.idZona,
      required this.nombreZona,
      required this.nombreCultivo,
      required this.idCultivo,
      required this.imagen,
      required this.latitud,
      required this.longitud,
      required this.nombreFechaSiembra});

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      idMunicipio: json['idMunicipio'] ?? 0,
      nombreMunicipio: (json['nombreMunicipio'] ?? ''),
      idZona: json['idZona'] ?? 0,
      nombreZona: (json['nombreZona'] ?? ''),
      nombreCultivo: (json['nombreCultivo'] ?? ''),
      idCultivo: json['idCultivo'] ?? 0,
      imagen: (json['imagen'] ?? ''),
      longitud: (json['longitud'] ?? 0.0).toDouble(),
      latitud: (json['latitud'] ?? 0.0).toDouble(),
      nombreFechaSiembra: (json['nombreFechaSiembra'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'idMunicipio': idMunicipio,
        'nombreMunicipio': nombreMunicipio,
        'idZona': idZona,
        'nombreZona': nombreZona,
        'nombreCultivo': nombreCultivo,
        'idCultivo': idCultivo,
        'imagen': imagen,
        'latitud': latitud,
        'longitud': longitud,
      };

  String toStringMunicipio() {
    return "Municipio [idMunicipio=" +
        idMunicipio.toString() +
        ", nombre=" +
        nombreMunicipio +
        ", idZona=" +
        idZona.toString() +
        ", nombreZona=" +
        nombreZona.toString() +
        ", nombreCultivo=" +
        nombreCultivo.toString() +
        ", idCultivo=" +
        idCultivo.toString() +
        ", imagen=" +
        imagen.toString() +
        "]";
  }
}
