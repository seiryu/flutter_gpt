import 'package:flutter/material.dart';
import 'package:flutter_gpt/color_shemes.dart';
import 'package:flutter_gpt/util/shared_preferences.dart';
import 'package:flutter_gpt/view/chat_page.dart';
import 'package:flutter_gpt/view/home_nav_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
   runApp(
    ProviderScope(
      overrides: [
        sharedPrefsRepo.overrideWith(
          (_) => SharedPrefsRepo(prefs: prefs)
        ),
      ],
      child: const MyApp()
    ),
  );

}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ref.watch(sharedPrefsRepo).themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
      debugShowCheckedModeBanner: false,
      // home: const ChatPage(),
      home: const HomeNavPage(),
    );
  }
}
