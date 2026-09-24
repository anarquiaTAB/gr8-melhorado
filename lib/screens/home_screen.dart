import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/gr8_api_client.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'lista_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  late final GR8ApiClient _api;

  List<Map<String, String>> _avisos = [];
  bool _loading = true;
  String? _erro;
  String _login = '';
  String _inst = '';

  @override
  void initState() {
    super.initState();
    _api = GR8ApiClient(_auth);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final login = await _auth.getStoredLogin() ?? '';
      final inst = await _auth.getStoredInst() ?? '';
      final avisos = await _api.avisos();
      setState(() {
        _login = login;
        _inst = inst;
        _avisos = avisos;
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
          child: TextButton(onPressed: _carregarDados, child: const Text('Tentar de novo')),
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
          Container(height: 160, decoration: _skelBox()),
        ],
      ),
    );
  }

  BoxDecoration _skelBox() =>
      BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.white);

  Widget _buildDashboard() {
    final naoLidos = _avisos.where((a) => (a['status'] ?? '').toLowerCase().contains('não')).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _perfilCard(),
        const SizedBox(height: 16),
        _menuTile(
          icon: Icons.campaign_rounded,
          title: 'Avisos',
          subtitle: naoLidos > 0 ? '$naoLidos não lidos' : 'Tudo lido',
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => ListaScreen(titulo: 'Avisos', itens: _avisos))),
        ),
        const SizedBox(height: 10),
        _menuTile(
          icon: Icons.grade_rounded,
          title: 'Boletim',
          subtitle: 'Notas por disciplina',
          onTap: () async {
            final dados = await _api.boletim();
            if (mounted) {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ListaScreen(titulo: 'Boletim', itens: dados)));
            }
          },
        ),
        const SizedBox(height: 10),
        _menuTile(
          icon: Icons.event_busy_rounded,
          title: 'Faltas',
          subtitle: 'Histórico de faltas',
          onTap: () async {
            final dados = await _api.faltas();
            if (mounted) {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ListaScreen(titulo: 'Faltas', itens: dados)));
            }
          },
        ),
        const SizedBox(height: 10),
        _menuTile(
          icon: Icons.schedule_rounded,
          title: 'Horários',
          subtitle: 'Grade de aulas',
          onTap: () async {
            final dados = await _api.horarios();
            if (mounted) {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ListaScreen(titulo: 'Horários', itens: dados)));
            }
          },
        ),
        const SizedBox(height: 10),
        _menuTile(
          icon: Icons.restaurant_rounded,
          title: 'Cardápio',
          subtitle: 'Cardápio da semana',
          onTap: () async {
            final dados = await _api.cardapio();
            if (mounted) {
              Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ListaScreen(titulo: 'Cardápio', itens: dados)));
            }
          },
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
            child: const Icon(Icons.person, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RA $_login', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Instituição $_inst',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
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
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
