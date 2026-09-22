import 'package:flutter/material.dart';
import '../services/gr8_api_client.dart';
import '../theme/app_theme.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final _api = GR8ApiClient();
  List<dynamic> _itens = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _loading = true);
    try {
      final itens = await _api.minhaAgenda();
      setState(() {
        _itens = itens;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _novoItem() async {
    final controller = TextEditingController();
    final texto = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Novo lembrete'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ex: Estudar pra prova de História'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (texto != null && texto.isNotEmpty) {
      try {
        await _api.minhaAgendaSalvar({'descricao': texto, 'concluido': false});
        _carregar();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Erro ao salvar item.')));
        }
      }
    }
  }

  Future<void> _concluir(String id) async {
    await _api.minhaAgendaConcluir(id);
    _carregar();
  }

  Future<void> _excluir(String id) async {
    await _api.minhaAgendaExcluir(id);
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Agenda')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        onPressed: _novoItem,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _itens.isEmpty
              ? const Center(child: Text('Nenhum lembrete ainda. Toca no + pra criar.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _itens.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final item = _itens[i];
                    final id = item['id']?.toString() ?? '';
                    final concluido = item['concluido'] == true || item['concluido'] == 1;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: concluido,
                          activeColor: AppColors.primary,
                          onChanged: (_) => _concluir(id),
                        ),
                        title: Text(
                          item['descricao']?.toString() ?? '',
                          style: TextStyle(
                            decoration: concluido ? TextDecoration.lineThrough : null,
                            color: concluido ? AppColors.textSecondary : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                          onPressed: () => _excluir(id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
