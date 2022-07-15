// ignore_for_file: library_private_types_in_public_api

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

class Diagnosticable {
  DebugLevel debugLevel;
  bool showTimestamps;
  int? cutAfter;

  Diagnosticable({
    this.debugLevel = DebugLevel.error,
    this.cutAfter = 800,
    this.showTimestamps = true,
  });

  get className {
    return runtimeType.toString();
  }

  void _print(String message, {DebugLevel level = DebugLevel.debug}) {
    if (shouldPrintDebug(level)) {
      final List<String> toShow = [];
      if (showTimestamps) {
        toShow.add(DateTime.now().toString().split(' ')[1]); //.split('.')[0]);
      }
      try {
        throw Exception();
      } catch (e, s) {
        final trace = CustomTrace.fromStackTrace(s).currentCall;
        toShow.add('${trace.functionName}:${trace.lineNumber}');
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
      log(
        colorify('${toShow.join(' ')}:\n${(shouldCut ? '${message.substring(0, cutAfter)}...(cut)' : '  $message')}'),
        level: 2000,
        name: levelString,
      );
    }
  }

  printStart([List<dynamic>? args]) => _print('[START] args: ${args?.map((e) => e.toString()).join(', ') ?? '(no arguments)'}', level: DebugLevel.info);
  printDebug(String message) => _print('[DBG] $message', level: DebugLevel.debug);
  printInfo(String message) => _print('[INF] $message', level: DebugLevel.info);
  printSuccess(String message) => _print('[SCC] $message', level: DebugLevel.success);
  printError(String message) => _print('[ERR] $message', level: DebugLevel.error);
  printWarning(String message) => _print('[WRN] $message', level: DebugLevel.warning);

  bool shouldPrintDebug(DebugLevel level) => kDebugMode && DebugLevel.values.indexOf(level) >= DebugLevel.values.indexOf(debugLevel);
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

class CustomTrace {
  _Frame currentCall;
  _Frame? previousCall;

  CustomTrace({required this.currentCall, this.previousCall});

  factory CustomTrace.fromStackTrace(StackTrace trace) {
    final frames = trace.toString().split('\n');
    return CustomTrace(
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
