import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:snow_app/spalsh_screen.dart';
import 'package:snow_app/core/global_navigator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await dotenv.load(fileName: '.env');
  print('✅ ✅ ✅ ✅  BASE URL: ${dotenv.env['BASE_URL']}'); 

  runApp(const SnowApp());
}

class SnowApp extends StatelessWidget {
  const SnowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      navigatorKey: GlobalNavigator.navigatorKey, // 🔥 THIS LINE

      home: const SplashScreen(),
    );
  }
}