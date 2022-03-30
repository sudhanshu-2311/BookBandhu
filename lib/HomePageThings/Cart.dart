import 'package:authentication_app/AfterCart/AddressBook.dart';
import 'package:authentication_app/AfterCart/AskingforAddress.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../ProductPage.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  int total=0;
  User user=FirebaseAuth.instance.currentUser;
  CollectionReference cart=FirebaseFirestore.instance.collection('Users');
  @override
  void initState() {
    getTotal();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: cart.doc(user.uid).collection('Cart').snapshots(),
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
                title: Text('Cart'),
              ),
              body:  snapshot.data.docs.length==0?Center(child: Text('Your Cart is Empty!!!', style: TextStyle(fontSize: 24.0),)):ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.all(12.0),
                         child: Container(
                         color: Colors.grey,
                          child: Column(
                           children: <Widget>[
                             InkWell(
                               onTap: (){
                                Navigator.push(context,   MaterialPageRoute(builder: (context) =>
                                ProductPage(product_name: snapshot.data.docs[index].get('Name'),product_discountedPrice: snapshot.data.docs[index].get('Current Price'),ISBN: snapshot.data.docs[index].get('ISBN'),imageURL: snapshot.data.docs[index].get('imageURL'),)));
                                  },
                                   child: ListTile(
                                    leading: Icon(Icons.book,
                                     size: 35.0,
                                    ),
                                     title: Text(snapshot.data.docs[index].get('Name'),
                                       style: TextStyle(
                                         fontWeight: FontWeight.bold
                                       ),
                                     ),
                                      subtitle: Text(snapshot.data.docs[index].get('Quality')),
                                       trailing: Text(snapshot.data.docs[index].get('Current Price'))
                                     ),
                                    ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: FlatButton(
                                                onPressed: () {
                                                  int decrease=0;
                                                  if (int.parse(snapshot.data.docs[index].get('Quantity')) > 1) {
                                                     decrease=int.parse(snapshot.data.docs[index].get('Quantity'))-1;
                                                    cart.doc(user.uid).collection('Cart').doc(snapshot.data.docs[index].get('ISBN')+snapshot.data.docs[index].get('Quality')).update({'Quantity': decrease.toString()});
                                                     setState(() {
                                                       total=total-int.parse(snapshot.data.docs[index].get('Current Price'));
                                                     });
                                                  }
                                                },
                                                color: Colors.blue,
                                                child: Text('-')
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(2.0),
                                              child: Text('Quantity:   ${snapshot.data.docs[index].get('Quantity')}')),
                                          Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: FlatButton(
                                                onPressed: (){
                                                 if (int.parse(snapshot.data.docs[index].get('Quantity')) < 5) {
                                                   int increase=0;
                                                   increase=int.parse(snapshot.data.docs[index].get('Quantity'))+1;
                                                   print(increase);
                                                   cart.doc(user.uid).collection('Cart').doc(snapshot.data.docs[index].get('ISBN') + snapshot.data.docs[index].get('Quality')).update({'Quantity': increase.toString()});
                                                   setState(() {
                                                     total=total+int.parse(snapshot.data.docs[index].get('Current Price'));
                                                   });
                                                }
                                                 },
                                                color: Colors.blue,
                                                child: Text('+')
                                            ),
                                          ),
                                        ],
                                      ),
                                  Padding(
                                   padding: EdgeInsets.only(left: 16.0, right: 16.0),
                                    child: FlatButton(
                                     onPressed: () async {
                                         setState(() {
                                           total = total - (int.parse(snapshot.data.docs[index].get('Current Price')) *int.parse(snapshot.data.docs[index].get('Quantity')));
                                         });
                                      cart.doc(user.uid).collection('Cart').doc(snapshot.data.docs[index].get('ISBN')+snapshot.data.docs[index].get('Quality')).delete();
                                         },
                                      minWidth: double.infinity,
                                      color: Colors.orange,
                                       child: Text('Remove'),
                                         ),
                                        )
                                      ]
                                     )
                                    ),
                                  );
                                }
                  ),
                bottomNavigationBar:
                Container(
                  color: Colors.orange,
                  child: ListTile(
                    leading: Icon(Icons.money),
                    title: Text('Total Amount'),
                    subtitle: Text(total.toString()),
                    trailing: FlatButton(
                      onPressed: () async {
                        QuerySnapshot addressAvailable = await FirebaseFirestore
                            .instance
                            .collection('Users').doc(user.uid).collection('Address Book').get();
                        List<DocumentSnapshot> AddressDocument = addressAvailable.docs;
                        if(total>100) {
                          if (AddressDocument.length == 0)
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                    askingForAddress(total: total))
                            );
                          else
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                    AddressBook(total: total,))
                            );
                        }
                        else
                          Fluttertoast.showToast(msg: 'Total Cart Value must be greater than 100 for Ordering');
                      },
                      color: Colors.blue,
                      child: Text('Proceed'),
                    ),
                  ),
                )
              );
          }
        }
    );
  }
  Future<String> getTotal() async{
    QuerySnapshot documentsAddedtoCart= await FirebaseFirestore.instance.collection('Users').doc(user.uid).collection('Cart').get();
    documentsAddedtoCart.docs.forEach((document) {
      Map<String, dynamic> data = document.data();
        setState(() {
          total = total +
              int.parse(data['Current Price']) * int.parse(data['Quantity']);
          return total.toString();
        });
    });
  }
}
