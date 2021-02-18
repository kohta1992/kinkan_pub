import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kinkanutilapp/group_const.dart';
import 'package:kinkanutilapp/model/plans.dart';

import 'cache.dart';

class MsGraph {
  FirebaseAuth _auth = FirebaseAuth.instanceFor(app: Firebase.app());
  OAuthCredential _oAuthCredential;

  authorise() async {
    await performLogin("microsoft.com", [
      'User.Read',
      'Calendars.ReadWrite',
      'ChannelMessage.Send',
    ], {
      "location": "ja",
    });
  }

  Future<bool> performLogin(String provider, List<String> scopes,
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
        return false;
      });
    } on PlatformException catch (error) {
      debugPrint("${error.code}: ${error.message}");
      return false;
    }
    return true;
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

  postEvents(PlansModel plansModel) async {
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

  Future<Map> postChannelMessage(PlansModel plansModel, String name) async {
    if (_oAuthCredential == null) {
      await authorise();
    }

    if (_oAuthCredential == null) {
      return null;
    }

    var accessToken = _oAuthCredential.accessToken;

    String channelId = await Cache.getChannelId();
    String groupId = await Cache.getGroupId();

    final response = await http.post(
        'https://graph.microsoft.com/v1.0/teams/$groupId/channels/$channelId/messages',
        headers: {
          'Authorization': '$accessToken',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          "subject": plansModel.getPlansSubjectForTeams(name),
          "body": {
            "content": plansModel.getPlansBodyForTeams(),
            "contentType": "html"
          },
        }));
    if (response.statusCode == 201) {
      try {
        return json.decode(response.body);
      } catch (e) {
        debugPrint('json decode error.');
        debugPrint('response body=${response.toString()}');
        return null;
      }
    } else {
      debugPrint('post event error.');
      debugPrint(response.toString());
      return null;
    }
  }

  Future<bool> replyChannelMessage(String messageId, String replyText) async {
    if (_oAuthCredential == null) {
      await authorise();
    }

    if (_oAuthCredential == null) {
      return false;
    }

    var accessToken = _oAuthCredential.accessToken;

    String channelId = await Cache.getChannelId();
    String groupId = await Cache.getGroupId();

    final response = await http.post(
        'https://graph.microsoft.com/v1.0/teams/$groupId/channels/$channelId/messages/$messageId/replies',
        headers: {
          'Authorization': '$accessToken',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          "body": {"content": replyText, "contentType": "html"},
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
