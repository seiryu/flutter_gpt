import 'package:dart_openai/openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gpt/util/openai_chat.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final chatPageViewModel = StateNotifierProvider<ChatPageViewModel, ChatPageState>(
  (ref) => ChatPageViewModel(ref)
);

class ChatPageViewModel extends StateNotifier<ChatPageState>{
  final StateNotifierProviderRef ref;
  final textController = TextEditingController();


  ChatPageViewModel(this.ref) : super( ChatPageState() );


  void onTextSent(){
    if(state.isStreaming || textController.text.isEmpty) return;


    state = state.addMessage(
      CompletionMessage("user", textController.text)
    );
    state = state.copyWith(isStreaming: true);
    
    var stream = ref.watch(openAiChat.notifier).createCompletionStream(
      state.messages.map(
        (e) => OpenAIChatCompletionChoiceMessageModel(
          role: e.role == "user" ? OpenAIChatMessageRole.user : OpenAIChatMessageRole.assistant, 
          content: e.content
        )
      ).toList()
    );

    int index = state.messages.length;
    stream.listen(
      (delta) {
        state = state.concatMessageAt(
          index,
          CompletionMessage(
            delta.role ?? "no role",
            delta.content ?? ""
          )
        );
      },
      onError: (e) => print(e),
      onDone: () => state = state.copyWith(isStreaming: false),
      cancelOnError: false,
    );
    textController.text = "";
  }

  void clear(){
    if(!state.isStreaming){
      state = ChatPageState(messages: [], isStreaming: false);
    }

  }
}

class ChatPageState{
  final int messageCount;
  final List<CompletionMessage> messages;
  final bool isStreaming;
  final bool hasError;

  ChatPageState({
    this.messages = const [],
    this.isStreaming = false,
    this.hasError = false,
  }): messageCount = messages.length;

  ChatPageState addMessage(CompletionMessage msg){
    return copyWith(
      messages: [...messages, msg ],
    );
  }

  ChatPageState concatMessageAt(int index, CompletionMessage msg){
    if(index > messageCount){
      return this;
    }

    if(index == messageCount){
      return addMessage(msg);
    }


    var first = messages.sublist(0, index);
    var last = messages.sublist(index + 1);

    return copyWith(
      messages: [...first, messages[index].concat(msg.content), ...last],
    );
  }

  ChatPageState copyWith( { List<CompletionMessage>? messages, bool? isStreaming }){
    return ChatPageState(
      messages: messages ?? [...this.messages],
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

class CompletionMessage{
  final String role;
  final String content;

  CompletionMessage(this.role, this.content);

  CompletionMessage concat(String content){
    return CompletionMessage(
      role, 
      this.content + content,
    );
  }
}