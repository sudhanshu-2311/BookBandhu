import 'package:authentication_app/Confirmation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:authentication_app/WelcomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OTP extends StatefulWidget {
  final String number;


  OTP(
      {Key key, @required this.number})
      : super(key: key);

  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final _formstate = GlobalKey<FormState>();
  String smsCode;
  String verificationCode;
  FirebaseAuthException exception;
  FirebaseFirestore _firestore= FirebaseFirestore.instance;
  bool isLoading=false;
  FirebaseAuth _auth=FirebaseAuth.instance;

  @override
  void initState() {
    _letsbegin();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
        key: _formstate,
        child: Padding(
        padding: EdgeInsets.all(10),
           child: Container(
               child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    onChanged: (value) {
                     smsCode = value;
                      },
                    textInputAction: TextInputAction.done,
                     validator: (String name) {
                      if (smsCode != 6||exception.code=='invalid-verification-code')
                         return 'Invalid OTP';
                      else
                         return null;
                     },
                  keyboardType: TextInputType.number,
                   textAlign: TextAlign.start,
                   decoration: InputDecoration(
                    labelText: 'Enter OTP',
                 ),
                 ),
                  Visibility(
                      visible: isLoading,
                      child: Center(
                        child: CircularProgressIndicator(),
                      )
                  ),
                   FlatButton(
                     child: Text('Verify'),
                         color: Colors.blueAccent,
                         onPressed: () async {
                           setState(() {
                             isLoading = true;
                           });
                        FocusScope.of(context).requestFocus(FocusNode());
                        if(_formstate.currentState.validate()) {
                          PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider
                              .credential(verificationId: verificationCode,
                              smsCode: smsCode);
                          UserCredential result = await _auth
                              .signInWithCredential(phoneAuthCredential);
                          User user = result.user;
                          if (user != null) {
                            DocumentSnapshot documentSnapshot=await _firestore.collection('Users').doc(user.uid).get();
                            if(documentSnapshot.exists==true) {
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.pushAndRemoveUntil(context,
                                MaterialPageRoute(builder: (context) =>
                                    Confirmation(
                                        nameOfPerson: null, emailadd: null, number: widget.number,isVerifiedThrough: 'Mobile Number',)),
                                    (Route<dynamic> route) => false,
                              );
                            }
                            else
                            {
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.pushAndRemoveUntil(context,
                                  MaterialPageRoute(builder: (context) =>WelcomeScreen()),
                                      (Route<dynamic> route) => false
                              );
                              User user=FirebaseAuth.instance.currentUser;
                              DocumentSnapshot documentSnapshot= await _firestore.collection('Users').doc(user.uid).get();
                              Map<String, dynamic> data = documentSnapshot.data();
                              final SharedPreferences preferences=await SharedPreferences.getInstance();
                              preferences.setString('Key',data['Email']);
                            }
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            Fluttertoast.showToast(msg:'Some Error Occured');
                          }
                        }
                       }
                   ),
                      ],
                     ),
                    ),
                   ),
                 ),
                );
            }

      Future<void> _letsbegin() async
    {
    await _auth.verifyPhoneNumber(
    phoneNumber: '+91' + widget.number,
    timeout: Duration(seconds: 60),
    verificationCompleted: (PhoneAuthCredential credential) async {
    UserCredential result = await _auth.signInWithCredential(credential);
    User user = result.user;
    if (user != null) {
      setState(() {
        isLoading = true;
      });
      DocumentSnapshot documentSnapshot=await _firestore.collection('Users').doc(user.uid).get();
      if(documentSnapshot.exists!=true) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) =>
              Confirmation(
                  nameOfPerson: null, emailadd: null, number: widget.number,isVerifiedThrough: 'Mobile Number',)),
              (Route<dynamic> route) => false,
        );
      }
      else {
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
                (Route<dynamic> route) => false
        );

        User user=FirebaseAuth.instance.currentUser;
        DocumentSnapshot documentSnapshot= await _firestore.collection('Users').doc(user.uid).get();
        Map<String, dynamic> data = documentSnapshot.data();
        final SharedPreferences preferences=await SharedPreferences.getInstance();
        preferences.setString('Key',data['Email']);
      }
    }
    else {
      Fluttertoast.showToast(msg:'Some Error Occured');
    }
    },
    verificationFailed: (FirebaseAuthException e) {
      exception=e;
    if (e.code == 'invalid-verification-code') {
      Fluttertoast.showToast(msg:'Invalid Verification Code');
    }
    },
    codeSent: (String verificationId, int resendToken) {
    this.verificationCode = verificationId;
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      this.verificationCode = verificationId;
},
);
}
}

