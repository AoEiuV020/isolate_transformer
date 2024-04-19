import 'dart:async';

import 'package:example/src/prime/prime.dart';
import 'package:flutter/material.dart';
import 'package:isolate_transformer/isolate_transformer.dart';

/// Displays detailed information about a SampleItem.
class PrimeCalcView extends StatefulWidget {
  const PrimeCalcView({super.key});

  static const routeName = '/prime_calc';

  @override
  State<PrimeCalcView> createState() => _PrimeCalcViewState();
}

class _PrimeCalcViewState extends State<PrimeCalcView> {
  final numController = StreamController<int>();
  final primeController = StreamController<(int, int)>();
  final isolateTransformer = IsolateTransformer();
  static final prime = Prime();
  var currentPrime = 1;
  var index = 0;
  @override
  void initState() {
    super.initState();
    initIsolate();
  }

  void initIsolate() {
    prime.setHash();
    isolateTransformer.transform(numController.stream, (e) {
      /*
      if (0 > 0) {
        debugPrint(currentPrime.toString());
      }
      */
      return prime.transform(e);
    }).listen((event) {
      currentPrime = event;
      if (!primeController.isClosed) {
        primeController.add((index++, event));
      }
    });
  }

  void start() {
    assert(prime.countWrapper.count == 100);
    index = 0;
    numController.add(currentPrime);
  }

  @override
  void dispose() {
    numController.close();
    primeController.close();
    isolateTransformer.killAllIsolates();
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
