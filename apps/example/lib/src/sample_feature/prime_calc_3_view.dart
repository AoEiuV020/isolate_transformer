import 'dart:async';

import 'package:example/src/function/prime.dart';
import 'package:flutter/material.dart';
import 'package:isolate_transformer/isolate_transformer.dart';

/// Displays detailed information about a SampleItem.
class PrimeCalc3View extends StatefulWidget {
  const PrimeCalc3View({super.key});

  static const routeName = '/prime_calc_3';

  @override
  State<PrimeCalc3View> createState() => _PrimeCalc3ViewState();
}

class _PrimeCalc3ViewState extends State<PrimeCalc3View> {
  late StreamController<int> numController;
  final primeController = StreamController<(int, int)>();
  final isolateTransformer = IsolateTransformer();
  var currentPrime = 1;
  var index = 0;
  @override
  void initState() {
    super.initState();
    initIsolate();
  }

  void initIsolate() {
    numController = StreamController<int>();
    isolateTransformer
        .transform(numController.stream, findPrimeNumbersTransform,
            workerName: 'findPrimeNumbersTransform')
        .listen((event) {
      currentPrime = event;
      if (!primeController.isClosed) {
        primeController.add((index++, event));
      }
    }, onError: (error, stackTrace) {
      debugPrint(error.toString());
      debugPrintStack(stackTrace: stackTrace);
      if (!primeController.isClosed) {
        // 一旦出现错误，后续就没了，只能reset新建一个numController和异步，
        primeController.addError(error, stackTrace);
      }
    });
  }

  void start() {
    index = 0;
    numController.add(currentPrime);
  }

  void reset() async {
    await isolateTransformer.killAll();
    currentPrime = 1;
    index = 0;
    initIsolate();
  }

  void error() {
    numController.add(-1);
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
