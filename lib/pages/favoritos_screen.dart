import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recetas_api/models/favorito.dart';
import 'package:recetas_api/pages/details.dart';
import 'dart:convert';
import 'package:recetas_api/services/auth_service.dart';

class Model {
  final String? url;
  final String? image;
  final String? source;
  final String? label;

  Model({this.url, this.image, this.source, this.label});
}

class FavoritosScreen extends StatefulWidget {
  @override
  _FavoritosScreenState createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<Favorito> favoritos = []; // Lista de favoritos
  List<Model> detallesFavoritos = []; // Lista de detalles de favoritos

  @override
  void initState() {
    super.initState();
    // Llamar a la función que obtiene la lista de favoritos desde AuthService
    obtenerFavoritos();
  }

  Future<void> obtenerFavoritos() async {
    AuthService authService = AuthService();

    // Obtener el correo electrónico del usuario actual
    String email = 'email';

    // Obtener el UserId del usuario actual
    String userId = await authService.obtenerUserId(email);

    // Obtener la lista de favoritos del usuario
    List<Favorito> listaFavoritos = await authService.obtenerFavoritos(userId);

    // Obtener detalles de cada platillo favorito y almacenarlos en detallesFavoritos
    for (Favorito favorito in listaFavoritos) {
      var response = await http.get(Uri.parse(
          'https://themealdb.com/api/json/v1/1/lookup.php?i=${favorito.idMeal}'));

      Map<String, dynamic> json = jsonDecode(response.body);

      if (json.containsKey('meals')) {
        var meal = json['meals'][0];
        Model detalleFavorito = Model(
          url: meal['idMeal'],
          image: meal['strMealThumb'],
          source: meal['strMeal'],
          label: meal['strMeal'],
        );
        setState(() {
          detallesFavoritos.add(detalleFavorito);
        });
      }
    }

    setState(() {
      favoritos = listaFavoritos;
    });
  }

  void _showDetailsPage(BuildContext context, String recipeId) async {
    final detailsUrl =
        'https://themealdb.com/api/json/v1/1/lookup.php?i=$recipeId';

    var response = await http.get(Uri.parse(detailsUrl));
    Map<String, dynamic> json = jsonDecode(response.body);

    if (json.containsKey('meals')) {
      var meal = json['meals'][0];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailsPage(meal: meal),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: GridView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        primary: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: detallesFavoritos.length,
        itemBuilder: (context, index) {
          final x = detallesFavoritos[index];
          return InkWell(
            onTap: () async {
              _showDetailsPage(context, x.url ?? '');
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(x.image ?? ''),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(3),
                    height: 45,
                    color: Color.fromARGB(255, 5, 5, 5).withOpacity(0.3),
                    child: Center(
                      child: Text(
                        x.label ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
