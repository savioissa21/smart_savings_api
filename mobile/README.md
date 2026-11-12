# Smart Savings (Flutter)

Aplicativo Flutter com arquitetura MVVM, Provider e Material 3 para acompanhar metas, registrar depósitos e retiradas e excluir metas.

## Executar

1. Inicie a API Spring Boot na porta `8080`.
2. Na pasta `mobile`, execute:

   ```powershell
   flutter pub get
   flutter run
   ```

Por padrão, o app usa `http://10.0.2.2:8080/api`, endereço do host visto pelo emulador Android. Para outro destino, configure a URL-base ao compilar/executar:

```powershell
flutter run --dart-define=API_BASE_URL=http://localhost:8080/api
```

Use `localhost` no simulador iOS. Em um dispositivo físico, use o endereço IP da máquina que executa a API e mantenha ambos na mesma rede; a API também precisa aceitar conexões pela rede local.

## Estrutura

```text
lib/
  main.dart
  models/
    deposit_model.dart
    goal_model.dart
  services/
    goal_api.dart
  viewmodels/
    goal_viewmodel.dart
  views/
    add_deposit_modal.dart
    add_goal_modal.dart
    goal_list_view.dart
```

Execute `flutter test` e `flutter analyze` para validar o aplicativo.
