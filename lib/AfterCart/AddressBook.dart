import 'package:authentication_app/AfterCart/OrderSummary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'AskingforAddress.dart';
class AddressBook extends StatefulWidget { 
  int total;
  AddressBook(
      {Key key, @required this.total})
      : super(key: key);

  @override
  _AddressBookState createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBook> {
  User user=FirebaseAuth.instance.currentUser;
  CollectionReference cart=FirebaseFirestore.instance.collection('Users');
  int groupValue= 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: cart.doc(user.uid).collection('Address Book').snapshots(),
        builder:
            (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting||snapshot.hasData!=true){
            return Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(backgroundColor: Colors.black,),
              ),
            );
          }
          else{
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.blue,
                  title: Text('Address Book'),
                ),
                body: ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Container(
                          color: Colors.grey,
                          child: RadioListTile(value: index,groupValue: groupValue ,onChanged: (value) {
                           setState(() {
                             groupValue = value;
                                });
                               },
                            title:Row(
                              children:<Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Text(snapshot.data.docs[index].get('Address Name'),
                              ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: FlatButton(
                                      color: Colors.blue,
                                      onPressed: () async {
                                    //    QuerySnapshot Address = await FirebaseFirestore.instance.collection('Users').doc(user.uid).collection('Address Book').where('Address Name',isEqualTo: snapshot.data.docs[index].get('Address Name')).get();
                                      // List<DocumentSnapshot> AddressDocument = Address.docs;   AddressDocument[index].id
                                        cart.doc(user.uid).collection('Address Book').doc().delete();
                                      },
                                      child: Text('Bye'),
                                    )
                                )
                          ]
                            ),
                          ),
                        ),
                      );
                    }
                      ),
                 bottomNavigationBar:Container(
                      color: Colors.orange,
                          child:ListTile(
                             leading: FlatButton(
                                onPressed: (){
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) =>
                                          askingForAddress(total: widget.total,))
                                  );
                            },
                              color: Colors.blue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                    child: Text('+ Add Address +'),
                          ),
                              trailing:FlatButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) =>
                                            OrderSummary(total: widget.total,address: snapshot.data.docs[groupValue].get('Address Name'),))
                                    );
                                   },
                                 color: Colors.blue,
                                   child: Text('Proceed'),
                            ),
                           )
                      ),
                    );
          }
        }
    );

  }
}
