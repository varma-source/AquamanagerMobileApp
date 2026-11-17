// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:superapp/constants/app_base_urls.dart';
// import 'package:superapp/constants/app_toast_msgs.dart';
// import 'package:superapp/constants/app_tokens.dart';
// import 'package:superapp/model/banner_model.dart';
// import 'package:superapp/model/category_details_model.dart';

// class UserService {
//   // =-=-=-=-=-=-=- get category -=-=-=-=-=-=-= //

//   Future<Categorydetails> fetchgetCategory() async {
//     var headers = {'authorization': 'Bearer ${AppTokens().accessToken}'};
//     var request = http.Request(
//       'POST',
//       Uri.parse(AppBaseUrls.baseUrl + 'app/docs/get-categories'),
//     );

//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       var responseString = await response.stream.bytesToString();
//       final decodedMap = json.decode(responseString);
//       return Categorydetails.fromJson(decodedMap);
//     } else {
//       var responseString = await response.stream.bytesToString();
//       final decodedMap = json.decode(responseString);
//       AppToastMsgs.failedToast("Error", decodedMap['message']);
//       throw Exception(decodedMap['message']);
//     }
//   }

//   // =-=-=-=-=-=-=- get banners -=-=-=-=-=-=-= //

//   Future <Bannerdetails> fetchgetbanners() async {
//     var headers = {
//       'authorization':
//           'Bearer ${AppTokens().accessToken}',
//     };
//     var request = http.Request(
//       'POST',
//       Uri.parse(AppBaseUrls.baseUrl+'app/docs/get-banners'),
//     );

//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       var responseString = await response.stream.bytesToString();
//       final decodedMap = json.decode(responseString);
//       return Bannerdetails.fromJson(decodedMap);
//     } else {
//       var responseString = await response.stream.bytesToString();
//       final decodedMap = json.decode(responseString);
//       AppToastMsgs.failedToast("Error", decodedMap['message']);
//       throw Exception(decodedMap['message']);
//     }
//   }
// }
