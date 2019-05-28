import 'package:flutter/material.dart';

class EggTimerButton extends StatelessWidget {

  final IconData iconData;
  final String text;
  final Function() onPressed;
  final Color backgroundColor;

  const EggTimerButton({this.iconData, this.text, this.onPressed, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: backgroundColor,
      splashColor: Color(0x22000000),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: Icon(
                iconData,
                color: Colors.black,
              ),
            ),
            Text(text,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0))
          ],
        ),
      ),
    );
  }
}
