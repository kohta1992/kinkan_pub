import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kinkanutilapp/model/plans.dart';

class MsGraph {
  FirebaseAuth _auth = FirebaseAuth.instanceFor(app: Firebase.app());
  OAuthCredential _oAuthCredential;

  authorise() async {
    await performLogin("microsoft.com", [
      'User.Read',
      'Calendars.ReadWrite',
    ], {
      "location": "ja",
    });
  }

  Future<void> performLogin(String provider, List<String> scopes,
      Map<String, String> parameters) async {
    try {
      final oAuthProvider = OAuthProvider(provider);
      scopes.forEach((scope) => oAuthProvider.addScope(scope));

      if (parameters != null) {
        oAuthProvider.setCustomParameters(parameters);
      }

      await _auth.signInWithPopup(oAuthProvider).then((result) {
        _oAuthCredential = result.credential;
      }).catchError((error) {
        // Handle error.
      });
    } on PlatformException catch (error) {
      debugPrint("${error.code}: ${error.message}");
    }
  }

  registerEvent(PlansModel plansModel) async {
    if (_oAuthCredential == null) {
      await authorise();
    }

    if (_oAuthCredential == null) {
      return;
    }

    var accessToken = _oAuthCredential.accessToken;

    for (var plan in plansModel.plans) {
      await postEvent(
          token: accessToken,
          subject: plan.getSubjectForOutlook(plansModel.isTimeUnneeded),
          startDateTime: plan.getStartDateTimeForOutlook(),
          endDateTime: plan.getEndDateTimeForOutlook());
    }
  }

  Future<bool> postEvent(
      {@required String token,
      @required String subject,
      String body,
      @required String startDateTime,
      @required String endDateTime}) async {
    final response = await http.post(
        'https://graph.microsoft.com/v1.0/me/events',
        headers: {
          'Authorization': '$token',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          "subject": subject,
          "body": {"content": body, "contentType": "text"},
          "start": {
            "dateTime": startDateTime,
            "timeZone": "Tokyo Standard Time"
          },
          "end": {"dateTime": endDateTime, "timeZone": "Tokyo Standard Time"},
          "isAllDay": true,
          "isReminderOn": false,
          "showAs": "free",
        }));
    if (response.statusCode == 201) {
      debugPrint('post event success.');
      return true;
    } else {
      debugPrint('post event error.');
      debugPrint(response.toString());
      return false;
    }
  }
}
