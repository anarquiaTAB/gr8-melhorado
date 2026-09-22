import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/aluno.dart';
import '../theme/app_theme.dart';

class FaltasScreen extends StatelessWidget {
  final List<Falta> faltas;
  const FaltasScreen({super.key, required this.faltas});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Faltas')),
      body: faltas.isEmpty
          ? const Center(child: Text('Nenhuma falta registrada. 🎉'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: faltas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final f = faltas[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        f.justificada ? Icons.check_circle_outline : Icons.cancel_outlined,
                        color: f.justificada ? AppColors.primary : AppColors.danger,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.disciplina,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(df.format(f.data),
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(
                        f.justificada ? 'Justificada' : 'Não justif.',
                        style: TextStyle(
                          color: f.justificada ? AppColors.primary : AppColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
