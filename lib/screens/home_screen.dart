import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/gr8_api_client.dart';
import '../services/auth_service.dart';
import '../models/aluno.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'notas_screen.dart';
import 'faltas_screen.dart';
import 'avisos_screen.dart';
import 'agenda_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = GR8ApiClient();
  final _auth = AuthService();

  Aluno? _aluno;
  List<Nota> _notas = [];
  List<Falta> _faltas = [];
  List<Aviso> _avisos = [];
  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final results = await Future.wait([
        _api.meusDados(),
        _api.notas(),
        _api.faltas(),
        _api.avisos(),
      ]);
      setState(() {
        _aluno = results[0] as Aluno;
        _notas = results[1] as List<Nota>;
        _faltas = results[2] as List<Falta>;
        _avisos = results[3] as List<Aviso>;
        _loading = false;
      });
    } on SessionExpiredException {
      await _auth.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _erro = 'Não deu pra carregar os dados agora.';
      });
    }
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GR8 Melhorado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _carregarDados,
        child: _loading
            ? _buildSkeleton()
            : _erro != null
                ? _buildErro()
                : _buildDashboard(),
      ),
    );
  }

  Widget _buildErro() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.wifi_off_rounded, color: AppColors.textSecondary, size: 48),
        const SizedBox(height: 12),
        Text(_erro!, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _carregarDados,
            child: const Text('Tentar de novo'),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceElevated,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(height: 110, decoration: _skelBox()),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Container(height: 90, decoration: _skelBox())),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 90, decoration: _skelBox())),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 160, decoration: _skelBox()),
        ],
      ),
    );
  }

  BoxDecoration _skelBox() =>
      BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.white);

  Widget _buildDashboard() {
    final mediaGeral = _notas.isEmpty
        ? 0.0
        : _notas.map((n) => n.valor).reduce((a, b) => a + b) / _notas.length;
    final faltasNaoJustificadas = _faltas.where((f) => !f.justificada).length;
    final avisosNaoLidos = _avisos.where((a) => !a.lido).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _perfilCard(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.grade_rounded,
                label: 'Média geral',
                value: mediaGeral.toStringAsFixed(1),
                color: AppColors.primary,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => NotasScreen(notas: _notas))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.event_busy_rounded,
                label: 'Faltas s/ justif.',
                value: '$faltasNaoJustificadas',
                color: faltasNaoJustificadas > 0 ? AppColors.warning : AppColors.primary,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => FaltasScreen(faltas: _faltas))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _menuTile(
          icon: Icons.campaign_rounded,
          title: 'Avisos',
          subtitle: avisosNaoLidos > 0 ? '$avisosNaoLidos não lidos' : 'Tudo lido',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => AvisosScreen(avisos: _avisos))),
        ),
        const SizedBox(height: 10),
        _menuTile(
          icon: Icons.checklist_rounded,
          title: 'Minha Agenda',
          subtitle: 'Tarefas e lembretes pessoais',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const AgendaScreen())),
        ),
      ],
    );
  }

  Widget _perfilCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [AppColors.primaryDark.withOpacity(0.35), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            backgroundImage:
                _aluno?.fotoUrl != null ? NetworkImage(_aluno!.fotoUrl!) : null,
            child: _aluno?.fotoUrl == null
                ? const Icon(Icons.person, color: AppColors.primary, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _aluno?.nome ?? '—',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(_aluno?.turma ?? '',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
