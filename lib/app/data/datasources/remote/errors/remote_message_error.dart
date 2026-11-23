// Package imports:
import 'package:equatable/equatable.dart';

class RemoteMessageError extends Equatable {
  final String? message;
  final String? codeMessage;

  const RemoteMessageError({this.message, this.codeMessage});

  // RemoteMessageError.fromJson(Map<String, dynamic> json) {
  //   message = json['message'];
  //   codeMessage = json['code'];
  // }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['message'] = message;
  //   data['code'] = codeMessage;
  //   return data;
  // }

  RemoteMessageError copyWith({
    String? message,
    String? codeMessage,
  }) {
    return RemoteMessageError(
      message: message ?? this.message,
      codeMessage: codeMessage ?? this.codeMessage,
    );
  }

  @override
  List<Object?> get props => [message, codeMessage];
}
