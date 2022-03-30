import 'package:authentication_app/AfterCart/SuccessfulOrder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class OrderSummary extends StatefulWidget {
  int total;
  String address;
  OrderSummary(
      {Key key, @required this.total,@required this.address})
      : super(key: key);

  @override
  _OrderSummaryState createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  User user = FirebaseAuth.instance.currentUser;
  CollectionReference cart = FirebaseFirestore.instance.collection('Users');
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  int totalBooks=0;
  @override
  void initState() {
    getTotalBooks();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: cart.doc(user.uid).collection('Cart').snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasData != true) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,),
              ),
            );
          }
          else {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.blue,
                title: Text('Order Summary'),
              ),
              body:
                Column(
                        children:<Widget>[
                          Container(
                            width: double.infinity,
                            color: Colors.grey,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding:EdgeInsets.only(top: 16.0),
                                    child: Text('Delivering to your Address:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300
                                    ),
                                    )
                          ),
                                Padding(
                                    padding:EdgeInsets.all(16.0),
                                    child: Text(widget.address,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500
                                    ),
                                    )
                                ),
                              ],
                            )
                          ),
                         Padding(
                             padding: EdgeInsets.all(16.0),
                             child: Text('Your items are:',
                               style: TextStyle(
                                 fontWeight: FontWeight.w300
                               ),
                             ),
                         ),
                       Expanded(
                         flex: 10,
                         child: ListView(
                             scrollDirection: Axis.vertical ,
                             children: snapshot.data.docs.map((DocumentSnapshot document) {
                               return ListTile(
                                 leading: Text(document.data()['Quantity']),
                                 title: Text(document.data()['Name']),
                                 subtitle: Text(document.data()['Quality']),
                                 trailing: Text(document.data()['Current Price']),
                               );
                             }).toList(),
                    ),
                       ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Total Price: ${widget.total}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Total Fees:${widget.total<600?45:0}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Grant Total:${widget.total<600?widget.total+45:widget.total}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w300
                                ),
                              ),
                            ),
                          )
                    ],
                    ),
              bottomNavigationBar: Container(
                 color: Colors.orange,
                  child:ListTile(
                     trailing: FlatButton(
                        onPressed: () async{
                          DocumentSnapshot documentSnapshot= await _firestore.collection('Users').doc(user.uid).get();
                          Map<String, dynamic> data = documentSnapshot.data();
                          DateTime DateTi=DateTime.now();
                          String now=DateFormat('yyMMddhhmmss').format(DateTi);
                          String Date=DateFormat('dd-MM-yy').format(DateTi);
                          String uid=user.uid;
                          String removed=uid.replaceAll(RegExp(r'[^0-9]'),'');
                          await _firestore.collection('Orders').doc(now+removed).set({
                            'Status': 'Pending',
                            'Date': Date,
                            'User ID': user.uid,
                            'Address': widget.address,
                            'User Name': data['Name'],
                            'Number': data['Number'],
                            'Total': widget.total<600?widget.total+45:widget.total,
                            'Number of Items':totalBooks
                          });
                          await _firestore.collection('Users').doc(uid).collection('Your Orders').doc(now+removed).set({
                            'Status': 'Pending',
                            'Date': Date,
                            'Address': widget.address,
                          });
                           FirebaseFirestore.instance.collection('Users').doc(user.uid).collection('Cart').get().then((QuerySnapshot querysnapshot){
                             querysnapshot.docs.forEach((doc) async {
                               await _firestore.collection('Orders').doc(now+removed).collection('Ordered Books').doc(doc.reference.id).set({
                                 'ISBN': doc['ISBN'],
                                 'Name': doc['Name'],
                                 'Price': doc['Current Price'],
                                 'Quality': doc['Quality'],
                                 'Quantity': doc['Quantity'],
                                 'imageURL': doc['imageURL']
                               });
                               await _firestore.collection('Users').doc(uid).collection('Your Orders').doc(now+removed).collection('Ordered Books').doc(doc.reference.id).set({
                                 'ISBN': doc['ISBN'],
                                 'Name': doc['Name'],
                                 'Price': doc['Current Price'],
                                 'Quality': doc['Quality'],
                                 'Quantity': doc['Quantity'],
                                 'imageURL': doc['imageURL']
                               });
                             });
                          });
                          Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (context) =>SuccessfulOrder(OrderID: now+removed,)),
                                  (Route<dynamic> route) => false
                          );
                          cart.doc(user.uid).collection('Cart')
                              .get()
                              .then((QuerySnapshot querySnapshot) {
                            querySnapshot.docs.forEach((doc) {
                              cart.doc(user.uid).collection('Cart').doc(doc.reference.id).delete();
                            });
                          });
                          },
                        color: Colors.blue,
                          child: Text('Make Payment'),
              ),
              ),
              ),
            );
          }
        }
    );
  }
  Future<String> getTotalBooks() async{
    QuerySnapshot documentBooks= await FirebaseFirestore.instance.collection('Users').doc(user.uid).collection('Cart').get();
    documentBooks.docs.forEach((document) {
      Map<String, dynamic> data = document.data();
      setState(() {
        totalBooks = totalBooks + int.parse(data['Quantity']);
      });
    });
  }
}
