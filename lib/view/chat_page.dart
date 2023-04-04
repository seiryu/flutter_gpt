import 'package:flutter/material.dart';
import 'package:flutter_gpt/util/shared_preferences.dart';
import 'package:flutter_gpt/util/theme_mode.dart';
import 'package:flutter_gpt/view/chat_page_view_model.dart';
import 'package:flutter_gpt/view/openai_apikey_dialog.dart';
import 'package:flutter_gpt/view/settings_page.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


var vm = chatPageViewModel;

class ChatPage extends HookConsumerWidget{
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque, // これを追加！！！
      child: Scaffold(
        appBar: _buildAppBar(context, ref),
        body: Column(
          children: [
            Expanded(
              child: _buildList(context, ref),
            ),
            _buildTextField(context, ref),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref){
    return AppBar(
      title: const Text("Flutter GPT"),
      actions: [
        IconButton(
          onPressed: () => ref.watch(themeMode.notifier).toggle(), 
          icon: Icon(
            ref.watch(themeMode) == ThemeMode.dark
              ? Icons.dark_mode
              : Icons.light_mode
          ),
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              maintainState: false,
              fullscreenDialog: true,
              builder: (_) => const SettingsPage(),
            ),
          ),
          icon: const Icon(Icons.settings),
        ),
        IconButton(
          onPressed: () => ref.watch(vm.notifier).clear(),
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref){
    return SingleChildScrollView(
      reverse: true,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          for(var message in ref.watch(vm).messages) ...{
             _buildListItem(context, ref, message)
          },
          if( ref.watch(vm).isStreaming )
            Container(
              margin: const EdgeInsets.only(top: 8.0),
              alignment: Alignment.center,
              child: const CircularProgressIndicator()
            )
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, WidgetRef ref, CompletionMessage message){
    return Card(
      color: message.role == "assistant"
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.tertiaryContainer,
      margin: const EdgeInsets.all(8),
      semanticContainer: false,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: SelectableText(
                message.role,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 4),
            MarkdownWidget(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              data: message.content,
              config: ref.watch(themeMode) == ThemeMode.dark
                  ? MarkdownConfig.darkConfig
                  : MarkdownConfig.defaultConfig,
            )
          ]
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, WidgetRef ref){
    onSubmit() async {
      if(ref.watch(sharedPrefsRepo).openAiApiKey.isEmpty){
        await showDialog(context: context, builder: (_) => const OpenAiApiKeyDialog());
      }else{
        ref.watch(vm.notifier).onTextSent();
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Material(
        type: MaterialType.card,
        elevation: 1,
        child: TextFormField(
          maxLines: 8,
          minLines: 1,
          autofocus: true,
          textInputAction: TextInputAction.newline,
          keyboardType: TextInputType.multiline,
          controller: ref.watch(vm.notifier).textController,
          onFieldSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(
            enabled: !ref.watch(vm).isStreaming,
            hintText: "Ask me anything",
            border: const OutlineInputBorder(),
            suffix: IconButton(
              onPressed: () => onSubmit(),
              icon: const Icon(Icons.send),
            ),
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16)
          ),
        ),
      )
    );
  }
}