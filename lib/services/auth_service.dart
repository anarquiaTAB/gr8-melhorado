import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Autenticação real do portal GR8 (ASP clássico).
///
/// O login não devolve token — a sessão é mantida 100% por cookie
/// (ASPSESSIONID...). Por isso usamos um cookie jar persistente em
/// vez de um Bearer token. A senha nunca é salva em disco; só o
/// cookie de sessão persiste, dentro do storage privado do app.
class AuthService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _kLogin = 'gr8_login';
  static const _kInst = 'gr8_inst';

  static const String baseUrl = 'https://alunos.gr8.com.br';
  static const String _origemFixo = 'x&4m3@.f!';

  late Dio dio;
  PersistCookieJar? _cookieJar;

  Future<void> ensureClient() async {
    if (_cookieJar != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(
      storage: FileStorage('${dir.path}/.cookies/'),
    );
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      followRedirects: false,
      validateStatus: (status) => status != null && status < 500,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36',
      },
    ));
    dio.interceptors.add(CookieManager(_cookieJar!));
  }

  Future<AuthResult> login({
    required String ra,
    required String senha,
    required String inst,
  }) async {
    await ensureClient();
    try {
      // GET inicial pra receber o cookie ASPSESSIONID antes do POST.
      await dio.get('/alu_login.asp');

      final resp = await dio.post(
        '/alu_login_exe.asp',
        data: {
          'inst': inst,
          'login': ra,
          'senha': senha,
          'g-recaptcha-response': '',
          'origem': _origemFixo,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'ajax-request': 'POST',
            'Origin': baseUrl,
            'Referer': '$baseUrl/alu_login.asp',
          },
        ),
      );

      final data = resp.data;
      final status = data is Map ? data['status'] : null;

      if (status != 'success') {
        final msg = (data is Map ? data['msg']?.toString() : null);
        return AuthResult(
          success: false,
          message: (msg != null && msg.isNotEmpty)
              ? msg
              : 'Login inválido. Confira instituição, RA e senha.',
        );
      }

      await _secureStorage.write(key: _kLogin, value: ra);
      await _secureStorage.write(key: _kInst, value: inst);

      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(success: false, message: 'Erro de conexão: $e');
    }
  }

  /// Verifica se a sessão salva (cookie) ainda é válida, checando se
  /// uma página autenticada responde 200 em vez de redirecionar pro
  /// login (comportamento confirmado do servidor).
  Future<bool> hasSession() async {
    await ensureClient();
    final login = await _secureStorage.read(key: _kLogin);
    if (login == null) return false;
    try {
      final resp = await dio.get('/alu_default.asp');
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String?> getStoredLogin() => _secureStorage.read(key: _kLogin);
  Future<String?> getStoredInst() => _secureStorage.read(key: _kInst);

  Future<void> logout() async {
    await ensureClient();
    await _cookieJar?.deleteAll();
    await _secureStorage.deleteAll();
  }
}

class AuthResult {
  final bool success;
  final String? message;
  AuthResult({required this.success, this.message});
}
