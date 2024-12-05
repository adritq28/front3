class DatosPronostico {
  //final int id;
  final int idUsuario;
  final String nombreMunicipio;
  final String nombreZona;
  final String nombreCompleto;
  final String telefono;
  //final int idPronostico;
  final double tempMax;
  final double tempMin;
  final double pcpn;
  late DateTime fecha = DateTime.now();
  final int idZona;
  final int idFenologia;
  //final bool edit;
  final bool delete;
  late DateTime fechaRangoDecenal = DateTime.now();

  DatosPronostico({
    //required this.id,
    required this.idUsuario,
    required this.nombreMunicipio,
    required this.nombreZona,
    required this.nombreCompleto,
    required this.telefono,
    //required this.idPronostico,
    required this.tempMax,
    required this.tempMin,
    required this.pcpn,
    required this.fecha,
    required this.idZona,
    required this.idFenologia,
    required this.delete,
    required this.fechaRangoDecenal
    //required this.edit,
  });

  factory DatosPronostico.fromJson(Map<String, dynamic> json) {
    return DatosPronostico(
      //id: json['idDatosEst'] ?? 0,
      idUsuario: json['idUsuario'] ?? 0,
      nombreMunicipio: (json['nombreMunicipio'] ?? ''),
      nombreZona: (json['nombreZona'] ?? ''),
      nombreCompleto: (json['nombreCompleto'] ?? ''),
      telefono: (json['telefono'] ?? ''),
      //idPronostico: json['idDatosPronostico'] ?? 0,
      tempMax: (json['tempMax'] ?? 0.0).toDouble(),
      tempMin: (json['tempMin'] ?? 0.0).toDouble(),
      pcpn: (json['pcpn'] ?? 0.0).toDouble(),
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'])
          : DateTime.now(),
      idZona: json['idZona'] ?? 0,
      idFenologia: json['idFenologia'] ?? 0,
      //edit: json['edit'] != null ? json['edit'] == true : false,
      delete: json['delete'] != null ? json['delete'] == true : false,
      fechaRangoDecenal: json['fechaRangoDecenal'] != null
          ? DateTime.parse(json['fechaRangoDecenal'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        //'idPronostico': idPronostico,
        'idUsuario': idUsuario,
        'nombreMunucipio': nombreMunicipio,
        'nombreZona': nombreZona,
        'nombreCompleto': nombreCompleto,
        'telefono': telefono,
        'tempMax': tempMax,
        'tempMin': tempMin,
        'pcpn': pcpn,
        'fecha':
            fecha.toUtc().toIso8601String(), //fechaDatos.toIso8601String(),
        'idZona': idZona,
        'idFenologia': idFenologia,
        //'edit': edit,
        'delete': delete,
        'fechaRangoDecenal': fechaRangoDecenal
      };

  String toStringDatosPronostico() {
    return "DatosPronostico [idUsuario.toString()" +
        ", nombreMunicipio=" +
        nombreMunicipio +
        ", nombreZona=" +
        nombreZona +
        ", nombreCompleto=" +
        nombreCompleto +
        ", telefono=" +
        telefono +
        ", fecha=" +
        fecha.toString() +
        //", idPronostico=" +
        //idPronostico.toString() +
        ", tempMax=" +
        tempMax.toString() +
        ", tempMin=" +
        tempMin.toString() +
        ", pcpn=" +
        pcpn.toString() +
        ", idZona=" +
        idZona.toString() +
        ", idFenologia=" +
        idFenologia.toString() +
        //", edit=" +
        // edit.toString() +
        ", delete=" +
        delete.toString() +
        "]";
  }
}