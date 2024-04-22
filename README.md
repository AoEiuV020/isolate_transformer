# isolate_transformer
flutter封装异步处理Stream流式数据，

[![img](https://img.shields.io/github/release/AoEiuV020/isolate_transformer.svg)](https://github.com/AoEiuV020/isolate_transformer/releases)
[![CI](https://github.com/AoEiuV020/isolate_transformer/workflows/CI/badge.svg)](https://github.com/AoEiuV020/isolate_transformer/actions)
[![Using melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)
[![Main version](https://img.shields.io/pub/v/isolate_transformer.svg)](https://pub.dev/packages/isolate_transformer)

## Features
主要针对 Stream.transform 的异步线程调用，其他异步线程封装都是一进一出，无法用于transform，  
最终实现效果是可以往异步线程发送一个 Stream to Stream 的方法，  
进出都是 Stream ，可以轻易使用Stream的transform和asyncExpand方法处理N进M出的数据流，  
error和done都有处理，所以也可以用于一进一出的数据处理，

[file.dart](./apps/example/lib/src/function/file.dart)  
[prime.dart](./apps/example/lib/src/function/prime.dart)  

## Getting started

```shell
dart pub add isolate_transformer dev:js
```

## Usage
[异步计算质数示例](./apps/example/lib/src/sample_feature/prime_calc_3_view.dart)  
[异步解析文件数据示例](./apps/example/lib/src/sample_feature/file_picker_item_details_view.dart)  

首先写个需要异步调用的顶层函数，保险起见不要定义在类中，否则可能出现不支持的对象传到异步线程崩溃，
```dart
@pragma('vm:entry-point')
Stream<int> findPrimeNumbersTransform(Stream<int> numStream) =>
    numStream.asyncExpand((event) {
      return findPrimeNumbers(event * 10, 100);
    });
```
web支持： 在web目录下添加 findPrimeNumbersTransform.dart 文件，
```dart
import 'package:example/src/function/prime.dart';
import 'package:isolate_transformer/worker_transformer.dart';
main() {
  workerMain(findPrimeNumbersTransform);
}
```
web支持： 在web目录下编译上述dart文件得到最终使用的js文件，
```shell
dart compile js findPrimeNumbersTransform.dart -o findPrimeNumbersTransform.js -O4
```
主线程创建IsolateTransformer对象，调用transform方法传入数据源Stream和需要异步执行的Stream转化方法，直接开始执行，  
web支持： 可选参数workerName，即是上述js文件 findPrimeNumbersTransform.js 的文件名，如果不给该参数，或者浏览器不支持Worker，会直接在主线程执行Stream转化方法，    
```dart
  final isolateTransformer = IsolateTransformer();
      isolateTransformer
        .transform(numController.stream, findPrimeNumbersTransform,
            workerName: 'findPrimeNumbersTransform')
        .listen((event) {
      print(event);
    });
```

页面关闭时记得停止异步工作，
```dart
isolateTransformer.killAll();
```

## TODO
- 示例读取文件许多二进制文件卡住，
