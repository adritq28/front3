

class UsuarioEstacion {
  final int idUsuario;
  final String nombreMunicipio;
  final String nombreEstacion;
  final String tipoEstacion;
  final String nombreCompleto;
  final String telefono;
  final int idEstacion;
  final bool codTipoEstacion;
  final String imagen;

  UsuarioEstacion({
    required this.idUsuario,
    required this.nombreMunicipio,
    required this.nombreEstacion,
    required this.tipoEstacion,
    required this.nombreCompleto,
    required this.telefono,
    required this.idEstacion,
    required this.codTipoEstacion,
    required this.imagen,
  });

  factory UsuarioEstacion.fromJson(Map<String, dynamic> json) {
    return UsuarioEstacion(
      idUsuario: json['idUsuario'],
      nombreMunicipio: (json['nombreMunicipio'] ?? ''),
      nombreEstacion: (json['nombreEstacion'] ?? ''),
      tipoEstacion: (json['tipoEstacion'] ?? ''),
      nombreCompleto: (json['nombreCompleto'] ?? ''),
      telefono: (json['telefono'] ?? ''),
      idEstacion: json['idEstacion']?? 0,
      codTipoEstacion: json['codTipoEstacion'] ?? true,
      imagen: (json['imagen'] ?? ''),

    );
  }

  Map<String, dynamic> toJson() => {
        'idUsuario': idUsuario,
        'nombreMunucipio': nombreMunicipio,
        'nombreEstacion': nombreEstacion,
        'tipoEstacion': tipoEstacion,
        'nombreCompleto': nombreCompleto,
        'telefono': telefono,
        'imagen': imagen,
      };

      

  String toStringUsuarioEstacion() {
    return "Usuario [idUsuario=" +
        idUsuario.toString() +
        ", nombreMunicipio=" +
        nombreMunicipio +
        ", nombreEstacion=" +
        nombreEstacion +
        ", tipoEstacion=" +
        tipoEstacion +
        ", nombreCompleto=" +
        nombreCompleto +
        ", telefono=" +
        telefono +
        "]";
  }
}
