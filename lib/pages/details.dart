import 'package:flutter/material.dart';
import 'package:recetas_api/services/auth_service.dart';

class RecipeDetailsPage extends StatefulWidget {
  final Map<String, dynamic> meal;

  RecipeDetailsPage({required this.meal});

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  bool isFavorito = false;

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  void checkIfFavorite() async {
    AuthService authService = AuthService();
    String userId = await authService.obtenerUserId('email');
    String idMeal = widget.meal['idMeal'];

    authService.existeFavorito(userId, idMeal).then((exists) {
      setState(() {
        isFavorito = exists;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal['strMeal']),
        actions: [
          IconButton(
            icon: Icon(
              isFavorito ? Icons.favorite : Icons.favorite_border,
              color: const Color.fromARGB(255, 13, 1, 0),
            ),
            onPressed: () {
              toggleFavorite();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(widget.meal['strMealThumb']),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Ingredientes:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: _buildIngredientsList(),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Elaboración:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.meal['strInstructions'],
                  style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    List<String> ingredients = [];
    for (int i = 1; i <= 30; i++) {
      if (widget.meal['strIngredient$i'] != null &&
          widget.meal['strIngredient$i'] != '') {
        ingredients.add(
            '${widget.meal['strIngredient$i']} - ${widget.meal['strMeasure$i']}');
      } else {
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredients
          .map(
            (ingredient) => Text(
              '- $ingredient',
              style: TextStyle(fontSize: 16),
            ),
          )
          .toList(),
    );
  }

  void toggleFavorite() async {
    AuthService authService = AuthService();
    String userId = await authService.obtenerUserId('email');
    String idMeal = widget.meal['idMeal'];

    if (isFavorito) {
      await authService.EliminarFavorito(userId, idMeal);
    } else {
      await authService.AgregarFavorito(userId, idMeal);
    }

    setState(() {
      isFavorito = !isFavorito;
    });
  }
}
