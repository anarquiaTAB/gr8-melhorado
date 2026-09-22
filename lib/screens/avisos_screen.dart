import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/aluno.dart';
import '../theme/app_theme.dart';

class AvisosScreen extends StatelessWidget {
  final List<Aviso> avisos;
  const AvisosScreen({super.key, required this.avisos});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Avisos')),
      body: avisos.isEmpty
          ? const Center(child: Text('Nenhum aviso no momento.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: avisos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final a = avisos[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: a.lido ? AppColors.divider : AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!a.lido)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(a.titulo,
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(a.conteudo, style: const TextStyle(fontSize: 13.5)),
                      const SizedBox(height: 8),
                      Text(df.format(a.data),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
