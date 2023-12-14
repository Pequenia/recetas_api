import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetas_api/services/auth_service.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
        backgroundColor: const Color.fromARGB(255, 233, 30, 152),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          // Agrega algún espaciado alrededor del Card
          margin: EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título "Registro"
                  Text(
                    'Registre un nuevo usuario',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  // Espaciado entre el título y el correo electrónico
                  SizedBox(height: 30.0),
                  // Campo de texto para el correo electrónico
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      String pattern =
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                      RegExp regExp = new RegExp(pattern);

                      return regExp.hasMatch(value ?? '')
                          ? null
                          : 'Ingresa un correo electrónico válido';
                    },
                  ),
                  // Espaciado entre el correo electrónico y la contraseña
                  SizedBox(height: 16.0),
                  // Campo de texto para la contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      return (value != null && value.length >= 6)
                          ? null
                          : 'La contraseña debe tener al menos 6 caracteres';
                    },
                  ),
                  // Espaciado entre la contraseña y el botón de registro
                  SizedBox(height: 16.0),
                  // Botón de registro
                  ElevatedButton(
                    onPressed: () async {
                      final authService =
                          Provider.of<AuthService>(context, listen: false);
                      final email = _emailController.text;
                      final password = _passwordController.text;

                      // Espera respuesta y si es asignado correctamente el token, registra
                      String? result =
                          await authService.createUser(email, password);

                      if (result == null) {
                        // Obtén el UserId después del registro exitoso
                        await authService.obtenerUserId(email);

                        // Realiza acciones adicionales con el UserId, si es necesario

                        Navigator.pushReplacementNamed(context, 'login');
                      } else {
                        print('Error en el registro: $result');
                      }
                    },
                    child: Text('Registrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 233, 30, 192),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
