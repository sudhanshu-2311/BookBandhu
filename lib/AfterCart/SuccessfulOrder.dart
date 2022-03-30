import 'package:authentication_app/WelcomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SuccessfulOrder extends StatelessWidget {
  String OrderID;
  SuccessfulOrder(
      {Key key, @required this.OrderID})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 100.0),
                child: Center(
                  child: Text('Order Successfully Placed',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w500
                  ),
                  ),
                ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: ClipOval(
                child: Container(
                  width: 160.0,
                  height: 160.0,
                  color: Colors.green,
                  child: Icon(Icons.check,
                    size: 80.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 80.0),
              child: Text('Order ID: $OrderID',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: FlatButton(
                height: 60.0,
                color: Colors.orange,
                  onPressed: (){
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) =>WelcomeScreen()),
                            (Route<dynamic> route) => false
                    );
                  },
                  child: Text('Move to Home Screen')),
            )
          ],
        ),
      ),
    );

  }
}

