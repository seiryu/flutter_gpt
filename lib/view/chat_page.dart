import 'package:flutter/material.dart';
import 'package:flutter_gpt/util/openai_chat.dart';
import 'package:flutter_gpt/util/shared_preferences.dart';
import 'package:flutter_gpt/view/chat_page_view_model.dart';
import 'package:flutter_gpt/view/openai_apikey_dialog.dart';
import 'package:flutter_gpt/view/settings_page.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


var vm = chatPageViewModel;

class ChatPage extends HookConsumerWidget{
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: Column(
        children: [
          Expanded(
            child: _buildList(context, ref),
          ),
          _buildTextField(context, ref),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref){
    return AppBar(
      title: const Text("Flutter GPT"),
      actions: [
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
      child: ListView(
        shrinkWrap: true,
        children: ref.watch(vm).messages.map(
          (message) => _buildListItem(context, message)
        ).toList(),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, CompletionMessage message){
    return Card(
      elevation: message.role == "assistant" ? 0 : null,
      shape: message.role == "assistant" 
        ? RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        )
        : null,
      margin: const EdgeInsets.all(8),
      semanticContainer: false,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SelectableText(
              message.role,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            MarkdownBody(
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(textScaleFactor: 1.1),
              data: message.content,
              selectable: true,
            ),
          ]
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, WidgetRef ref){
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        maxLines: 5,
        minLines: 1,
        controller: ref.watch(vm.notifier).textController,
        onFieldSubmitted: (_) => ref.watch(vm.notifier).onTextSent(),
        decoration: InputDecoration(
          hintText: "Ask me anything",
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            onPressed: () async {
              if(ref.watch(sharedPrefsRepo).openAiApiKey.isEmpty){
                await showDialog(context: context, builder: (_) => const OpenAiApiKeyDialog());
              }else{
                ref.watch(vm.notifier).onTextSent();
              }
            },
            icon: const Icon(Icons.send),
          ),
        ),
      ),
    );
  }
}