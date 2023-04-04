import 'package:flutter/material.dart';
import 'package:flutter_gpt/util/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OpenAiApiKeyDialog extends HookConsumerWidget{
  const OpenAiApiKeyDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    return AlertDialog(
      title: const Text("API Keyを入力"),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "API Key",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(sharedPrefsRepo.notifier).setConfig(openAiApiKey: controller.text).then(
              (_) => Navigator.of(context).pop()
            );
          }, 
          child: const Text("保存")
        )
      ],
    );
  }

}