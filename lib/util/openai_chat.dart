import 'package:dart_openai/openai.dart';
import 'package:flutter_gpt/util/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final openAiChat = Provider<OpenAiChat>( (ref) => OpenAiChat(ref) );

class OpenAiChat{
  final ProviderRef ref;

  OpenAiChat(this.ref);


  Stream<OpenAiCompletionMessage> createCompletionStream(
    List<OpenAiCompletionMessage> messages
  ){
    final apiKey = ref.read(sharedPrefsRepo).openAiApiKey;
    if(apiKey.isEmpty){
      throw const NoOpenAiApiKeyException();  
    }

    OpenAI.apiKey = apiKey;

    messages.insert(
      0, 
      OpenAiCompletionMessage(
        role: MessageRole.system,
        content: ref.read(sharedPrefsRepo).systemMessage
      ),
    );

    var stream = OpenAI.instance.chat.createStream(
      model: "gpt-3.5-turbo", 
      messages: messages.map( (e) => e.toChoiceMessageModel() ).toList(),
      temperature: ref.read(sharedPrefsRepo).gptTempleture,
      maxTokens: ref.read(sharedPrefsRepo).maxTokens,
    );

    return stream.map( (event) => OpenAiCompletionMessage.fromDelta(event.choices.first.delta) );
  }
}

enum MessageRole{
  user(OpenAIChatMessageRole.user),
  assistant(OpenAIChatMessageRole.assistant),
  system(OpenAIChatMessageRole.system),
  none(OpenAIChatMessageRole.assistant);

  final OpenAIChatMessageRole openAiRole;

  const MessageRole(this.openAiRole);
}

class OpenAiCompletionMessage{
  final MessageRole role;
  final String content;

  OpenAiCompletionMessage({required this.role, required this.content});

  factory OpenAiCompletionMessage.fromDelta(OpenAIStreamChatCompletionChoiceDeltaModel delta){
    MessageRole role;

    switch(delta.role){
      case "user":
        role = MessageRole.user;
        break;
      case "assistant":
        role = MessageRole.assistant;
        break;
      case "system":
        role = MessageRole.system;
        break;
      default:
        role = MessageRole.none;
        break;
    }

    return OpenAiCompletionMessage(role: role, content: delta.content ?? "");
  }

  operator + (OpenAiCompletionMessage msg){
    return OpenAiCompletionMessage(
      role: role == MessageRole.none ? msg.role : role, 
      content: content + msg.content,
    );
  }

  OpenAIChatCompletionChoiceMessageModel toChoiceMessageModel(){
    return OpenAIChatCompletionChoiceMessageModel(
      role: role.openAiRole,
      content: content,
    );
  }
}

class NoOpenAiApiKeyException implements Exception{
  final String msg = "no apikey set";

  const NoOpenAiApiKeyException();

  @override
  String toString() => msg;
}
