import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tela genérica pra qualquer dado vindo como tabela HTML do portal
/// (avisos, boletim, faltas, horários, cardápio) — cada item é um
/// Map<String,String> com as colunas originais da tabela.
class ListaScreen extends StatelessWidget {
  final String titulo;
  final List<Map<String, String>> itens;

  const ListaScreen({super.key, required this.titulo, required this.itens});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: itens.isEmpty
          ? const Center(child: Text('Nada por aqui ainda.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: itens.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = itens[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item.entries
                        .where((e) => e.value.trim().isNotEmpty)
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                                  children: [
                                    TextSpan(
                                      text: '${e.key}: ',
                                      style: const TextStyle(
                                          color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(text: e.value),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
    );
  }
}
