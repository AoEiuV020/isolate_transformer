import 'dart:isolate';

import 'package:json_annotation/json_annotation.dart';

part 'count.g.dart';

@JsonSerializable()
class CountWrapper implements Capability {
  final int count;

  CountWrapper({required this.count});

  factory CountWrapper.fromJson(Map<String, dynamic> json) =>
      _$CountWrapperFromJson(json);

  Map<String, dynamic> toJson() => _$CountWrapperToJson(this);
}
