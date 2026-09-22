class Aluno {
  final String nome;
  final String turma;
  final String serie;
  final String? fotoUrl;
  final double? notaDisciplinar;
  final String matricula;
  final String escId;
  final String escCod;

  Aluno({
    required this.nome,
    required this.turma,
    required this.serie,
    this.fotoUrl,
    this.notaDisciplinar,
    required this.matricula,
    required this.escId,
    required this.escCod,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      nome: json['nome'] ?? json['alu_nome'] ?? '',
      turma: json['turma'] ?? '',
      serie: json['serie'] ?? '',
      fotoUrl: json['foto'] ?? json['foto_url'],
      notaDisciplinar: (json['nota_disciplinar'] is num)
          ? (json['nota_disciplinar'] as num).toDouble()
          : null,
      matricula: json['matricula']?.toString() ?? '',
      escId: json['escid']?.toString() ?? '',
      escCod: json['esccod']?.toString() ?? '',
    );
  }
}

class Nota {
  final String disciplina;
  final double valor;
  final String periodo;

  Nota({required this.disciplina, required this.valor, required this.periodo});

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      disciplina: json['disc_desc'] ?? json['disc_sigla'] ?? '',
      valor: (json['valor'] is num) ? (json['valor'] as num).toDouble() : 0.0,
      periodo: json['periodo']?.toString() ?? '',
    );
  }
}

class Falta {
  final DateTime data;
  final String disciplina;
  final bool justificada;

  Falta({required this.data, required this.disciplina, required this.justificada});

  factory Falta.fromJson(Map<String, dynamic> json) {
    return Falta(
      data: DateTime.tryParse(json['data'] ?? '') ?? DateTime.now(),
      disciplina: json['disc_desc'] ?? '',
      justificada: json['justificada'] == true || json['justificada'] == 1,
    );
  }
}

class Aviso {
  final String titulo;
  final String conteudo;
  final DateTime data;
  final bool lido;

  Aviso({
    required this.titulo,
    required this.conteudo,
    required this.data,
    required this.lido,
  });

  factory Aviso.fromJson(Map<String, dynamic> json) {
    return Aviso(
      titulo: json['titulo'] ?? '',
      conteudo: json['conteudo'] ?? json['texto'] ?? '',
      data: DateTime.tryParse(json['data'] ?? '') ?? DateTime.now(),
      lido: json['lido'] == true || json['lido'] == 1,
    );
  }
}
