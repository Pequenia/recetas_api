import 'package:flutter/material.dart';

// Este provider gestiona el estado del formulario de inicio de sesión.
class LoginFormProvider extends ChangeNotifier {
  // Clave global para identificar y gestionar el estado del formulario.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Variables para almacenar el correo electrónico y la contraseña ingresados por el usuario.
  String email = '';
  String password = '';

  // Bandera que indica si la aplicación está en un estado de carga, por ejemplo, durante un inicio de sesión.
  bool _isLoading = false;

  // Getter para obtener el estado actual de carga.
  bool get isLoading => _isLoading;

  // Setter para actualizar el estado de carga y notificar a los listeners (widgets) interesados.
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Método para verificar si el formulario es válido según las reglas de validación definidas.
  bool isValidForm() {
    // Si formKey.currentState es nulo, se considera que el formulario no es válido.
    // Si no es nulo, se invoca el método validate() para realizar la validación del formulario.
    // El operador ?? se utiliza para proporcionar un valor predeterminado (false) si formKey.currentState es nulo.
    return formKey.currentState?.validate() ?? false;
  }
}
