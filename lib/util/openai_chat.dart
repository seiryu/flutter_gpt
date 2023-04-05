import 'package:dart_openai/openai.dart';
import 'package:flutter_gpt/util/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final openAiChat = Provider<OpenAiChat>( (ref) => OpenAiChat(ref) );

class OpenAiChat{
  final ProviderRef ref;

  OpenAiChat(this.ref);


  Stream<OpenAIStreamChatCompletionChoiceDeltaModel> createCompletionStream(
    List<OpenAIChatCompletionChoiceMessageModel> messages
  ){
    final apiKey = ref.read(sharedPrefsRepo).openAiApiKey;
    if(apiKey.isEmpty){
      throw const NoOpenAiApiKeyException();  
    }

    OpenAI.apiKey = apiKey;

    messages.insert(
      0, 
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: ref.read(sharedPrefsRepo).systemMessage
      ),
    );

    var stream = OpenAI.instance.chat.createStream(
      model: "gpt-3.5-turbo", 
      messages: messages,
      temperature: ref.read(sharedPrefsRepo).gptTempleture,
      maxTokens: ref.read(sharedPrefsRepo).maxTokens,
    );

    return stream.map((event) => event.choices.first.delta);
  }
}

class NoOpenAiApiKeyException implements Exception{
  final String msg = "no apikey set";

  const NoOpenAiApiKeyException();

  @override
  String toString() => msg;
}
