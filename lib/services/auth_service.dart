import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Serviço de autenticação.
///
/// A senha do usuário NUNCA é salva em disco. Apenas o token de sessão
/// retornado pelo servidor é persistido, dentro do Android Keystore
/// (via flutter_secure_storage), que é criptografado a nível de SO e
/// não é legível por outros apps nem por um dump simples de arquivos.
class AuthService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String baseUrl = 'https://gr8escolar.com.br/api/aluno';

  static const _kToken = 'gr8_token';
  static const _kEscId = 'gr8_escid';
  static const _kEscCod = 'gr8_esccod';
  static const _kEscNome = 'gr8_escnome';
  static const _kLogin = 'gr8_login'; // RA salvo para exibir, não a senha

  /// Faz login com RA/senha/unidade do próprio usuário.
  ///
  /// O app original só pede UM campo "unidade" (código da escola). O
  /// servidor resolve esse código e devolve escid/esccod/escnome na
  /// resposta — só o token e esses dados de retorno são persistidos.
  Future<AuthResult> login({
    required String ra,
    required String senha,
    required String unidade,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/aluno_login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': ra,
          'senha': senha,
          'unidade': unidade,
        }),
      );

      if (resp.statusCode != 200) {
        return AuthResult(
          success: false,
          message:
              'Falha no login (HTTP ${resp.statusCode}). Confira unidade, RA e senha.',
        );
      }

      final data = jsonDecode(resp.body);
      final token = data['api_token'] ?? data['token'];

      if (token == null) {
        return AuthResult(
          success: false,
          message: 'O servidor não retornou os dados do aluno. '
              'Verifique o código da unidade e o login.',
        );
      }

      // Persiste o token e os dados que o servidor devolveu — senha
      // descartada da memória assim que a função retorna.
      await _storage.write(key: _kToken, value: token.toString());
      await _storage.write(key: _kEscId, value: data['escid']?.toString() ?? '');
      await _storage.write(key: _kEscCod, value: data['esccod']?.toString() ?? unidade);
      await _storage.write(key: _kEscNome, value: data['escnome']?.toString() ?? '');
      await _storage.write(key: _kLogin, value: ra);

      return AuthResult(success: true, token: token.toString());
    } catch (e) {
      return AuthResult(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<String?> getStoredToken() => _storage.read(key: _kToken);
  Future<String?> getStoredEscId() => _storage.read(key: _kEscId);
  Future<String?> getStoredEscCod() => _storage.read(key: _kEscCod);
  Future<String?> getStoredEscNome() => _storage.read(key: _kEscNome);
  Future<String?> getStoredLogin() => _storage.read(key: _kLogin);

  Future<bool> hasSession() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}

class AuthResult {
  final bool success;
  final String? token;
  final String? message;

  AuthResult({required this.success, this.token, this.message});
}
