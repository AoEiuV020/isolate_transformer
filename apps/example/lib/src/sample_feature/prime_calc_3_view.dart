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
  final numController = StreamController<int>();
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
    isolateTransformer
        .transform(numController.stream, findPrimeNumbersTransform,
            workerName: 'findPrimeNumbersTransform')
        .listen((event) {
      currentPrime = event;
      if (!primeController.isClosed) {
        primeController.add((index++, event));
      }
    });
  }

  void start() {
    index = 0;
    numController.add(currentPrime);
  }

  @override
  void dispose() {
    numController.close();
    primeController.close();
    isolateTransformer.close();
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
                CircularProgressIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
