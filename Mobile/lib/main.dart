import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_theme.dart';
import 'package:gaspika_mobile/features/auth/viewmodels/login_viewmodel.dart';
import 'package:gaspika_mobile/utils/router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LoginViewModel())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: AppTheme.theme(context),
      routerConfig: AppRouter.router,
    );
  }
}
