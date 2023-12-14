class Favorito {
  final String UserId;
  final String idMeal;

  Favorito({
    required this.UserId,
    required this.idMeal,
  });

  // Factory method para crear una instancia de Favorito desde un mapa
  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      UserId: json['userId'],
      idMeal: json['idMeal'],
    );
  }

  // Método para convertir una instancia de Favorito a un mapa
  Map<String, dynamic> toJson() {
    return {
      'userId': UserId,
      'idMeal': idMeal,
    };
  }
}
