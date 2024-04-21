import 'dart:async';

import 'package:example/src/function/prime.dart';
import 'package:flutter/material.dart';
import 'package:isolate_transformer/isolate_transformer.dart';

/// Displays detailed information about a SampleItem.
class MapListView extends StatefulWidget {
  const MapListView({super.key});

  static const routeName = '/map_list';

  @override
  State<MapListView> createState() => _MapListViewState();
}

class _MapListViewState extends State<MapListView> {
  late StreamController<Map> numController;
  final primeController = StreamController<(int, String)>();
  final isolateTransformer = IsolateTransformer();
  var currentPrime = 1;
  var index = 0;
  var count = 100;
  @override
  void initState() {
    super.initState();
    initIsolate();
  }

  void initIsolate() {
    numController = StreamController<Map>();
    isolateTransformer
        .transform(numController.stream, findPrimeNumbersListTransform,
            workerName: 'findPrimeNumbersListTransform')
        .listen((event) {
      currentPrime = event.last;
      if (!primeController.isClosed) {
        primeController.add((index++, event.toString()));
      }
    }, onError: (error, stackTrace) {
      debugPrint(error.toString());
      debugPrintStack(stackTrace: stackTrace);
      if (!primeController.isClosed) {
        // 一旦出现错误，后续就没了，只能reset新建一个numController和异步，
        primeController.addError(error, stackTrace);
      }
    }, onDone: () {
      if (!primeController.isClosed) {
        // 一旦关闭StreamBuilder就完成了，无法恢复了，
        primeController.close();
      }
    });
  }

  void start() {
    index = 0;
    numController.add({
      'prime': currentPrime,
      'count': count++,
      'merge': 3,
    });
  }

  void end() {
    numController.close();
  }

  void reset() async {
    await isolateTransformer.killAll();
    currentPrime = 1;
    index = 0;
    initIsolate();
  }

  void error() {
    numController.add({
      'prime': -1,
      'count': count++,
      'merge': 3,
    });
  }

  @override
  void dispose() {
    numController.close();
    primeController.close();
    isolateTransformer.killAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IsolateTransformer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<Object>(
                stream: primeController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    // 处理错误情况
                    return Text(
                        'Error: ${snapshot.error}\n${snapshot.stackTrace}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('0');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return Text('No more data');
                  } else {
                    return Text(
                      'prime number: ${snapshot.data}',
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
