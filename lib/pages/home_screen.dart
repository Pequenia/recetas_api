import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recetas_api/widgets/drawer.dart';
import 'details.dart';

class Model {
  final String? url;
  final String? image;
  final String? source;
  final String? label;

  Model({this.url, this.image, this.source, this.label});
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => MyAppState();
}

class MyAppState extends State<HomeScreen> {
  List<Model> list = <Model>[];
  final url = 'https://themealdb.com/api/json/v1/1/search.php?s=';

  getApiData() async {
    var response = await http.get(Uri.parse(url));
    Map<String, dynamic> json = jsonDecode(response.body);

    if (json.containsKey('meals')) {
      (json['meals'] as List).forEach((e) {
        Model model = Model(
          url: e['idMeal'],
          image: e['strMealThumb'],
          source: e['strMeal'],
          label: e['strMeal'],
        );
        setState(() {
          list.add(model);
        });
      });
    }
  }

  void performSearch(String query) async {
    final searchUrl = 'https://themealdb.com/api/json/v1/1/search.php?s=$query';

    var response = await http.get(Uri.parse(searchUrl));
    Map<String, dynamic> json = jsonDecode(response.body);

    setState(() {
      list.clear();
    });

    if (json.containsKey('meals')) {
      (json['meals'] as List).forEach((e) {
        Model model = Model(
          url: e['idMeal'],
          image: e['strMealThumb'],
          source: e['strMeal'],
          label: e['strMeal'],
        );
        setState(() {
          list.add(model);
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getApiData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Recetas"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/foodbck.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      list.clear();
                    });
                  }
                },
                onSubmitted: (value) {
                  performSearch(value);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  fillColor:
                      const Color.fromARGB(255, 255, 64, 182).withOpacity(0.2),
                  filled: true,
                  hintText: 'Buscar recetas...',
                ),
              ),
              SizedBox(
                height: 15,
              ),
              GridView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                primary: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final x = list[i];
                  return InkWell(
                    onTap: () async {
                      await _showDetailsPage(context, x.url ?? '');
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
                            color:
                                Color.fromARGB(255, 5, 5, 5).withOpacity(0.3),
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
              )
            ],
          ),
        ),
      ),
      drawer: CustomDrawer(),
    );
  }

  Future<void> _showDetailsPage(BuildContext context, String recipeId) async {
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
}
