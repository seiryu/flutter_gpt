import 'package:dart_openai/openai.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter_gpt/util/openai_chat.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final chatPageViewModel = StateNotifierProvider<ChatPageViewModel, ChatPageState>(
  (ref) => ChatPageViewModel(ref)
);

class ChatPageViewModel extends StateNotifier<ChatPageState>{
  final StateNotifierProviderRef ref;
  final textController = TextEditingController();


  ChatPageViewModel(this.ref) : super( 
    ChatPageState(
      messages: [],
      textFieldtext: "",
      chatListKey: GlobalKey(),
      isStreaming: false,
      hasError: false,
    )
  );

  void onTextFieldChanged(String str){
    state = state.copyWith(
      textFieldtext: str,
    );
  }

  void onTextSent(){
    if(state.isStreaming || state.isTextFieldTextEmpty()) return;

    
    state = state.addMessage(
      CompletionMessage("user", state.textFieldtext)
    );
    state = state.copyWith(isStreaming: true);
    
    var stream = ref.read(openAiChat).createCompletionStream(
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
      state = state.copyWith(messages: []);
    }
  }

  Future<bool> saveChatAsPng() async {
    try{
      final boundary = 
          state.chatListKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png );
      final pngBytes = byteData!.buffer.asUint8List();

      final fileName = "${state.title}.png";
      final String? path = await getSavePath(suggestedName: fileName);
      if (path == null)   return false;

      final xFile = XFile.fromData(pngBytes, mimeType: "image/png");
      await xFile.saveTo(path);

      return true;
    }catch(e){
      print(e);
      return false;
    }
  }
}

class ChatPageState{
  final String title;
  final int messageCount;
  final List<CompletionMessage> messages;
  final bool isStreaming;
  final bool hasError;
  final String textFieldtext;
  final GlobalKey chatListKey;

  ChatPageState({
    required this.messages,
    required this.isStreaming,
    required this.hasError,
    required this.textFieldtext,
    required this.chatListKey,
  }): messageCount = messages.length, 
      title = messages.isEmpty ? "Flutter GPT" : "${messages.first.content.substring(0, 10)}...";

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

  bool isTextFieldTextEmpty(){
    return textFieldtext.trim().isEmpty;
  }

  ChatPageState copyWith({
    List<CompletionMessage>? messages,
    bool? isStreaming,
    bool? hasError,
    String? textFieldtext,
    GlobalKey? chatListKey,
  }){
    return ChatPageState(
      messages: messages ?? [...this.messages],
      isStreaming: isStreaming ?? this.isStreaming,
      hasError: hasError ?? this.hasError,
      textFieldtext: textFieldtext ?? this.textFieldtext,
      chatListKey: chatListKey ?? this.chatListKey,
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