import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'auth_service.dart';

/// Cliente das páginas autenticadas do portal GR8. Como o backend é
/// ASP clássico, cada "endpoint" devolve HTML — fazemos parsing das
/// tabelas com o pacote `html`. A sessão (cookie) é gerenciada pelo
/// AuthService/Dio compartilhado.
class GR8ApiClient {
  final AuthService _auth;
  GR8ApiClient(this._auth);

  Future<Dio> _client() async {
    await _auth.ensureClient();
    return _auth.dio;
  }

  Future<html_dom.Document> _getPage(String path) async {
    final dio = await _client();
    final resp = await dio.get(path);
    if (resp.statusCode == 302 || resp.statusCode == 401) {
      throw SessionExpiredException();
    }
    return html_parser.parse(resp.data.toString());
  }

  /// Avisos da escola/professor — extrai linhas da tabela de avisos.
  Future<List<Map<String, String>>> avisos() async {
    final doc = await _getPage('/alu_avisos.asp');
    final linhas = doc.querySelectorAll('table tr');
    final resultado = <Map<String, String>>[];

    for (final linha in linhas.skip(1)) {
      final celulas = linha.querySelectorAll('td');
      if (celulas.length < 3) continue;
      resultado.add({
        'assunto': celulas[0].text.trim(),
        'enviado_em': celulas.length > 1 ? celulas[1].text.trim() : '',
        'status': celulas.length > 2 ? celulas.last.text.trim() : '',
      });
    }
    return resultado;
  }

  Future<List<Map<String, String>>> faltas() async {
    final doc = await _getPage('/alu_faltas.asp');
    return _extrairTabela(doc);
  }

  Future<List<Map<String, String>>> boletim() async {
    // A página de boletim com dados reais é alu_boletim2.asp
    // (alu_boletim.asp sozinha retorna 500 — precisa de parâmetros
    // de etapa/turma que o portal define via sessão).
    final doc = await _getPage('/alu_boletim2.asp');
    return _extrairTabela(doc);
  }

  Future<List<Map<String, String>>> horarios() async {
    final doc = await _getPage('/alu_horarios.asp');
    return _extrairTabela(doc);
  }

  Future<List<Map<String, String>>> cardapio() async {
    final doc = await _getPage('/alu_cardapio.asp');
    return _extrairTabela(doc);
  }

  List<Map<String, String>> _extrairTabela(html_dom.Document doc) {
    final linhas = doc.querySelectorAll('table tr');
    if (linhas.isEmpty) return [];

    final cabecalho =
        linhas.first.querySelectorAll('th, td').map((e) => e.text.trim()).toList();

    final resultado = <Map<String, String>>[];
    for (final linha in linhas.skip(1)) {
      final celulas = linha.querySelectorAll('td');
      if (celulas.isEmpty) continue;
      final mapa = <String, String>{};
      for (var i = 0; i < celulas.length; i++) {
        final chave = i < cabecalho.length ? cabecalho[i] : 'col$i';
        mapa[chave] = celulas[i].text.trim();
      }
      resultado.add(mapa);
    }
    return resultado;
  }
}

class SessionExpiredException implements Exception {
  final String message = 'Sessão expirada';
}
