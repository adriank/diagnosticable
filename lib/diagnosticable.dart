library diagnosticable;

import 'dart:developer';
import 'package:diagnosticable/colorify.dart';
import 'package:flutter/foundation.dart';

enum DebugLevel {
  debug,
  info,
  success,
  warning,
  error,
  off,
}

@immutable
class Diagnosticable {
  final DebugLevel debugLevel;
  final bool showTimestamps;
  final int? cutAfter;
  final bool multiline;
  final bool showDebugLevel;

  /// Used to distinguish between different loggers
  final String? scope;

  /// This can be useful on web where no debug symbols from Flutter are available as of now.
  final bool forceDebugMessages;

  const Diagnosticable({
    this.debugLevel = DebugLevel.error,
    this.cutAfter = 800,
    this.showTimestamps = true,
    this.multiline = !kIsWeb,
    this.showDebugLevel = false,
    this.scope,
    this.forceDebugMessages = false,
  });

  get className => runtimeType.toString();

  void _print(String message, {DebugLevel level = DebugLevel.debug}) {
    if (shouldPrintDebug(level)) {
      final List<String> toShow = [
        if (scope != null) '[${scope!}]',
      ];
      if (showTimestamps) {
        toShow.add(DateTime.now().toString().split(' ')[1]); //.split('.')[0]);
      }
      try {
        throw Exception();
      } catch (e, s) {
        if (kIsWeb) {
          print(e);
          print(s);
          // TODO maybe implement function name + line on web
        } else {
          final trace = _CustomTrace.fromStackTrace(s).currentCall;
          toShow.add('${trace.functionName}:${trace.lineNumber}');
        }
      }
      final shouldCut = cutAfter != null ? cutAfter! < message.length : false;
      Function colorify = white;
      String levelString = 'DBG';
      switch (level) {
        case DebugLevel.debug:
          colorify = blue;
          levelString = 'DBG';
          break;
        case DebugLevel.info:
          colorify = white;
          levelString = 'INF';
          break;
        case DebugLevel.success:
          colorify = green;
          levelString = 'SCC';
          break;
        case DebugLevel.warning:
          colorify = yellow;
          levelString = 'WRN';
          break;
        case DebugLevel.error:
          colorify = red;
          levelString = 'ERR';
          break;
        case DebugLevel.off:
      }
      final n = multiline ? '\n' : ' ';
      final printDebugLevel = showDebugLevel ? '[$levelString] ' : '';
      final toPrint = ((shouldCut ? '${message.substring(0, cutAfter)}...(cut)' : '  $message')).trim();
      if (!kDebugMode) {
        print('${toShow.join(' ')}:$n$printDebugLevel$toPrint');
      } else {
        log(
          colorify('${toShow.join(' ')}:$n$printDebugLevel$toPrint'),
          level: 2000,
          name: levelString,
        );
      }
    }
  }

  printStart([List<dynamic>? args]) => _print('args: ${args?.map((e) => e.toString()).join(', ') ?? '(no arguments)'}', level: DebugLevel.info);
  printDebug(String message) => _print(message, level: DebugLevel.debug);
  printInfo(String message) => _print(message, level: DebugLevel.info);
  printSuccess(String message) => _print(message, level: DebugLevel.success);
  printError(String message) => _print(message, level: DebugLevel.error);
  printWarning(String message) => _print(message, level: DebugLevel.warning);

  bool shouldPrintDebug(DebugLevel level) => forceDebugMessages || kDebugMode && DebugLevel.values.indexOf(level) >= DebugLevel.values.indexOf(debugLevel);
}

class _Frame {
  _Frame({
    required this.fileName,
    required this.functionName,
    required this.columnNumber,
    required this.lineNumber,
  });
  late String fileName;
  late String functionName;
  late int lineNumber;
  late int columnNumber;
}

class _CustomTrace {
  _Frame currentCall;
  _Frame? previousCall;

  _CustomTrace({required this.currentCall, this.previousCall});

  factory _CustomTrace.fromStackTrace(StackTrace trace) {
    final frames = trace.toString().split('\n');
    return _CustomTrace(
      currentCall: _readFrame(frames[2]),
      previousCall: (frames.length >= 3) ? _readFrame(frames[3]) : null,
    );
  }

  static _Frame _readFrame(String frame) {
    if (frame == '<asynchronous suspension>') {
      return _Frame(
        fileName: '?',
        lineNumber: 0,
        functionName: '?',
        columnNumber: 0,
      );
    }
    final parts = frame.replaceAll(r'<anonymous closure>', 'anonymous').replaceAll(r'<anonymous, closure>', 'anonymous').split(' ').where((element) => element.isNotEmpty && element != 'new').toList();
    List<String> listOfInfos = ['', '', '0', '0'];
    try {
      listOfInfos = parts[2].split(':');
    } catch (_) {}
    return _Frame(
      fileName: listOfInfos[1],
      lineNumber: int.parse(listOfInfos[2]),
      functionName: parts[1].split('.anony')[0].split('(')[0],
      columnNumber: int.parse(listOfInfos[3].replaceFirst(')', '')),
    );
  }
}
