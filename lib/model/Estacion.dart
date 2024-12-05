class Estacion {
  final int id;
  final String nombreEstacion;
  final String latitud;
  final String longitud;
  final String altura;
  final bool estado;
  final String tipoEstacion;
  final int idMunicipio;
  final bool codTipoEstacion;

  Estacion(
      {required this.id,
      required this.nombreEstacion,
      required this.latitud,
      required this.longitud,
      required this.altura,
      required this.estado,
      required this.tipoEstacion,
      required this.idMunicipio,
      required this.codTipoEstacion});

  factory Estacion.fromJson(Map<String, dynamic> json) {
    return Estacion(
      id: json['idEstacion']?? 0,
      nombreEstacion: (json['nombre']?? ''),
      latitud: (json['latitud']?? ''),
      longitud: (json['longitud']?? ''),
      altura: (json['altura']?? ''),
      estado:  json['estado'] != null ? json['estado'] == true : false,
      tipoEstacion: (json['tipoEstacion']?? ''),
      idMunicipio: json['idMunicipio']?? 0,
      codTipoEstacion: json['codTipoEstacion'] != null ? json['codTipoEstacion'] == true : false,
    );
  }

  Map<String, dynamic> toJson() => {
        'idEstacion': id,
        'nombreEstacion': nombreEstacion,
        'latitud': latitud,
        'longitud': longitud,
        'altura': altura,
        'estado': estado,
        'tipoEstacion': tipoEstacion,
        'idMunicipio': idMunicipio,
        'codTipoEstacion': codTipoEstacion,
      };

  String toStringEstacion() {
    return "Estacion [idEstacion=" +
        id.toString() +
        ", nombreEstacion=" +
        nombreEstacion +
        ", latitud=" +
        latitud +
        ", longitud=" +
        longitud +
        ", altura=" +
        altura +
        ", estado=" +
        estado.toString() +
        ", tipoEstacion=" +
        tipoEstacion +
        ", idMunicipio=" +
        idMunicipio.toString() +
        ", codTipoEstacion=" +
        codTipoEstacion.toString() +
        "]";
  }
}
