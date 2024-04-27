import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:example/src/function/byte_array.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:isolate_transformer/isolate_transformer.dart';
import 'package:stream_taker/stream_taker.dart';

class ByteArrayMergeView extends StatefulWidget {
  const ByteArrayMergeView(this.currentFile, {super.key});

  final PlatformFile currentFile;
  static const routeName = '/byte_array_merge';

  @override
  State<ByteArrayMergeView> createState() => _ByteArrayMergeViewState();
}

class _ByteArrayMergeViewState extends State<ByteArrayMergeView> {
  late StreamController<Uint8List> inputController;
  late StreamTaker<Uint8List> fileReadStreamSplit;
  final outputController = StreamController<Uint8List>();
  final isolateTransformer = IsolateTransformer();
  var count = 1;
  var waitingCount = 0;

  @override
  void initState() {
    super.initState();
    initIsolate();
  }

  void initIsolate() {
    inputController = StreamController();
    fileReadStreamSplit = StreamTaker(widget.currentFile.readStream!.map(
        (event) => event is Uint8List ? event : Uint8List.fromList(event)));
    isolateTransformer
        .transform(inputController.stream, byteArrayMergeTransform,
            workerName: 'byteArrayMergeTransform')
        .listen((event) {
      final receiveTime = DateTime.now().microsecondsSinceEpoch;
      debugPrint("receiveTime: $receiveTime, length: ${event.length}");
      if (!outputController.isClosed) {
        outputController.add(event);
      }
    }, onError: (error, stackTrace) {
      debugPrint(error.toString());
      debugPrintStack(stackTrace: stackTrace);
      if (!outputController.isClosed) {
        // 一旦出现错误，后续就没了，只能reset新建一个numController和异步，
        outputController.addError(error, stackTrace);
      }
    }, onDone: () {
      if (!outputController.isClosed) {
        // 一旦关闭StreamBuilder就完成了，无法恢复了，
        outputController.close();
      }
    });
  }

  void start() {
    log('start');
    transfer(count);
    count *= 2;
  }

  void transfer(int max) async {
    var takeCount = 0;
    try {
      await for (var data in fileReadStreamSplit.take(max)) {
        ++takeCount;
        inputController.add(data);
      }
    } catch (e, s) {
      inputController.addError(e, s);
      return;
    }
    if (takeCount < max) {
      inputController.close();
    }
  }

  void end() {
    inputController.close();
  }

  void reset() async {
    await isolateTransformer.killAll();
    inputController.close();
    count = 1;
    initIsolate();
  }

  void error() {
    inputController.add(Uint8List(0));
  }

  @override
  void dispose() {
    inputController.close();
    outputController.close();
    isolateTransformer.killAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('byteArrayMergeTransform'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
                stream: outputController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    // 处理错误情况
                    return Text(
                        'Error: ${snapshot.error}\n${snapshot.stackTrace}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('waiting');
                  } else if (!snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return Text('No more data');
                  } else {
                    final data = snapshot.requireData;
                    final status =
                        snapshot.connectionState == ConnectionState.done
                            ? 'done'
                            : 'waiting';
                    if (data.isEmpty) {
                      return Text('$status: 0');
                    }
                    return Text(
                      '$status: ${data.length}, ${data.first.toRadixString(16).padLeft(2, '0')}..${data.last.toRadixString(16).padLeft(2, '0')}',
                    );
                  }
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    start();
                  },
                  child: Text('start'),
                ),
                ElevatedButton(
                  onPressed: () {
                    end();
                  },
                  child: Text('end'),
                ),
                ElevatedButton(
                  onPressed: () {
                    reset();
                  },
                  child: Text('reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    error();
                  },
                  child: Text('error'),
                ),
                CircularProgressIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
