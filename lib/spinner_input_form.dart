import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double _defaultVerticalPadding = 0.0;
const double _defaultHorizontalPadding = 10.0;
const double _defaultIconSize = 20.0;

/// Spinner button style.
class SpinnerButtonStyle {
  /// Icon size.
  double size;

  /// Icon color.
  Color color;

  /// Icon.
  IconData icon;

  /// Constructor.
  SpinnerButtonStyle({this.size, this.color, this.icon});
}

class SpinnerInputForm extends StatefulWidget {
  /// Input form controller. (required)
  final TextEditingController controller;

  /// Widget width.
  final double width;

  /// Widget height.
  final double height;

  /// Padding.
  final EdgeInsets padding;

  /// Decoration.
  final BoxDecoration decoration;

  /// TextFormField Input availability. (default: true)
  final bool enabled;

  /// TextStyle for the TextFormField.
  final TextStyle textStyle;

  /// Increment button icon.
  final SpinnerButtonStyle upperButtonStyle;

  /// Decrement button icon.
  final SpinnerButtonStyle downerButtonStyle;

  /// On tap upper button function.
  final Function() onTapUpperButton;

  /// On tap downer button function.
  final Function() onTapDownerButton;

  /// Constructor.
  SpinnerInputForm({
    @required this.controller,
    this.width,
    this.height,
    this.padding,
    this.decoration,
    this.textStyle,
    this.enabled,
    this.upperButtonStyle,
    this.downerButtonStyle,
    this.onTapUpperButton,
    this.onTapDownerButton,
  });

  @override
  State<StatefulWidget> createState() => _SpinnerInputFormState();
}

class _SpinnerInputFormState extends State<SpinnerInputForm> {
  TextEditingController _controller;
  EdgeInsets _padding;
  BoxDecoration _decoration;
  SpinnerButtonStyle _upperButtonStyle;
  SpinnerButtonStyle _downerButtonStyle;
  Function() _onTapUpperButton;
  Function() _onTapDownerButton;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController(text: '0');

    _padding = widget.padding ??
        EdgeInsets.only(
          left: _defaultHorizontalPadding,
          right: _defaultHorizontalPadding,
          top: _defaultVerticalPadding,
          bottom: _defaultVerticalPadding,
        );

    _decoration = widget.decoration ??
        BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        );

    _upperButtonStyle = widget.upperButtonStyle ?? SpinnerButtonStyle();
    _upperButtonStyle.icon ??= Icons.arrow_drop_up;
    _upperButtonStyle.size ??= _defaultIconSize;
    _upperButtonStyle.color ??= Colors.black;

    _downerButtonStyle = widget.downerButtonStyle ?? SpinnerButtonStyle();
    _downerButtonStyle.icon ??= Icons.arrow_drop_down;
    _downerButtonStyle.size ??= _defaultIconSize;
    _downerButtonStyle.color ??= Colors.black;

    _onTapUpperButton = widget.onTapUpperButton ??
        () {
          var num = int.tryParse(_controller.text);
          if (num == null) {
            _controller.text = '0';
          } else {
            num++;
            _controller.text = num.toString();
          }
        };

    _onTapDownerButton = widget.onTapDownerButton ??
        () {
          var num = int.tryParse(_controller.text);
          if (num == null) {
            _controller.text = '0';
          } else {
            num--;
            _controller.text = num.toString();
          }
        };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: _padding,
      decoration: _decoration,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: TextFormField(
                controller: _controller,
                style: widget.textStyle,
                textAlign: TextAlign.center,
                enabled: widget.enabled,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              )),
          Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: InkWell(
                  child: Icon(
                    _upperButtonStyle.icon,
                    size: _upperButtonStyle.size,
                    color: _upperButtonStyle.color,
                  ),
                  onTap: () => setState(() {
                    _onTapUpperButton();
                  }),
                ),
              ),
              InkWell(
                child: Icon(
                  _downerButtonStyle.icon,
                  size: _downerButtonStyle.size,
                  color: _downerButtonStyle.color,
                ),
                onTap: () => setState(() {
                  _onTapDownerButton();
                }),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
