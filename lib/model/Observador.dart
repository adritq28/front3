class Observador {
  final int id;
  final int idUsuario;
  final int idEstacion;
  final bool estadoDatos;

  Observador(
      {required this.id,
      required this.idUsuario,
      required this.idEstacion,
      required this.estadoDatos,
      });

  factory Observador.fromJson(Map<String, dynamic> json) {
    return Observador(
      id: json['idObservador'],
      idUsuario: json['idUsuario'],
      idEstacion: json['idEstacion'],
      estadoDatos: json['estadoDatos'],
    );
  }

    Map<String, dynamic> toJson() => {
        'idObservador': id,
        'idUsuario': idUsuario,
        'idEstacion': idEstacion,
        'estadoDatos': estadoDatos,
      };

  String toStringPersona() {
    return "Usuario [idUsuario=" + id.toString()
                + ", idUsuario=" + idUsuario.toString() + ", idEstacion=" + idEstacion.toString() +  ", estadoDatos=" + estadoDatos.toString() + "]";
  }
}
