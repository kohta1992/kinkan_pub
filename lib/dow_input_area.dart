import 'package:flutter/material.dart';
import 'package:kinkanutilapp/dow_info.dart';
import 'package:kinkanutilapp/screen_type.dart';
import 'package:kinkanutilapp/spinner_input_form.dart';

class DOWInputArea extends StatefulWidget {
  final DOWInfo info;

  Function(DOWInfo) incrementStartCallback;
  Function(DOWInfo) decrementStartCallback;
  Function(DOWInfo) incrementEndCallback;
  Function(DOWInfo) decrementEndCallback;
  Function(DOWInfo, String) selectWorkPlaceCallback;

  DOWInputArea({
    Key key,
    @required this.info,
    this.incrementStartCallback,
    this.decrementStartCallback,
    this.incrementEndCallback,
    this.decrementEndCallback,
    this.selectWorkPlaceCallback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DOWInputAreaState();
}

class _DOWInputAreaState extends State<DOWInputArea> {
  SpinnerInputForm _startSpinner;
  SpinnerInputForm _endSpinner;

  @override
  void initState() {
    _startSpinner = SpinnerInputForm(
      controller: widget.info.startTimeController,
      enabled: false,
      width: 100.0,
      height: 50.0,
      onTapUpperButton: () => widget.incrementStartCallback(widget.info),
      onTapDownerButton: () => widget.decrementStartCallback(widget.info),
    );

    _endSpinner = SpinnerInputForm(
      controller: widget.info.endTimeController,
      enabled: false,
      width: 100.0,
      height: 50.0,
      onTapUpperButton: () => widget.incrementEndCallback(widget.info),
      onTapDownerButton: () => widget.decrementEndCallback(widget.info),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (screenType(context)) {
      case ScreenType.xl:
      case ScreenType.lg:
      case ScreenType.md:
        return _buildForLarge();
        break;
      case ScreenType.sm:
      case ScreenType.xs:
        return _buildForSmall();
        break;
      default:
        return null;
    }
  }

  Widget _buildForSmall() {
    return Center(
        child: Container(
      height: 100,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        width: 1,
        color: Colors.black12,
      ))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Text(
              '${widget.info.getDate()}',
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _startSpinner,
              _endSpinner,
              Container(
                width: 100,
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DropdownButton<String>(
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blueGrey,
                      ),
                      value: widget.info.workPlace,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, color: Colors.black),
                      underline: Container(
                        height: 0,
                      ),
                      onChanged: (String newValue) {
                        widget.selectWorkPlaceCallback(widget.info, newValue);
                      },
                      items: workPlaceList.map((String item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: item == widget.info.workPlace
                                ? TextStyle(fontWeight: FontWeight.bold)
                                : TextStyle(fontWeight: FontWeight.normal),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildForLarge() {
    return Container(
      height: 60,
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            width: 70,
            child: Text('${widget.info.getDate()}'),
          ),
          _startSpinner,
          _endSpinner,
          Container(
            width: 100,
            padding: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<String>(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.blueGrey,
                  ),
                  value: widget.info.workPlace,
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black),
                  underline: Container(
                    height: 0,
                  ),
                  onChanged: (String newValue) {
                    widget.selectWorkPlaceCallback(widget.info, newValue);
                  },
                  items: workPlaceList.map((String item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: item == widget.info.workPlace
                            ? TextStyle(fontWeight: FontWeight.bold)
                            : TextStyle(fontWeight: FontWeight.normal),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
