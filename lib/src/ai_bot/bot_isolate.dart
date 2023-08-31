import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:dfc_gpt/dfc_gpt.dart';
import 'package:dfc_gpt/src/ai_bot/bot_isolate_function.dart';
import 'package:dfc_gpt/src/ai_bot/bot_types.dart';
import 'package:flutter/services.dart';

class BotIsolate {
  BotIsolate({
    required this.config,
    required this.callback,
  });

  final BotConfig config;
  final void Function(BotIsolateResponse response) callback;

  _IsolateHandle? _privIsoHandle;

  Future<_IsolateHandle> get _isolate async {
    return _privIsoHandle ??= await _startIsolate();
  }

  Future<void> send(dynamic message) async {
    final iso = await _isolate;

    iso.sendPort.send(message);
  }

  void dispose() {
    if (_privIsoHandle != null) {
      _privIsoHandle?.sendPort.send(const BotShutdown());

      _privIsoHandle = null;
    }
  }

  // ======================================================
  // private

  Future<_IsolateHandle> _startIsolate() async {
    final sendPortCompleter = Completer<_IsolateHandle>();
    final ReceivePort receivePort = ReceivePort();
    Isolate? isolate;
    StreamSubscription<dynamic>? receivePortSubscription;

    receivePortSubscription = receivePort.listen((dynamic data) {
      if (data is SendPort) {
        sendPortCompleter
            .complete(_IsolateHandle(isolate: isolate!, sendPort: data));
      } else if (data is BotResponse) {
        callback(
          BotIsolateResponse(
            type: 'gpt-response',
            data: data.output,
            fromUser: false,
          ),
        );
      } else if (data is BotIsolateFinished) {
        print('### GptIsolateFinished');
        receivePortSubscription?.cancel();
        // receivePort.close();
        // isolate = null;

        isolate?.kill();
      } else {
        // null comes in on exit?
        print('GptIsolate exit: $data');
      }
    });

    isolate = await _spawn(
      sendPort: receivePort.sendPort,
      config: config,
    );

    return sendPortCompleter.future;
  }

  // this had to be a separate function.
  // it seems that the spawn call was trying to capture
  // local variables for the closure, but it failed with the above Completer.
  static Future<Isolate> _spawn({
    required SendPort sendPort,
    required BotConfig config,
  }) {
    final RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;

    return Isolate.spawn<SendPort>(
      (sendPort) => BotIsolateFunction.isolateStart(
        sendPort,
        rootIsolateToken,
        config,
      ),
      sendPort,
      debugName: 'BotIsolate',
      errorsAreFatal: false,
      onError: sendPort,
      onExit: sendPort,
    );
  }
}

// ==================================================

class _IsolateHandle {
  _IsolateHandle({
    required this.isolate,
    required this.sendPort,
  });

  Isolate isolate;
  SendPort sendPort;
}
