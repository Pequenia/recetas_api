import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recetas_api/pages/register_page.dart';
import 'package:recetas_api/providers/login_form_providers.dart';
import 'package:recetas_api/services/auth_service.dart';
import 'home_screen.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginFormProvider _loginFormProvider = LoginFormProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/nuberosa.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Título "Login"
                      Text(
                        'Login',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 30.0),
                      // Formulario de inicio de sesión
                      ChangeNotifierProvider(
                        create: (_) => _loginFormProvider,
                        child: _LoginForm(
                          emailController: _emailController,
                          passwordController: _passwordController,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              // Enlace para ir a la pantalla de registro
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text('¿No tienes una cuenta? ¡Regístrate aquí!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  _LoginForm({
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    final loginFormProvider = Provider.of<LoginFormProvider>(context);

    return Form(
      key: loginFormProvider.formKey,
      child: Column(
        children: [
          // Campo de texto para el correo electrónico
          TextFormField(
            controller: emailController,
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
          SizedBox(height: 16.0),
          // Campo de texto para la contraseña
          TextFormField(
            controller: passwordController,
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
          SizedBox(height: 16.0),
          // Botón de inicio de sesión
          ElevatedButton(
            onPressed: () async {
              if (loginFormProvider.isValidForm()) {
                loginFormProvider.isLoading = true;
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                final email = emailController.text;
                final password = passwordController.text;

                String? result = await authService.login(email, password);

                loginFormProvider.isLoading = false;

                if (result == null) {
                  // Obtener el UserId después de iniciar sesión
                  String userId = await authService.obtenerUserId(email);

                  // Verificar si hubo algún error al obtener el UserId
                  if (userId.isNotEmpty && userId != 'Usuario no encontrado') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Error al Obtener UserId'),
                          content:
                              Text('Hubo un problema al obtener el UserId.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  // Manejar el error en el inicio de sesión
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Inicio de Sesión Incorrecto'),
                        content: Text(result),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            },
            child: Text('Iniciar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 233, 30, 182),
            ),
          ),
        ],
      ),
    );
  }
}
