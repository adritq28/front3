class Provincia{
  final int id;
  final String nombre;

  Provincia({required this.id, required this.nombre});

  factory Provincia.fromJson(Map<String, dynamic> json) {
    return Provincia(
      id: json['idEstacion'],
      nombre: json['nombre'],
    );
  }

    Map<String, dynamic> toJson() => {
        'idEstacion': id,
        'nombre': nombre,
      };

  String toStringProvincia() {
    return "Provincia [idProvincia=" + id.toString() + ", nombre=" + nombre + "]";
  }

}