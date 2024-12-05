class DatosEstacionHidrologica {
  //final int id;
  final int idUsuario;
  final String nombreMunicipio;
  final String nombreEstacion;
  final String tipoEstacion;
  final String nombreCompleto;
  late DateTime fechaReg = DateTime.now();
  final double limnimetro;
  final int idEstacion;
  final bool delete;

  DatosEstacionHidrologica({
    //required this.id,
    required this.idUsuario,
    required this.nombreMunicipio,
    required this.nombreEstacion,
    required this.tipoEstacion,
    required this.nombreCompleto,
    required this.fechaReg,
    required this.limnimetro,
    required this.idEstacion,
    required this.delete,
  });

  factory DatosEstacionHidrologica.fromJson(Map<String, dynamic> json) {
    return DatosEstacionHidrologica(
      //id: json['idDatosEst'] ?? 0,
      idUsuario: json['idUsuario'] ?? 0,
      nombreMunicipio: (json['nombreMunicipio'] ?? ''),
      nombreEstacion: (json['nombreEstacion'] ?? ''),
      tipoEstacion: (json['tipoEstacion'] ?? ''),
      nombreCompleto: (json['nombreCompleto'] ?? ''),
      fechaReg: json['fechaReg'] != null
          ? DateTime.parse(json['fechaReg'])
          : DateTime.now(),
      limnimetro: (json['limnimetro'] ?? 0.0).toDouble(),
      idEstacion: json['idEstacion'] ?? 0,
      delete: json['delete'] != null ? json['delete'] == true : false,
    );
  }

  Map<String, dynamic> toJson() => {
        //'idDatosEstacion': id,
        'idUsuario': idUsuario,
        'nombreMunucipio': nombreMunicipio,
        'nombreEstacion': nombreEstacion,
        'tipoEstacion': tipoEstacion,
        'nombreCompleto': nombreCompleto,
        'fechaReg':
            fechaReg.toUtc().toIso8601String(), //fechaDatos.toIso8601String(),
        'limnimetro': limnimetro,
        'idEstacion': idEstacion,
        'delete': delete,
      };

  String toStringDatosEstacionHidrologica() {
    return "DatosEstacion [idUsuario.toString()" +
        ", nombreMunicipio=" +
        nombreMunicipio +
        ", nombreEstacion=" +
        nombreEstacion +
        ", tipoEstacion=" +
        tipoEstacion +
        ", nombreCompleto=" +
        nombreCompleto +
        ", fechaReg=" +
        fechaReg.toString() +
        ", limnimetro=" +
        limnimetro.toString() +
        ", delete=" +
        delete.toString() +
        "]";
  }
}
