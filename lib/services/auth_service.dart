import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:recetas_api/models/favorito.dart';

class AuthService extends ChangeNotifier {
  final String _baseUrl = 'LoginPrueba.somee.com'; // Sitio web
  final storage = FlutterSecureStorage();

  Future<String?> createUser(String email, String password) async {
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
    };

    final url = Uri.http(_baseUrl, '/api/Cuentas/registrar');

    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(authData),
    );

    try {
      final dynamic decodedResp = json.decode(resp.body);

      if (decodedResp is Map<String, dynamic>) {
        if (decodedResp.containsKey('token')) {
          await storage.write(key: 'token', value: decodedResp['token']);
          await storage.write(key: 'email', value: email);

          return null;
        } else {
          return decodedResp['error'] ?? 'Error desconocido';
        }
      } else {
        return 'Error desconocido: La respuesta del servidor no es válida';
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      return 'Error al procesar la respuesta del servidor';
    }
  }

  Future<String?> login(String email, String password) async {
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
    };
    final url = Uri.http(_baseUrl, '/api/Cuentas/login');

    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(authData),
    );

    try {
      final Map<String, dynamic> decodedResp = json.decode(resp.body);

      if (decodedResp.containsKey('token')) {
        await storage.write(key: 'token', value: decodedResp['token']);
        await storage.write(key: 'email', value: email);

        return null;
      } else {
        return decodedResp['error'] ?? 'Inicio de sesión incorrecto';
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      return 'Error al iniciar sesión';
    }
  }

  Future logout() async {
    await storage.delete(key: 'token');
  }

  Future<String> readToken() async {
    return await storage.read(key: 'token') ?? '';
  }
  //meter en git todo

  //------------------------------------------------------////////////------------------------------------------------------------//

  Future<String> obtenerUserId(String email) async {
    try {
      String? emaiil = await storage.read(key: 'email');

      final url = Uri.http(_baseUrl, '/api/Cuentas/ObtenerUserId/$emaiil');

      final token = await readToken();
      final resp = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print('Respuesta del servidor al obtener el UserId: ${resp.body}');
      print('Correo electrónico actual: $email');
      if (resp.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(resp.body);
        print(resp.body);
        return data['userId'];
      } else {
        print(
            'Error al obtener el UserId. Código de estado: ${resp.statusCode}');
        return '0';
      }
    } catch (error) {
      print('Excepción al obtener el UserId: $error');
      return '1';
    }
  }

  Future<void> AgregarFavorito(String UserId, String IdComida) async {
    try {
      final Map<String, dynamic> data = {
        'UserId': UserId,
        'idMeal': IdComida,
      };

      print(UserId);
      print(IdComida);

      final url = Uri.http(_baseUrl, '/api/Cuentas/Favoritos');

      final token = await readToken();
      final resp = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(data),
      );

      print('Respuesta al agregar favorito: ${resp.body}');

      if (resp.statusCode == 200) {
        print('Agregado con éxito');
      } else {
        print('Error al agregar. Código de estado: ${resp.statusCode}');
      }
    } catch (error) {
      print('Excepción al agregar: $error');
    }
  }

  Future<void> EliminarFavorito(String UserId, String IdComida) async {
    try {
      final Map<String, dynamic> data = {
        'UserId': UserId,
        'idMeal': IdComida,
      };

      final url = Uri.http(_baseUrl, '/api/Cuentas/Favoritos');

      final token = await readToken();
      final resp = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(data),
      );

      if (resp.statusCode == 200) {
        print('Eliminado con éxito');
      } else {
        print('Error al eliminar. Código de estado: ${resp.statusCode}');
      }
    } catch (error) {
      print('Excepción al eliminar: $error');
    }
  }

  Future<bool> existeFavorito(String UserId, String IdComida) async {
    try {
      final url = Uri.http(_baseUrl, '/api/Cuentas/Favoritos/$UserId');

      final token = await readToken();
      final resp = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (resp.statusCode == 200) {
        final List<dynamic> userDataList = json.decode(resp.body);
        // Verifica si hay algún elemento con el IdMeal específico
        return userDataList.any((userData) => userData['idMeal'] == IdComida);
      } else {
        print('Error al verificar. Código de estado: ${resp.statusCode}');
        return false;
      }
    } catch (error) {
      print('Excepción al verificar: $error');
      return false;
    }
  }

  Future<List<Favorito>> obtenerFavoritos(String UserId) async {
    try {
      final url = Uri.http(_baseUrl, '/api/Cuentas/Favoritos/$UserId');

      final token = await readToken();
      final resp = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print('Respuesta del servidor: ${resp.body}');

      if (resp.statusCode == 200) {
        print(resp.body);

        final List<dynamic> data = json.decode(resp.body);
        // Convertir la lista de mapas a una lista de Favorito
        List<Favorito> favoritos =
            data.map((map) => Favorito.fromJson(map)).toList();
        return favoritos;
      } else {
        print('Error al obtener. Código de estado: ${resp.statusCode}');
        return [];
      }
    } catch (error) {
      print('Excepción al obtener: $error');
      return [];
    }
  }
}
