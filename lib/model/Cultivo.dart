class Cultivo {
  //final int id;
  final int idCultivo;
  final String nombre;
  final String tipo;
  late DateTime fechaSiembra = DateTime.now();
  final String idZona;
  final bool delete;
  final bool edit;
  late DateTime fechaReg = DateTime.now();
  final int idUsuarioReg;
  final String nombreFechaSiembra;

  Cultivo({
    //required this.id,
    required this.idCultivo,
    required this.nombre,
    required this.tipo,
    required this.fechaSiembra,
    required this.idZona,
    required this.delete,
    required this.edit,
    required this.fechaReg,
    required this.idUsuarioReg,
    required this.nombreFechaSiembra
  });

  factory Cultivo.fromJson(Map<String, dynamic> json) {
    return Cultivo(
      //id: json['idDatosEst'] ?? 0,
      idCultivo: json['idCultivo'] ?? 0,
      nombre: (json['nombre'] ?? ''),
      tipo: (json['tipo'] ?? ''),
      fechaSiembra: json['fechaSiembra'] != null
          ? DateTime.parse(json['fechaSiembra'])
          : DateTime.now(),
      idZona: (json['idZona'] ?? ''),
      delete: json['delete'] != null ? json['delete'] == true : false,
      //idPronostico: json['idCultivo'] ?? 0,
      edit: (json['edit'] ?? 0.0).toDouble(),
      fechaReg: json['fechaReg'] != null
          ? DateTime.parse(json['fechaReg'])
          : DateTime.now(),
      idUsuarioReg: json['idUsuarioReg'] ?? 0,
      nombreFechaSiembra: (json['nombreFechaSiembra'] ?? ''),
      //edit: json['edit'] != null ? json['edit'] == true : false,
      
    );
  }

  Map<String, dynamic> toJson() => {
        //'idPronostico': idPronostico,
        'idCultivo': idCultivo,
        'nombre': nombre,
        'tipo': tipo,
        'fechaSiembra': fechaSiembra.toUtc().toIso8601String(),
        'idZona': idZona,
        'delete': delete,
        'edit': edit,
        'fechaReg': fechaReg.toUtc().toIso8601String(), //fechaSiembraDatos.toIso8601String(),
        'idUsuarioReg': idUsuarioReg,
      };

  String toStringCultivo() {
    return "Cultivo ["+ idCultivo.toString() +
        ", nombre=" +
        nombre +
        ", tipo=" +
        tipo +
        ", idZona=" +
        idZona +
        ", delete=" +
        delete.toString() +
        ", fechaSiembra=" +
        fechaSiembra.toString() +
        //", idPronostico=" +
        //idPronostico.toString() +
        ", edit=" +
        edit.toString() +
        ", fechaReg=" +
        fechaReg.toString() +
        ", idUsuarioReg=" +
        idUsuarioReg.toString() +
        "]";
  }
}