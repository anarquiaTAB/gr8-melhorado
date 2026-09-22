import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _raCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _escIdCtrl = TextEditingController();
  final _escCodCtrl = TextEditingController();

  bool _loading = false;
  bool _checandoSessao = true;
  String? _erro;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _tentarAutologin();
  }

  Future<void> _tentarAutologin() async {
    final temSessao = await _auth.hasSession();
    if (temSessao && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }
    setState(() => _checandoSessao = false);
  }

  Future<void> _fazerLogin() async {
    if (_raCtrl.text.trim().isEmpty || _senhaCtrl.text.isEmpty) {
      setState(() => _erro = 'Preenche RA e senha, boss.');
      return;
    }

    setState(() {
      _loading = true;
      _erro = null;
    });

    final result = await _auth.login(
      ra: _raCtrl.text.trim(),
      senha: _senhaCtrl.text,
      escId: _escIdCtrl.text.trim(),
      escCod: _escCodCtrl.text.trim(),
    );

    if (!mounted) return;

    if (result.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        _loading = false;
        _erro = result.message ?? 'Erro ao fazer login';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checandoSessao) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: AppColors.primary, size: 44),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'GR8 Melhorado',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sua agenda escolar, do seu jeito',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 36),
                  TextField(
                    controller: _raCtrl,
                    decoration: const InputDecoration(
                      hintText: 'RA (matrícula)',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _senhaCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _escIdCtrl,
                          decoration: const InputDecoration(hintText: 'ID Escola'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _escCodCtrl,
                          decoration: const InputDecoration(hintText: 'Cód. Escola'),
                        ),
                      ),
                    ],
                  ),
                  if (_erro != null) ...[
                    const SizedBox(height: 12),
                    Text(_erro!,
                        style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _fazerLogin,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : const Text('Entrar'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seu login fica salvo com criptografia no seu\ncelular. A senha nunca é armazenada.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
