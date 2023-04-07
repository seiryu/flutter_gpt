import 'package:file_selector/file_selector.dart';
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
      OpenAiCompletionMessage(role: MessageRole.user, content: state.textFieldtext)
    );

    state = state.copyWith(isStreaming: true);
    final stream = ref.read(openAiChat).createCompletionStream( state.messages );
    int index = state.messages.length;
    stream.listen(
      (delta) => state = state.concatMessageAt( index,  delta ),
      onError: (e) => print(e),
      onDone: () => state = state.copyWith(isStreaming: false),
      cancelOnError: false,
    );
    textController.clear();
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
  final List<OpenAiCompletionMessage> _messages;
  final bool isStreaming;
  final bool hasError;
  final String textFieldtext;
  final GlobalKey chatListKey;

  ChatPageState({
    required List<OpenAiCompletionMessage> messages,
    required this.isStreaming,
    required this.hasError,
    required this.textFieldtext,
    required this.chatListKey,
  }): _messages = [...messages];

  List<OpenAiCompletionMessage> get messages => [..._messages];
  int get messageCount => _messages.length;

  String get title{
    if(_messages.isEmpty) return "チャット";

    final content = _messages.first.content.replaceAll(RegExp(r'\n|\r\n|\r'), " ");
    if(content.length < 10) return content;

    return "${content.substring(0, 10)}...";
  }

  ChatPageState addMessage(OpenAiCompletionMessage msg){
    return copyWith(
      messages: [..._messages, msg ],
    );
  }

  ChatPageState concatMessageAt(int index, OpenAiCompletionMessage msg){
    if(index > messageCount){
      return this;
    }
    if(index == messageCount){
      return addMessage(msg);
    }


    var first = _messages.sublist(0, index);
    var last = _messages.sublist(index + 1);

    return copyWith(
      messages: [...first, _messages[index] + msg, ...last],
    );
  }

  bool isTextFieldTextEmpty(){
    return textFieldtext.trim().isEmpty;
  }

  ChatPageState copyWith({
    List<OpenAiCompletionMessage>? messages,
    bool? isStreaming,
    bool? hasError,
    String? textFieldtext,
    GlobalKey? chatListKey,
  }){
    return ChatPageState(
      messages: messages ?? [..._messages],
      isStreaming: isStreaming ?? this.isStreaming,
      hasError: hasError ?? this.hasError,
      textFieldtext: textFieldtext ?? this.textFieldtext,
      chatListKey: chatListKey ?? this.chatListKey,
    );
  }
}