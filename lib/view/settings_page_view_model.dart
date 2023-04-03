import 'package:flutter/material.dart';
import 'package:flutter_gpt/util/openai_chat.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final settingsPageViewModel = StateNotifierProvider.autoDispose<SettingsPageViewModel, SettingsPageState>(
  (ref) => SettingsPageViewModel(ref)
);


class SettingsPageViewModel extends StateNotifier<SettingsPageState>{
  final StateNotifierProviderRef ref;
  late final apiKeyController = TextEditingController(text: ref.watch(openAiChat).apiKey);
  late final sysRoleMsgController = TextEditingController(text: ref.watch(openAiChat).systemMessage);
  late final templetureController = TextEditingController(text: ref.watch(openAiChat).templeture.toString());
  late final maxTokensController = TextEditingController(text: ref.watch(openAiChat).maxTokens.toString());

  

  SettingsPageViewModel(this.ref):super( SettingsPageState() );

  void save(){
    ref.watch(openAiChat.notifier).setConfig(
      apiKey: apiKeyController.text, 
      systemMessage: sysRoleMsgController.text,
      templeture: double.tryParse(templetureController.text),
      maxTokens: int.tryParse(maxTokensController.text),
    );
  }
}

class SettingsPageState{
}