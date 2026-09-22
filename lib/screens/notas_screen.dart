import 'package:flutter/material.dart';
import '../models/aluno.dart';
import '../theme/app_theme.dart';

class NotasScreen extends StatelessWidget {
  final List<Nota> notas;
  const NotasScreen({super.key, required this.notas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notas')),
      body: notas.isEmpty
          ? const Center(child: Text('Nenhuma nota disponível ainda.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final n = notas[i];
                final cor = n.valor >= 6
                    ? AppColors.primary
                    : (n.valor >= 4 ? AppColors.warning : AppColors.danger);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.disciplina,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(n.periodo,
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          n.valor.toStringAsFixed(1),
                          style: TextStyle(color: cor, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
