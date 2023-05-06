import 'package:dio/dio.dart';

abstract class Failure {
  final String errMessage;

  Failure(this.errMessage);
}

class SarverFailure extends Failure {
  SarverFailure(super.errMessage);

  factory SarverFailure.FromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.connectTimeout:
        return SarverFailure('Connection timeout with Apiserver');

      case DioErrorType.sendTimeout:
        return SarverFailure('Send timeout with Apiserver');
      case DioErrorType.receiveTimeout:
        return SarverFailure('Receive timeout with Apiserver');
      case DioErrorType.response:
        return SarverFailure.fromResponse(
            dioError.response!.statusCode!, dioError.response!.data);
      case DioErrorType.cancel:
        return SarverFailure('Request to Apiserver was canceld');

      case DioErrorType.other:
        if (dioError.message.contains('SocketException')) {
          return SarverFailure('No Internet Connection');
        }
        return SarverFailure('Unexpected Error, please try later!');
      default:
        return SarverFailure('Opps There was an Error, please try again');
    }
  }

  factory SarverFailure.fromResponse(int statascode, dynamic response) {
    if (statascode == 400 || statascode == 401 || statascode == 403) {
      return SarverFailure(response['error']['message']);
    } else if (statascode == 404) {
      return SarverFailure('Your request not found, please try later!');
    } else if (statascode == 405) {
      return SarverFailure('Internal Server error, please try later!');
    } else {
      return SarverFailure('Opps There was an Error, please try again');
    }
  }
}
