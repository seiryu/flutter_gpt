import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final themeMode = StateNotifierProvider<ThemeModeState, ThemeMode>((_) => ThemeModeState());


class ThemeModeState extends StateNotifier<ThemeMode>{
  ThemeModeState(): super(ThemeMode.light);

  toggle(){
    switch(state){
      case ThemeMode.system:
      case ThemeMode.light:
        state = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        state = ThemeMode.light;
        break;
    }
  }
}