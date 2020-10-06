import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinkanutilapp/dow_info.dart';

import 'package:kinkanutilapp/dow_input_area.dart';
import 'package:kinkanutilapp/screen_type.dart';
import 'package:kinkanutilapp/group_const.dart';
import 'package:nholiday_jp/nholiday_jp.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth _auth = FirebaseAuth.instanceFor(app: Firebase.app());
  OAuthCredential _oAuthCredential;

  List<DOWInfo> dowInfoList;

  DOWInfo defaultDOWInfo;

  var _isOpenTeams = false;

  var _hasDetailSettings = false;

  var _isSettingTime = true;

  var _isPreview = false;

  var _isPosting = false;

  void _changeTeamsSwitch(bool e) => setState(() => _isOpenTeams = e);

  void _changeSettingTimeSwitch(bool e) {
    setState(() => _isSettingTime = e);
    _setIsSettingTime();
  }

  double _workingTime;

  @override
  void initState() {
    _auth.setPersistence(Persistence.NONE);
    _init();
    super.initState();
  }

  void _init() async {
    // デフォルトの初期化
    defaultDOWInfo = DOWInfo();
    await _getIsSettingTime();
    await _getDefaultTimeValue();
    await _getDefaultWorkPlaceValue();
    _initDOWInfoList();
    _workingTime = defaultDOWInfo.getWorkingTime();
  }

  Future<void> _generateAndCopy() async {
    await _copyToClipboard('${_getPlansTitle()}\n${_getPlans()}');
  }

  String _getPlansTitle() {
    return '${dowInfoList[0].getDate()}-${dowInfoList[4].getDate()} 勤務予定 ()';
  }

  String _getPlans() {
    var plans = "";
    dowInfoList.forEach((dow) {
      if (_isSettingTime) {
        if (_hasDetailSettings) {
          plans += dow.toString();
        } else {
          if (dow.workPlace == workPlaceList[3]) {
            plans +=
                '${dow.getDate()} ${NHolidayJp.getName(dow.startDateTime.year, dow.startDateTime.month, dow.startDateTime.day) ?? dow.workPlace}';
          } else {
            plans +=
                '${dow.getDate()} ${defaultDOWInfo.getStartTime()}-${defaultDOWInfo.getEndTime()} ${defaultDOWInfo.workPlace}';
          }
        }
      } else {
        plans += dow.toStringWithoutTime();
      }
      if (dow.startDateTime.weekday != DateTime.friday) {
        plans += '\n';
      }
    });
    return plans;
  }

  void _setHoliday(DOWInfo dowInfo) {
    var isHoliday = NHolidayJp.getName(dowInfo.startDateTime.year,
            dowInfo.startDateTime.month, dowInfo.startDateTime.day) !=
        null;
    if (isHoliday) {
      dowInfo.workPlace = workPlaceList[3];
    } else if (dowInfo.workPlace == workPlaceList[3]) {
      dowInfo.workPlace = defaultDOWInfo.workPlace;
    }
  }

  void _initDOWInfoList() {
    dowInfoList = List<DOWInfo>();

    int diff = DateTime.monday - DateTime.now().weekday;
    if (diff > 1) {
      diff -= 8;
    }
    diff += 7;

    for (int i = 0; i < 5; i++) {
      var datetime = DateTime.now().add(new Duration(days: diff + i));
      DateTime startDatetime = DateTime.parse(
          '${parseDateFormat.format(datetime)} ${defaultDOWInfo.getStartTime()}:00.000');
      DateTime endDatetime = DateTime.parse(
          '${parseDateFormat.format(datetime)} ${defaultDOWInfo.getEndTime()}:00.000');
      var isHoliday = NHolidayJp.getName(
              startDatetime.year, startDatetime.month, startDatetime.day) !=
          null;

      dowInfoList.add(DOWInfo(
          startDateTime: startDatetime,
          endDateTime: endDatetime,
          workPlace: isHoliday ? workPlaceList[3] : defaultDOWInfo.workPlace));
    }
  }

  void _resetAllDate() {
    int diff = DateTime.monday - DateTime.now().weekday;
    if (diff > 1) {
      diff -= 8;
    }
    diff += 7;

    int i = 0;
    dowInfoList.forEach((dowInfo) {
      var datetime = DateTime.now().add(new Duration(days: diff + i));
      dowInfo.startDateTime = DateTime.parse(
          '${parseDateFormat.format(datetime)} ${dowInfo.getStartTime()}:00.000');
      dowInfo.endDateTime = DateTime.parse(
          '${parseDateFormat.format(datetime)} ${dowInfo.getEndTime()}:00.000');
      _setHoliday(dowInfo);
      i++;
    });
  }

  void _incrementAllDate() {
    setState(() {
      dowInfoList.forEach((dowInfo) {
        dowInfo.startDateTime = dowInfo.startDateTime.add(Duration(days: 7));
        dowInfo.endDateTime = dowInfo.endDateTime.add(Duration(days: 7));
        _setHoliday(dowInfo);
      });
    });
  }

  void _decrementAllDate() {
    setState(() {
      dowInfoList.forEach((dowInfo) {
        dowInfo.startDateTime = dowInfo.startDateTime.add(Duration(days: -7));
        dowInfo.endDateTime = dowInfo.endDateTime.add(Duration(days: -7));
        _setHoliday(dowInfo);
      });
    });
  }

  void _resetAllTime() {
    setState(() {
      defaultDOWInfo.startDateTime =
          DateTime.parse('${defaultDOWInfo.getDateForParse()} 09:00:00.000');
      defaultDOWInfo.endDateTime =
          DateTime.parse('${defaultDOWInfo.getDateForParse()} 17:30:00.000');

      _workingTime = defaultDOWInfo.getWorkingTime();

      dowInfoList.forEach((dowInfo) {
        dowInfo.startDateTime = DateTime.parse(
            '${dowInfo.getDateForParse()} ${defaultDOWInfo.getStartTime()}:00.000');
        dowInfo.endDateTime = DateTime.parse(
            '${dowInfo.getDateForParse()} ${defaultDOWInfo.getEndTime()}:00.000');
        dowInfo.startTimeController.text = dowInfo.getStartTime();
        dowInfo.endTimeController.text = dowInfo.getEndTime();
      });
      _setDefaultTimeValue();
    });
  }

  void _resetWorkingTime() {
    setState(() {
      var duration = Duration(hours: 8, minutes: 30);

      defaultDOWInfo.endDateTime = defaultDOWInfo.startDateTime;
      defaultDOWInfo.endDateTime = defaultDOWInfo.endDateTime.add(duration);
      _workingTime = defaultDOWInfo.getWorkingTime();

      dowInfoList.forEach((dowInfo) {
        dowInfo.endDateTime = dowInfo.startDateTime;
        dowInfo.endDateTime = dowInfo.endDateTime.add(duration);
        dowInfo.endTimeController.text = dowInfo.getEndTime();
      });
      _setDefaultTimeValue();
    });
  }

  void _incrementAllTime() {
    setState(() {
      defaultDOWInfo.incrementStartTime();
      defaultDOWInfo.incrementEndTime();
      _workingTime = defaultDOWInfo.getWorkingTime();

      dowInfoList.forEach((dowInfo) {
        dowInfo.incrementStartTime();
        dowInfo.incrementEndTime();
      });
      _setDefaultTimeValue();
    });
  }

  void _decrementAllTime() {
    setState(() {
      defaultDOWInfo.decrementStartTime();
      defaultDOWInfo.decrementEndTime();
      _workingTime = defaultDOWInfo.getWorkingTime();

      dowInfoList.forEach((dowInfo) {
        dowInfo.decrementStartTime();
        dowInfo.decrementEndTime();
      });
      _setDefaultTimeValue();
    });
  }

  void _onSelectedWorkPlace(int index) {
    setState(() {
      defaultDOWInfo.workPlace = workPlaceList[index];

      _setDefaultWorkPlaceValue();

      dowInfoList.forEach((dowInfo) {
        dowInfo.workPlace = workPlaceList[index];
      });
    });
  }

  void incrementStartTimeCallback(DOWInfo info) {
    setState(() {
      info.incrementStartTime();
    });
  }

  void incrementEndTimeCallback(DOWInfo info) {
    setState(() {
      info.incrementEndTime();
    });
  }

  void decrementStartTimeCallback(DOWInfo info) {
    setState(() {
      info.decrementStartTime();
    });
  }

  void decrementEndTimeCallback(DOWInfo info) {
    setState(() {
      info.decrementEndTime();
    });
  }

  void selectWorkPlaceCallback(DOWInfo info, String newValue) {
    setState(() {
      info.workPlace = newValue;
    });
  }

  Future<void> _copyToClipboard(String text) async {
    final data = ClipboardData(text: text);
    await Clipboard.setData(data);
  }

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

  registerEvent() async {
    setState(() {
      _isPosting = true;
    });

    if (_oAuthCredential == null) {
      await authorise();
    }

    if (_oAuthCredential == null) {
      setState(() {
        _isPosting = false;
      });
      return;
    }

    var accessToken = _oAuthCredential.accessToken;
    for (var info in dowInfoList) {
      await postEvent(
          token: accessToken,
          subject: info.getSubjectForOutlook(_isSettingTime),
          startDateTime: info.getStartDateTimeForOutlook(),
          endDateTime: info.getEndDateTimeForOutlook());
    }
    setState(() {
      _isPosting = false;
    });
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

  bool isLargeScreen(BuildContext context) {
    return screenType(context) == ScreenType.xl ||
        screenType(context) == ScreenType.lg ||
        screenType(context) == ScreenType.md;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        width: 600,
                        padding: EdgeInsets.only(
                            top: 10.0, bottom: 10, left: 10, right: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            isLargeScreen(context)
                                ? _buildLargeDefaultSettingArea()
                                : _buildSmallDefaultSettingArea(),
                            SizedBox(
                              width: isLargeScreen(context)
                                  ? 550
                                  : double.infinity,
                              child: FlatButton(
                                color: Color(0x00ffffff),
                                onPressed: () {
                                  setState(() {
                                    _hasDetailSettings = !_hasDetailSettings;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(_hasDetailSettings
                                        ? Icons.arrow_drop_down
                                        : Icons.arrow_right),
                                    Text('詳細設定'),
                                  ],
                                ),
                              ),
                            ),
                            _hasDetailSettings
                                ? Container(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          for (var info in dowInfoList)
                                            DOWInputArea(
                                              info: info,
                                              incrementStartCallback:
                                                  incrementStartTimeCallback,
                                              decrementStartCallback:
                                                  decrementStartTimeCallback,
                                              incrementEndCallback:
                                                  incrementEndTimeCallback,
                                              decrementEndCallback:
                                                  decrementEndTimeCallback,
                                              selectWorkPlaceCallback:
                                                  selectWorkPlaceCallback,
                                            ),
                                        ]),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: _isPreview ? 250 : 60,
                decoration: BoxDecoration(
                  color: Color(0xfff0f0f0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 1.0,
                      blurRadius: 10.0,
                      offset: Offset(-5, 0),
                    ),
                  ],
                ),
                width: double.infinity,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isPreview
                              ? SizedBox(
                                  width: isLargeScreen(context)
                                      ? 600
                                      : double.infinity,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          height: 150,
                                          padding: EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 10,
                                              bottom: 10),
                                          margin: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color: Color(0xffffffff),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                spreadRadius: 1.0,
                                                blurRadius: 10.0,
                                                offset: Offset(5, 5),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                                '${_getPlansTitle()}\n${_getPlans()}'),
                                          ),
                                        ),
                                        Container(
                                          height: 150,
                                          padding: EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 10,
                                              bottom: 10),
                                          margin: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color: Color(0xffffffff),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                spreadRadius: 1.0,
                                                blurRadius: 10.0,
                                                offset: Offset(5, 5),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          width: 1,
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      bottom: 5),
                                                  child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        for (var info
                                                            in dowInfoList)
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SizedBox(
                                                                width: 40,
                                                                child: Text(
                                                                  '${info.getWeekday()} : ',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 50,
                                                                child: Text(
                                                                  '${_hasDetailSettings ? info.getWorkingTime() : defaultDOWInfo.getWorkingTime()}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                              Text(
                                                                '時間',
                                                              ),
                                                            ],
                                                          ),
                                                      ]),
                                                ),
                                                Container(
                                                    padding:
                                                        EdgeInsets.only(top: 5),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        SizedBox(
                                                          width: 40,
                                                          child: Text(
                                                            '合計 : ',
                                                            textAlign:
                                                                TextAlign.end,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 50,
                                                          child: Text(
                                                            '${_sumWorkingTime()}',
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Text(
                                                          '時間',
                                                        ),
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                )
                              : Container(),
                          Center(
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: _isPosting
                                        ? Center(
                                            child: Container(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator()))
                                        : RaisedButton(
                                            child: const Text(
                                              '予定表に登録',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () async {
                                              await registerEvent();
                                              final snackBar = SnackBar(
                                                content:
                                                    Text('Outlookの予定表に登録しました。'),
                                                action: SnackBarAction(
                                                  label: '閉じる',
                                                  textColor: Colors.yellow,
                                                  onPressed: () {
                                                    Scaffold.of(context)
                                                        .hideCurrentSnackBar();
                                                  },
                                                ),
                                              );
                                              Scaffold.of(context)
                                                  .showSnackBar(snackBar);
                                            },
                                            color: Colors.blue,
                                            textColor: Colors.white,
                                          ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: RaisedButton(
                                      child: const Text(
                                        'メールで送信',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () async {
                                        String subject = Uri.encodeComponent(
                                            _getPlansTitle());
                                        String body =
                                            Uri.encodeComponent(_getPlans());
                                        String url =
                                            "mailto:${GroupConst.teamsAddress}?subject=$subject&body=$body";
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      color: Colors.blue,
                                      textColor: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: RaisedButton(
                                      child: const Text(
                                        'コピー',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () async {
                                        await _generateAndCopy();
                                        final snackBar = SnackBar(
                                          content: Text('クリップボードにコピーしました！'),
                                          action: SnackBarAction(
                                            label: '閉じる',
                                            textColor: Colors.yellow,
                                            onPressed: () {
                                              Scaffold.of(context)
                                                  .hideCurrentSnackBar();
                                            },
                                          ),
                                        );
                                        Scaffold.of(context)
                                            .showSnackBar(snackBar);

                                        if (_isOpenTeams) {
                                          launch(GroupConst.teamsUrl);
                                        }
                                      },
                                      color: Colors.blue,
                                      textColor: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10.0),
                                    child: Switch(
                                      value: _isOpenTeams,
                                      activeColor: Colors.white,
                                      activeTrackColor: Colors.blueAccent,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: Colors.grey,
                                      onChanged: _changeTeamsSwitch,
                                    ),
                                  ),
                                  Icon(
                                    Icons.open_in_new,
                                    size: 16,
                                  ),
                                  Text('Teamsを開く',
                                      style: TextStyle(
                                        fontSize: 16,
                                      )),
                                ]),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: _isPreview
                          ? Alignment.topRight
                          : Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(_isPreview
                            ? Icons.arrow_drop_down
                            : Icons.arrow_drop_up),
                        color: Colors.blueGrey,
                        onPressed: () => setState(() {
                          _isPreview = !_isPreview;
                        }),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _sumWorkingTime() {
    var sum = 0.0;
    for (var info in dowInfoList)
      sum += _hasDetailSettings
          ? info.getWorkingTime()
          : defaultDOWInfo.getWorkingTime();
    return sum;
  }

  Widget _buildLargeDefaultSettingArea() {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 70,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                          ),
                          Center(
                              child: const Text(
                            '日付',
                            style: TextStyle(fontSize: 16),
                          )),
                        ]),
                  ),
                  SizedBox(
                    width: 360,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: _decrementAllDate,
                              color: Colors.blueGrey,
                              icon: Icon(Icons.keyboard_arrow_left),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: Center(
                              child: Text(
                                '${dowInfoList[0].getDate()} 〜 ${dowInfoList[4].getDate()}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: _incrementAllDate,
                              color: Colors.blueGrey,
                              icon: Icon(Icons.keyboard_arrow_right),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                _resetAllDate();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.autorenew_rounded),
                            ),
                          ),
                        ]),
                  ),
                ]),
          ),
          SizedBox(
            height: 70,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 20,
                          ),
                          Center(
                              child: const Text(
                            '時刻',
                            style: TextStyle(fontSize: 16),
                          )),
                          Container(
                            margin: EdgeInsets.only(left: 20.0),
                            child: Switch(
                              value: _isSettingTime,
                              activeColor: Colors.white,
                              activeTrackColor: Colors.blueAccent,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Colors.grey,
                              onChanged: _changeSettingTimeSwitch,
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(
                    width: 360,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                _decrementAllTime();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.keyboard_arrow_left),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: Center(
                              child: Text(
                                '${defaultDOWInfo.getStartTime()} 〜 ${defaultDOWInfo.getEndTime()}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isSettingTime
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                _incrementAllTime();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.keyboard_arrow_right),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                _resetAllTime();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.autorenew_rounded),
                            ),
                          ),
                        ]),
                  ),
                ]),
          ),
          SizedBox(
            height: 70,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timelapse,
                            size: 20,
                          ),
                          Center(
                              child: const Text(
                            '時間',
                            style: TextStyle(fontSize: 16),
                          )),
                        ]),
                  ),
                  SizedBox(
                    width: 360,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                defaultDOWInfo.decrementEndTime();
                                _workingTime = defaultDOWInfo.getWorkingTime();
                                dowInfoList.forEach((dowInfo) {
                                  dowInfo.decrementEndTime();
                                });
                                _setDefaultTimeValue();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.keyboard_arrow_left),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: Center(
                              child: Text(
                                '$_workingTime 時間',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isSettingTime
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                defaultDOWInfo.incrementEndTime();
                                _workingTime = defaultDOWInfo.getWorkingTime();
                                dowInfoList.forEach((dowInfo) {
                                  dowInfo.incrementEndTime();
                                });
                                _setDefaultTimeValue();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.keyboard_arrow_right),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                _resetWorkingTime();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.autorenew_rounded),
                            ),
                          ),
                        ]),
                  ),
                ]),
          ),
          SizedBox(
            height: 70,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.place,
                          size: 20,
                        ),
                        Center(
                            child: const Text(
                          '場所',
                          style: TextStyle(fontSize: 16),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 360,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: RaisedButton(
                            child: const Text(
                              'リモート',
                              style: TextStyle(color: Colors.white),
                            ),
                            disabledColor: Colors.blue,
                            color: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                            onPressed:
                                defaultDOWInfo.workPlace == workPlaceList[0]
                                    ? null
                                    : () => _onSelectedWorkPlace(0),
                          ),
                        ),
                        Container(
                          child: RaisedButton(
                            child: const Text(
                              '出社',
                              style: TextStyle(color: Colors.white),
                            ),
                            disabledColor: Colors.blue,
                            color: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                            onPressed:
                                defaultDOWInfo.workPlace == workPlaceList[1]
                                    ? null
                                    : () => _onSelectedWorkPlace(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDefaultSettingArea() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                width: 1,
                color: Colors.grey,
              ),
            )),
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                          ),
                          Center(
                              child: const Text(
                            '日付',
                            style: TextStyle(fontSize: 16),
                          )),
                        ]),
                  ),
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: IconButton(
                            iconSize: 20,
                            onPressed: _decrementAllDate,
                            color: Colors.blueGrey,
                            icon: Icon(Icons.keyboard_arrow_left),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: Center(
                            child: Text(
                              '${dowInfoList[0].getDate()} 〜 ${dowInfoList[4].getDate()}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: IconButton(
                            iconSize: 20,
                            onPressed: _incrementAllDate,
                            color: Colors.blueGrey,
                            icon: Icon(Icons.keyboard_arrow_right),
                          ),
                        ),
                        Container(
                          child: IconButton(
                            iconSize: 20,
                            onPressed: () => setState(() {
                              _resetAllDate();
                            }),
                            color: Colors.blueGrey,
                            icon: Icon(Icons.autorenew_rounded),
                          ),
                        ),
                      ]),
                ]),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(width: 1, color: Colors.grey),
            )),
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 20,
                          ),
                          Center(
                              child: const Text(
                            '時刻',
                            style: TextStyle(fontSize: 16),
                          )),
                          SizedBox(
                            child: Switch(
                              value: _isSettingTime,
                              activeColor: Colors.white,
                              activeTrackColor: Colors.blueAccent,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Colors.grey,
                              onChanged: _changeSettingTimeSwitch,
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                _decrementAllTime();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.keyboard_arrow_left),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: Center(
                              child: Text(
                                '${defaultDOWInfo.getStartTime()} 〜 ${defaultDOWInfo.getEndTime()}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isSettingTime
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                _incrementAllTime();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.keyboard_arrow_right),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                _resetAllTime();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.autorenew_rounded),
                            ),
                          ),
                        ]),
                  ),
                ]),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(width: 1, color: Colors.grey),
            )),
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 20,
                          ),
                          Center(
                              child: const Text(
                            '時間',
                            style: TextStyle(fontSize: 16),
                          )),
                        ]),
                  ),
                  SizedBox(
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                defaultDOWInfo.decrementEndTime();
                                _workingTime = defaultDOWInfo.getWorkingTime();
                                dowInfoList.forEach((dowInfo) {
                                  dowInfo.decrementEndTime();
                                });
                                _setDefaultTimeValue();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.keyboard_arrow_left),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: Center(
                              child: Text(
                                '$_workingTime 時間',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isSettingTime
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                defaultDOWInfo.incrementEndTime();
                                _workingTime = defaultDOWInfo.getWorkingTime();
                                dowInfoList.forEach((dowInfo) {
                                  dowInfo.incrementEndTime();
                                });
                                _setDefaultTimeValue();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.keyboard_arrow_right),
                            ),
                          ),
                          Container(
                            child: IconButton(
                              iconSize: 20,
                              onPressed: () => setState(() {
                                _resetWorkingTime();
                              }),
                              color: Colors.blueGrey,
                              icon: Icon(Icons.autorenew_rounded),
                            ),
                          ),
                        ]),
                  ),
                ]),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                width: 1,
                color: Colors.grey,
              ),
            )),
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.place,
                          size: 20,
                        ),
                        Center(
                            child: const Text(
                          '場所',
                          style: TextStyle(fontSize: 16),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 360,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: RaisedButton(
                            child: const Text(
                              'リモート',
                              style: TextStyle(color: Colors.white),
                            ),
                            disabledColor: Colors.blue,
                            color: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                            onPressed:
                                defaultDOWInfo.workPlace == workPlaceList[0]
                                    ? null
                                    : () => _onSelectedWorkPlace(0),
                          ),
                        ),
                        Container(
                          child: RaisedButton(
                            child: const Text(
                              '出社',
                              style: TextStyle(color: Colors.white),
                            ),
                            disabledColor: Colors.blue,
                            color: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                            onPressed:
                                defaultDOWInfo.workPlace == workPlaceList[1]
                                    ? null
                                    : () => _onSelectedWorkPlace(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  Future<void> _getDefaultTimeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var startTime = prefs.getString('defaultStartTime') ?? '09:00';
      var endTime = prefs.getString('defaultEndTime') ?? '17:30';

      defaultDOWInfo.startDateTime = DateTime.parse(
          '${defaultDOWInfo.getDateForParse()} $startTime:00.000');
      defaultDOWInfo.endDateTime =
          DateTime.parse('${defaultDOWInfo.getDateForParse()} $endTime:00.000');
    });
  }

  Future<void> _setDefaultTimeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('defaultStartTime', defaultDOWInfo.getStartTime());
    prefs.setString('defaultEndTime', defaultDOWInfo.getEndTime());
  }

  Future<void> _getDefaultWorkPlaceValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var index = prefs.getInt('defaultWorkPlace') ?? 0;
      defaultDOWInfo.workPlace = workPlaceList[index];
    });
  }

  Future<void> _setDefaultWorkPlaceValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(
        'defaultWorkPlace', workPlaceList.indexOf(defaultDOWInfo.workPlace));
  }

  Future<void> _getIsSettingTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSettingTime = prefs.getBool('isSettingTime') ?? true;
    });
  }

  Future<void> _setIsSettingTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSettingTime', _isSettingTime);
  }
}
