# 🚀 Quick Start Guide

## Comandos Essenciais

### Setup Inicial
```bash
# Instalar dependências
flutter pub get

# Verificar se está tudo OK
flutter doctor
```

### Durante o Desenvolvimento
```bash
# Executar todos os testes
flutter test

# Executar testes com cobertura
flutter test --coverage

# Executar testes específicos
flutter test test/src/commands/command_test.dart

# Executar todos os testes de uma vez (arquivo especial)
flutter test test/all_tests.dart

# Watch mode (executar testes automaticamente)
flutter test --watch
```

### Análise de Código
```bash
# Analisar código
flutter analyze

# Formatar código
dart format .

# Verificar formatação (sem modificar)
dart format --output=none --set-exit-if-changed .

# Corrigir problemas automaticamente
dart fix --apply
```

### Testar o Exemplo
```bash
# Web
cd example && flutter run -d chrome

# Mobile (Android/iOS)
cd example && flutter run

# Desktop
cd example && flutter run -d macos
cd example && flutter run -d windows
cd example && flutter run -d linux
```

### Preparação para Publicação
```bash
# Simular publicação (dry-run)
flutter pub publish --dry-run

# Verificar score
pana .

# Publicar (após confirmar dry-run)
flutter pub publish
```

### Git & Versioning
```bash
# Commit das mudanças
git add .
git commit -m "feat: add new feature"

# Criar tag de versão
git tag v1.0.0

# Push com tags
git push origin main --tags
```

## 📋 Workflow de Desenvolvimento

### 1. Criar Nova Feature
```bash
# Criar branch
git checkout -b feature/minha-feature

# Desenvolver e testar
flutter test

# Commitar
git commit -am "feat: implementa minha feature"
```

### 2. Antes de Fazer Merge
```bash
# Verificar se tudo está OK
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed .
```

### 3. Publicar Nova Versão
```bash
# 1. Atualizar versão no pubspec.yaml (ex: 1.0.0 -> 1.1.0)
# 2. Atualizar CHANGELOG.md

# 3. Testar
flutter test
flutter pub publish --dry-run

# 4. Commit e tag
git add .
git commit -m "chore: bump version to 1.1.0"
git tag v1.1.0

# 5. Publicar
flutter pub publish
git push origin main --tags
```

## 🧪 Comandos de Teste Avançados

### Cobertura de Testes
```bash
# Gerar cobertura
flutter test --coverage

# Ver cobertura em HTML (requer genhtml)
genhtml coverage/lcov.info -o coverage/html

# Abrir no navegador
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
start coverage/html/index.html  # Windows
```

### Debug de Testes
```bash
# Executar um teste específico em debug
flutter test --name "should execute action" --pause-after-load

# Ver output detalhado
flutter test --reporter=expanded

# Executar testes com verbosidade
flutter test --verbose
```

## 🔧 Troubleshooting

### Problemas com Dependências
```bash
# Limpar cache
flutter clean
flutter pub get

# Atualizar dependências
flutter pub upgrade

# Verificar dependências desatualizadas
flutter pub outdated
```

### Problemas com Testes
```bash
# Limpar e rodar testes novamente
flutter clean
flutter pub get
flutter test

# Verificar se algum arquivo está mal formatado
dart format --set-exit-if-changed lib/ test/
```

### Problemas com Análise
```bash
# Ver detalhes dos problemas
flutter analyze --verbose

# Ignorar warnings específicos (não recomendado)
flutter analyze --no-fatal-warnings
```

## 📦 Comandos do Pub

### Informações do Pacote
```bash
# Ver informações
flutter pub deps

# Ver dependências em árvore
flutter pub deps --style=tree

# Ver dependências desatualizadas
flutter pub outdated
```

### Publicação
```bash
# Verificar antes de publicar
flutter pub publish --dry-run

# Publicar
flutter pub publish

# Publicar versão específica
flutter pub publish --tag=beta
```

## 🎯 Scripts Úteis

### Criar arquivo de script (opcional)

**scripts/test_all.sh** (Linux/macOS)
```bash
#!/bin/bash
set -e

echo "🧹 Cleaning..."
flutter clean
flutter pub get

echo "🔍 Analyzing..."
flutter analyze

echo "✨ Formatting..."
dart format --set-exit-if-changed .

echo "🧪 Testing..."
flutter test --coverage

echo "✅ All checks passed!"
```

**scripts/test_all.bat** (Windows)
```batch
@echo off
echo 🧹 Cleaning...
flutter clean
flutter pub get

echo 🔍 Analyzing...
flutter analyze

echo ✨ Formatting...
dart format --set-exit-if-changed .

echo 🧪 Testing...
flutter test --coverage

echo ✅ All checks passed!
```

Tornar executável:
```bash
chmod +x scripts/test_all.sh
./scripts/test_all.sh
```

## 🌟 Dicas Pro

1. **Use o VSCode/Android Studio**: Configure os plugins do Flutter/Dart
2. **Atalhos úteis no VSCode**:
   - `Cmd+Shift+P` / `Ctrl+Shift+P`: Command Palette
   - Digite "Flutter: Run Flutter Tests" para rodar testes
3. **Hot Reload**: Use `r` ao executar o app
4. **Hot Restart**: Use `R` ao executar o app
5. **GitHub Actions**: Já configurado em `.github/workflows/test.yml`

## 📚 Documentação Adicional

- [Documentação do Flutter](https://flutter.dev/docs)
- [Pub.dev Guidelines](https://dart.dev/tools/pub/publishing)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Testing Flutter Apps](https://flutter.dev/docs/testing)

---

**Pronto para começar! 🚀**