class Usuario {
  final int id;
  final String nombreUsuario;
  final String nombre;
  final String apePat;
  final String apeMat;
  final String telefono;
  final String ci;
  final String password;

  Usuario(
      {required this.id,
      required this.nombreUsuario,
      required this.nombre,
      required this.apePat,
      required this.apeMat,
      required this.telefono,
      required this.ci,
      required this.password});




  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['idUsuario']?? 0,
      nombreUsuario: (json['nombreUsuario'] ?? ''),
      nombre: (json['nombre'] ?? ''),
      apePat: (json['apePat'] ?? ''),
      apeMat: (json['apeMat'] ?? ''),
      telefono: (json['telefono'] ?? ''),
      ci: (json['ci'] ?? ''),
      password: (json['password'] ?? ''),
    );
  }

    Map<String, dynamic> toJson() => {
        'idUsuario': id,
        'nombreUsuario': nombreUsuario,
        'nombre': nombre,
        'apePat': apePat,
        'apeMat': apeMat,
        'ci': ci,
        'password': password,
      };

  // String toJsonString() {
  //   return jsonEncode(toJson());
  // }

  String toStringPersona() {
    return "Usuario [idUsuario=" + id.toString() + ", nombreUsuario=" + nombreUsuario + ", nombre=" + nombre
                + ", apePat=" + apePat + ", apeMat=" + apeMat + ", telefono=" + telefono +", ci=" + ci + ", password=" + password + "]";
  }
}
