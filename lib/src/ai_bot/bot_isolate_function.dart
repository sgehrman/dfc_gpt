import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:dfc_gpt/dfc_gpt.dart';
import 'package:dfc_gpt/src/ai_bot/bot_types.dart';
import 'package:dfc_gpt/src/ai_lib/llmodel.dart';
import 'package:dfc_gpt/src/ai_lib/llmodel_library.dart';
import 'package:flutter/services.dart';

// ==================================================
// this runs inside the isolate

class BotIsolateFunction {
  BotIsolateFunction._();

  static void isolateStart(
    SendPort sendPort,
    RootIsolateToken rootToken,
    String librarySearchPath,
    LLModelPromptConfig? promptConfig,
  ) {
    // errors happen without this
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);

    // see https://github.com/flutter/flutter/issues/99155
    // something to do with the path_provider package
    DartPluginRegistrant.ensureInitialized();

    StreamSubscription<dynamic>? receivePortSubscription;
    final ReceivePort receivePort = ReceivePort();

    BotRequestHandler? requestHandler = BotRequestHandler(
      librarySearchPath: librarySearchPath,
      promptConfig: promptConfig,
      callback: (output) {
        final BotResponse response = BotResponse(output: output);
        sendPort.send(response);
      },
    );

    receivePortSubscription = receivePort.listen((dynamic data) {
      if (data is BotRequest) {
        requestHandler?.askQuestion(data);
      } else if (data is BotShutdown) {
        // this should trigger the shutdownCallback above
        // requestHandler?.dispose();
        requestHandler = null;

        receivePortSubscription?.cancel();
        // receivePort.close();
      } else {
        print('bot isolate function: $data');
      }
    });

    sendPort.send(receivePort.sendPort);
  }
}

// ==================================================

class BotRequestHandler {
  BotRequestHandler({
    required this.librarySearchPath,
    required this.callback,
    this.promptConfig,
  });

  final String librarySearchPath;
  final LLModelPromptConfig? promptConfig;

  final void Function(String results) callback;
  LLModel? _model;

  Future<void> updateModel(String modelPath) async {
    try {
      if (_model != null) {
        // shut down old model gracefully
        await LLModelLibrary.shared.shutdownGracefully();

        // now we can safely dispose the old model
        _model?.dispose();
      }

      _model = LLModel(
        modelPath: modelPath,
        responseCallback: (tokenId, response) {
          callback(response);
        },
      );

      await _model!.load(
        librarySearchPath: librarySearchPath,
        promptConfig: promptConfig,
      );
    } catch (err) {
      print('BotRequestHandler error: $err');
    }
  }

  Future<void> askQuestion(BotRequest request) async {
    if (_model == null || _model!.modelPath != request.modelPath) {
      // need to rebuild with new model first
      await updateModel(request.modelPath);
    } else {
      // interrupt any message still being answered
      await LLModelLibrary.shared.shutdownGracefully();
    }

    _model?.generate(
      prompt: request.question,
    );
  }
}
