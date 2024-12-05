class Promotor {
  final int idUsuario;
  final String nombreMunicipio;
  final String nombreZona;
  final String nombreCompleto;
  final String telefono;
  final int idZona;
  final int idCultivo;
  final String nombreCultivo;
  final String tipo;
  final int idMunicipio;
  final String imagen;
  final String imagenP;
  final String nombreFechaSiembra;

  Promotor({
    required this.idUsuario,
    required this.nombreMunicipio,
    required this.nombreZona,
    required this.nombreCompleto,
    required this.telefono,
    required this.idZona,
    required this.idCultivo,
    required this.nombreCultivo,
    required this.tipo,
    required this.idMunicipio,
    required this.imagen,
    required this.imagenP,
    required this.nombreFechaSiembra

  });

  factory Promotor.fromJson(Map<String, dynamic> json) {
    return Promotor(
      idUsuario: json['idUsuario']?? 0,
      nombreMunicipio: json['nombreMunicipio'] ?? 'N/A',
      nombreZona: json['nombreZona'] ?? 'N/A',
      nombreCompleto: json['nombreCompleto'] ?? 'N/A',
      telefono: json['telefono'] ?? 'N/A',
      idZona: json['idZona']?? 0,
      idCultivo: json['idCultivo']?? 0,
      nombreCultivo: json['nombreCultivo'] ?? 'N/A',
      tipo: json['tipo'] ?? 'N/A',
      idMunicipio: json['idMunicipio']?? 0,
      imagen: json['imagen'] ?? 'N/A',
      imagenP: json['imagen'] ?? 'N/A',
      nombreFechaSiembra: json['nombreFechaSiembra'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() => {
        'idUsuario': idUsuario,
        'nombreMunucipio': nombreMunicipio,
        'nombreZona': nombreZona,
        'nombreCompleto': nombreCompleto,
        'telefono': telefono,
        'idZona': idZona,
        'idCultivo': idCultivo,
        'nombreCultivo': nombreCultivo,
        'tipo': tipo,
        'idMunicipio': idMunicipio,
        'imagen': imagen,
        'nombreFechaSiembra': nombreFechaSiembra,
      };

  String toStringPromotor() {
    return "Usuario [idUsuario=" +
        idUsuario.toString() +
        ", nombreMunicipio=" +
        nombreMunicipio +
        ", nombreZona=" +
        nombreZona +
        ", nombreCompleto=" +
        nombreCompleto +
        ", telefono=" +
        telefono +
        ", idZona=" +
        idZona.toString() +
        ", idCultivo=" +
        idCultivo.toString() +
        ", nombre=" +
        nombreCultivo.toString() +
        ", tipo=" +
        tipo.toString() +
        ", idMunicipio=" +
        idMunicipio.toString() +
        ", imagen=" +
        imagen.toString() +
        "]";
  }
}
