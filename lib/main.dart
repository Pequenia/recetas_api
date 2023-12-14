import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetas_api/pages/chek_auth_screen.dart';
import 'package:recetas_api/pages/favoritos_screen.dart';
import 'package:recetas_api/pages/home_screen.dart';
import 'package:recetas_api/pages/login_page.dart';
import 'package:recetas_api/pages/register_page.dart';
import 'package:recetas_api/services/auth_service.dart';
import 'package:recetas_api/services/notifications_services.dart';

void main() => runApp(AppState());

class AppState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      initialRoute: 'checking',
      routes: {
        'login': (_) => LoginPage(),
        'register': (_) => RegisterScreen(),
        'home': (_) => HomeScreen(),
        'checking': (_) => CheckAuthScreen(),
        'favoritos': (_) => FavoritosScreen(), // Agrega esta línea
      },
      scaffoldMessengerKey: NotificationsService.messengerKey,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
            elevation: 0, color: Color.fromARGB(255, 255, 82, 226)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color.fromARGB(255, 255, 82, 229), elevation: 0),
      ),
      home: FutureBuilder(
        future: Provider.of<AuthService>(context).readToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.hasData &&
                snapshot.data != null &&
                (snapshot.data as String).isNotEmpty) {
              return HomeScreen();
            } else {
              return LoginPage();
            }
          }
        },
      ),
    );
  }
}
