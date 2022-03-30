import 'package:authentication_app/Drawer/OrderedBooks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class YourOrders extends StatefulWidget {
  @override
  _YourOrdersState createState() => _YourOrdersState();
}

class _YourOrdersState extends State<YourOrders> {
  User user=FirebaseAuth.instance.currentUser;
  CollectionReference users=FirebaseFirestore.instance.collection('Users');
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: users.doc(user.uid).collection('Your Orders').snapshots(),
          builder:
          (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
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
                    title: Text('Your Orders'),
                  ),
                  body: snapshot.data.docs.length==0?Center(child: Text('You have not Ordered Yet!!!', style: TextStyle(fontSize: 24.0),)): ListView(
                    children: snapshot.data.docs.map((DocumentSnapshot document) {
                      return OrderedBooks(OrderID: document.reference.id, Status: document['Status'],Date: document['Date'], Address: document['Address']);
                    }).toList(),
                  ),
                  );
            }
          }
          );
  }
}

/* ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return OrderedBooks(OrderID: snapshot.data.docs[index].reference.id, Status: snapshot.data.docs[index].get('Status'), Date: snapshot.data.docs[index].get('Date'), Address: snapshot.data.docs[index].get('Address'));
                      }
                  )
   ListView(
                    children: snapshot.data.docs.map((DocumentSnapshot document) {
                      return OrderedBooks(OrderID: document.reference.id, Status: document['Status'],Date: document['Date'], Address: document['Address']);
                    }).toList(),
                  ),
                  */