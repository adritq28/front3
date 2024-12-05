class Role{
  final int id;
  final String roleName;
  final String descripcion;

  Role(
      {required this.id,
      required this.roleName,
      required this.descripcion});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['idRole'],
      roleName: json['roleName'],
      descripcion: json['descripcion'],
    );
  }

    Map<String, dynamic> toJson() => {
        'idRole': id,
        'roleName': roleName,
        'descripcion': descripcion,
      };

  String toStringPersona() {
    return "Role [idRole=" + id.toString() + ", roleName=" + roleName + ", descripcion=" + descripcion + "]";
  }
}
