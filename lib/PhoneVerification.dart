import 'package:authentication_app/Confirmation.dart';
import 'package:authentication_app/OTPpage.dart';
import 'package:flutter/material.dart';
import 'package:authentication_app/WelcomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
class PhoneVerification extends StatefulWidget {
  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  bool isLoading=false;
  String number;
  final _form = GlobalKey<FormState>();
  bool register = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _form,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    MaterialButton(
                        color: register == true ? Colors.black : Colors.white,
                        textColor: register == true ? Colors.white : Colors
                            .black,
                        child: Text('Register'),
                        onPressed: () {
                          setState(() {
                            register = true;
                          });
                        }
                    ),
                    MaterialButton(
                        color: register == true ? Colors.white : Colors.black,
                        textColor: register == true ? Colors.black : Colors
                            .white,
                        child: Text('Login'),
                        onPressed: () {
                          setState(() {
                            register = false;
                          });
                        }
                    ),
                  ],
                ),
                Visibility(
                    visible: isLoading,
                    child: Center(
                      child: CircularProgressIndicator(),
                    )
                ),
                TextFormField(
                  onChanged: (value) {
                    number = value;
                  },
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.start,
                  validator: (String no) {
                    if (no.length != 10)
                      return 'Invalid Number';
                    else
                      return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Mobile No.',
                  ),
                ),
                SizedBox(
                  height: 32.0,
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: MaterialButton(
                    color: Colors.green,
                    onPressed: () async {
                      setState(() {
                        isLoading=true;
                      });
                      FocusScope.of(context).requestFocus(FocusNode());
                      if (_form.currentState.validate()) {
                        QuerySnapshot res = await FirebaseFirestore.instance
                            .collection('Users').where(
                            'Number', isEqualTo: number).get();
                        List<DocumentSnapshot> documents = res.docs;
                        if (documents.length == 0) {
                          if (register == true) {
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      OTP(
                                          number: number)),
                                  (Route<dynamic> route) => false,
                            );
                          }
                          else {
                            setState(() {
                              isLoading=false;
                            });
                            Fluttertoast.showToast(
                                msg: 'Not a Registered Number');
                          }
                        }
                        else {
                          if (register == true) {
                            setState(() {
                              isLoading=false;
                            });
                            Fluttertoast.showToast(
                                msg: 'Already a Existed Number,Try Login');
                          }else {
                            setState(() {
                              isLoading=false;
                            });
                            Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      OTP(
                                          number: number)),
                                  (Route<dynamic> route) => false,
                            );
                          }
                        }
                      }
                    },
                    child: Text('Send OTP'),
                  ),
                ),
                SizedBox(
                  height: 64.0,
                ),
                Divider(
                  thickness: 1.0,
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: MaterialButton(
                    color: Colors.blue,
                    onPressed: () {
                      _signInWithGoogle();
                    },
                    child: register == true
                        ? Text('Register with Google')
                        : Text('Login with Google'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      isLoading=true;
    });
    FirebaseAuth _firebase = FirebaseAuth.instance;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final GoogleSignInAccount googleSignInAccount = await GoogleSignIn()
        .signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount
        .authentication;
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    final UserCredential authResult = await _firebase.signInWithCredential(
        credential);
    final User user = authResult.user;
    if (user != null) {
      DocumentSnapshot documentSnapshot = await _firestore.collection('Users')
          .doc(user.uid)
          .get();
      if (documentSnapshot.exists != true) {
        if (register == true) {
          setState(() {
            isLoading = false;
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) =>
                Confirmation(nameOfPerson: user.displayName,
                    emailadd: user.email,
                    number: user.phoneNumber,isVerifiedThrough: 'Google Email',)),
                (Route<dynamic> route) => false,
          );
        }
        else {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'First Register Urself');
        }
      }
      else {
        if (register == true) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'Already Registered, Try to Login');
        }else {
          setState(() {
            isLoading=true;
          });
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  (Route<dynamic> route) => false
          );
          User user=FirebaseAuth.instance.currentUser;
          DocumentSnapshot documentSnapshot= await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
          Map<String, dynamic> data = documentSnapshot.data();
          final SharedPreferences preferences=await SharedPreferences.getInstance();
          preferences.setString('Key',data['Email']);
        }
      }
    }

    else {
      Fluttertoast.showToast(msg: 'Some Error Occured');
    }
  }
  }



