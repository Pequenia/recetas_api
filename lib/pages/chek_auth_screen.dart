import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetas_api/pages/home_screen.dart';
import 'package:recetas_api/pages/login_page.dart';
import 'package:recetas_api/services/auth_service.dart';

// Esta pantalla se encarga de verificar si el usuario ya ha iniciado sesión al cargar la aplicación.
class CheckAuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtener una instancia del servicio de autenticación utilizando Provider.
    final authService = Provider.of<AuthService>(context,
        listen: false); //false porque no o construye, solo lo revisa

    return Scaffold(
      body: Center(
        child: FutureBuilder(
          // Leer el token almacenado para determinar si el usuario ha iniciado sesión previamente.
          future: authService.readToken(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            // Si no hay datos en el snapshot, muestra un widget de texto vacío.
            if (!snapshot.hasData) return Text('');

            // Si el token es una cadena vacía, redirige a la pantalla de inicio de sesión.
            if (snapshot.data == '') {
              Future.microtask(() {
                Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => LoginPage(),
                        transitionDuration: Duration(seconds: 0)));
              });
            } else {
              // Si hay un token, redirige a la pantalla de inicio.
              Future.microtask(() {
                Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => HomeScreen(),
                        transitionDuration: Duration(seconds: 0)));
              });
            }

            // Si no se cumple ninguna de las condiciones anteriores, devuelve un contenedor vacío.
            return Container();
          },
        ),
      ),
    );
  }
}
