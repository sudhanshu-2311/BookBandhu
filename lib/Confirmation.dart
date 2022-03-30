import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'WelcomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Confirmation extends StatefulWidget {
  String nameOfPerson;
  String emailadd;
  String number;
  String isVerifiedThrough;
  Confirmation(
      {Key key, @required this.nameOfPerson, @required this.emailadd, @required this.number,@required this.isVerifiedThrough})
      : super(key: key);

  @override
  _ConfirmationState createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
  final _form = GlobalKey<FormState>();
  bool isLoading=false;
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
                TextFormField(
                  onChanged: (value) {

                   widget.nameOfPerson = value;
                  },
                  textInputAction: TextInputAction.next,
                  initialValue: widget.nameOfPerson==null?'':widget.nameOfPerson,
                  validator: (String name) {
                    if (name.isEmpty||name.length<=2)
                      return 'Invalid Name';
                    else
                      return null;
                  },
                  keyboardType: TextInputType.name,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                Visibility(
                    visible: isLoading,
                    child: Center(
                      child: CircularProgressIndicator(),
                    )
                ),
                TextFormField(
                  onChanged: (value) {
                    widget.emailadd = value;
                  },
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.start,
                  initialValue:  widget.emailadd==null?'':widget.emailadd,
                  validator: (String email) {
                    if (EmailValidator.validate(email))
                      return null;
                    else
                      return 'Invalid Email';
                  },
                  decoration: InputDecoration(
                    hintText: 'Email',
                  ),
                ),
                TextFormField(
                  onChanged: (value) {
                    widget.number = value;
                  },
                  keyboardType: TextInputType.number,
                  initialValue: widget.number==null?'':widget.number,
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
                    color: Colors.orange,
                    child: Text('Register'),
                    onPressed: () async{
                      FocusScope.of(context).requestFocus(FocusNode());
                      FirebaseFirestore _firestore= FirebaseFirestore.instance;
                      User user = FirebaseAuth.instance.currentUser;
                      if (_form.currentState.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        QuerySnapshot numberRes = await FirebaseFirestore
                            .instance
                            .collection('Users').where(
                            'Number', isEqualTo: widget.number).get();
                        List<DocumentSnapshot> numberDocument = numberRes.docs;
                        QuerySnapshot emailRes = await FirebaseFirestore
                            .instance
                            .collection('Users').where(
                            'Email', isEqualTo: widget.emailadd).get();
                        List<DocumentSnapshot> emailDocument = emailRes.docs;
                        if (numberDocument.length == 0 &&
                            emailDocument.length == 0) {
                          await _firestore.collection('Users')
                              .doc(user.uid)
                              .set({
                            'Name': widget.nameOfPerson,
                            'Email': widget.emailadd,
                            'Number': widget.number,
                            'IsVerifiedThrough':widget.isVerifiedThrough
                          });
                            SharedPreferences preferences=await SharedPreferences.getInstance();
                              preferences.setString('Key', widget.emailadd);
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WelcomeScreen()),
                                  (Route<dynamic> route) => false
                          );
                        }
                        else
                          {
                            setState(() {
                              isLoading = false;
                            });
                            Fluttertoast.showToast(msg: 'Already Registered Email or Number' );
                          }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
