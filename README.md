# GR8 Melhorado

Cliente pessoal do GR8 Agenda Escolar, feito em Flutter, com dark mode
customizado e autologin seguro.

## O que é

Este app usa **sua própria conta** (RA/senha) para acessar as mesmas
APIs do app oficial GR8, mas com uma interface própria, dashboard
unificado e tema escuro.

Segurança:
- A senha nunca é salva em disco — só o token de sessão retornado
  pelo servidor, guardado no Android Keystore via `flutter_secure_storage`.
- Sem hardcode de credenciais de terceiros.
- Sem varredura de dados de outros alunos.

## Rodando localmente

```bash
flutter pub get
flutter run
```

## Gerando o APK manualmente

```bash
flutter build apk --release
# APK gerado em: build/app/outputs/flutter-apk/app-release.apk
```

## Build automática via GitHub Actions

O workflow em `.github/workflows/build-apk.yml` builda o APK
automaticamente a cada push na branch `main`, e disponibiliza:

1. Como **artefato do workflow** (aba Actions → seu run → Artifacts)
2. Como **release automática** (aba Releases do repositório)

### Como usar

1. Cria um repositório novo no GitHub
2. Sobe este projeto:
   ```bash
   git init
   git add .
   git commit -m "GR8 Melhorado inicial"
   git branch -M main
   git remote add origin https://github.com/SEU_USUARIO/gr8-melhorado.git
   git push -u origin main
   ```
3. Vai em **Actions** no repositório — a build inicia sozinha
4. Quando terminar (uns 3-5 min), baixa o APK em **Releases** ou em
   **Actions → run mais recente → Artifacts**

### Rodar manualmente sem dar push

Aba **Actions** → **Build APK** → **Run workflow**.

## Assinatura para produção

Por padrão o build usa a chave de debug (funciona pra instalar no seu
próprio celular sem problema). Se quiser assinar com uma keystore
própria pra distribuir de forma mais séria, gera uma keystore e
adiciona os secrets `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`,
`KEY_ALIAS`, `KEY_PASSWORD` no repositório — me chama que eu ajusto o
`build.gradle` e o workflow pra usar isso.
