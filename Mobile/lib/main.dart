import 'package:flutter/material.dart';
import 'package:gaspika_mobile/configs/app_router.dart';
import 'package:gaspika_mobile/configs/app_theme.dart';
import 'package:gaspika_mobile/configs/dotenv_config.dart';
import 'package:gaspika_mobile/features/auth/viewmodels/login_viewmodel.dart';
import 'package:gaspika_mobile/features/auth/viewmodels/register_viewmodel.dart';
import 'package:gaspika_mobile/features/create_shopping_item/viewmodels/create_shopping_item_viewmodel.dart';
import 'package:gaspika_mobile/features/food_details/viewmodels/food_details_viewmodel.dart';
import 'package:gaspika_mobile/features/home/viewmodels/home_viewmodel.dart';
import 'package:gaspika_mobile/features/shopping_list/viewmodels/shopping_list_viewmodel.dart';
import 'package:gaspika_mobile/features/shopping_list_items/viewmodels/shopping_list_items_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  await DotenvConfig.initDotenv();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ShoppingListViewModel()),
        ChangeNotifierProvider(create: (_) => ShoppingItemsViewModel()),
        ChangeNotifierProvider(create: (_) => FoodDetailsViewmodel()),
        ChangeNotifierProvider(create: (_) => CreateShoppingItemViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      locale: const Locale('fr'),

      supportedLocales: const [Locale('fr'), Locale('en')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      title: 'Flutter Demo',
      theme: AppTheme.theme(context),
      routerConfig: AppRouter.router,
    );
  }
}
