import 'package:authentication_app/AfterCart/AddressBook.dart';
import 'package:authentication_app/AfterCart/OrderSummary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class askingForAddress extends StatefulWidget {
  int total;
  askingForAddress(
      {Key key, @required this.total})
      : super(key: key);

  @override
  _askingForAddressState createState() => _askingForAddressState();
}

class _askingForAddressState extends State<askingForAddress> {
  final _formstate = GlobalKey<FormState>();
  String address;
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
                    address=value;
                  },
                  textInputAction: TextInputAction.done,
                  validator: (String address) {
                    if (address.isEmpty)
                      return 'Address cannot be Empty';
                    else
                      return null;
                  },
                  keyboardType: TextInputType.name,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    labelText: 'Enter Home Address',
                  ),
                ),
                FlatButton(
                    child: Text('+  Add Address  +'),
                    color: Colors.blueAccent,
                    onPressed: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      if(_formstate.currentState.validate()) {
                        FirebaseFirestore _firestore = FirebaseFirestore
                            .instance;
                        User user = FirebaseAuth.instance.currentUser;
                        QuerySnapshot queryAddress = await FirebaseFirestore
                            .instance
                            .collection('Users').doc(user.uid).collection(
                            'Address Book').get();
                        List<DocumentSnapshot> AddressDocument = queryAddress
                            .docs;
                        await _firestore.collection('Users').doc(user.uid)
                            .collection('Address Book').doc()
                            .set({'Address Name': address,});
                        if (AddressDocument.length <2) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                                  OrderSummary(total: widget.total,address: address,))
                          );
                        }
                        else
                          Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (context) =>
                                AddressBook(total: widget.total,)),
                                (Route<dynamic> route) => false,
                          );
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
}
