class HistFechaSiembra {
  final int idHistFecha;
  late DateTime fechaSiembra= DateTime.now();
  final int idCultivo;

  HistFechaSiembra({required this.idHistFecha, required this.fechaSiembra, 
  required this.idCultivo});

  factory HistFechaSiembra.fromJson(Map<String, dynamic> json) {
    return HistFechaSiembra(
      idHistFecha: json['idHistFecha']?? 0,
      fechaSiembra: json['fechaSiembra'] != null
          ? DateTime.parse(json['fechaSiembra'])
          : DateTime.now(),
      idCultivo: json['idCultivo'] ?? 0,
    );
  }
}
