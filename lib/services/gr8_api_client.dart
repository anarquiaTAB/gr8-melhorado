import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/aluno.dart';

/// Cliente para as rotas autenticadas do GR8. Todas as chamadas usam
/// o token de sessão do próprio usuário logado — sem hardcode de
/// credenciais de terceiros, sem varredura de IDs de outros alunos.
class GR8ApiClient {
  static const String baseUrl = 'https://gr8escolar.com.br/api/aluno';
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getStoredToken();
    if (token == null) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _get(String path) async {
    final headers = await _headers();
    final resp = await http.get(Uri.parse('$baseUrl/$path'), headers: headers);
    if (resp.statusCode == 401) {
      throw SessionExpiredException();
    }
    if (resp.statusCode != 200) {
      throw Exception('Erro ${resp.statusCode} ao buscar $path');
    }
    return jsonDecode(resp.body);
  }

  Future<Aluno> meusDados() async {
    final json = await _get('meusdados');
    return Aluno.fromJson(json is List ? json.first : json);
  }

  Future<List<Nota>> notas() async {
    final json = await _get('notas');
    final list = (json is List) ? json : (json['notas'] ?? []);
    return list.map<Nota>((e) => Nota.fromJson(e)).toList();
  }

  Future<List<Falta>> faltas() async {
    final json = await _get('faltas');
    final list = (json is List) ? json : (json['faltas'] ?? []);
    return list.map<Falta>((e) => Falta.fromJson(e)).toList();
  }

  Future<List<Aviso>> avisos() async {
    final json = await _get('avisos2');
    final list = (json is List) ? json : (json['avisos'] ?? []);
    return list.map<Aviso>((e) => Aviso.fromJson(e)).toList();
  }

  Future<List<dynamic>> horarios() async {
    final json = await _get('horarios');
    return (json is List) ? json : (json['horarios'] ?? []);
  }

  Future<List<dynamic>> cardapio() async {
    final json = await _get('cardapio');
    return (json is List) ? json : (json['cardapio'] ?? []);
  }

  Future<List<dynamic>> minhaAgenda() async {
    final json = await _get('minha_agenda');
    return (json is List) ? json : (json['agenda'] ?? []);
  }

  Future<void> minhaAgendaSalvar(Map<String, dynamic> item) async {
    final headers = await _headers();
    final resp = await http.post(
      Uri.parse('$baseUrl/minha_agenda_salvar'),
      headers: headers,
      body: jsonEncode(item),
    );
    if (resp.statusCode == 401) throw SessionExpiredException();
    if (resp.statusCode != 200) {
      throw Exception('Erro ao salvar item da agenda');
    }
  }

  Future<void> minhaAgendaConcluir(String id) async {
    final headers = await _headers();
    final resp = await http.post(
      Uri.parse('$baseUrl/minha_agenda_concluir'),
      headers: headers,
      body: jsonEncode({'id': id}),
    );
    if (resp.statusCode == 401) throw SessionExpiredException();
  }

  Future<void> minhaAgendaExcluir(String id) async {
    final headers = await _headers();
    final resp = await http.post(
      Uri.parse('$baseUrl/minha_agenda_excluir'),
      headers: headers,
      body: jsonEncode({'id': id}),
    );
    if (resp.statusCode == 401) throw SessionExpiredException();
  }

  Future<List<dynamic>> ocorrencias() async {
    final json = await _get('ocorrencias');
    return (json is List) ? json : (json['ocorrencias'] ?? []);
  }

  Future<List<dynamic>> parcelas() async {
    final json = await _get('parcelas');
    return (json is List) ? json : (json['parcelas'] ?? []);
  }
}

class SessionExpiredException implements Exception {
  final String message = 'Sessão expirada';
}
