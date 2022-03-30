import 'package:authentication_app/Drawer/OrderDetail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderedBooks extends StatefulWidget {
  String OrderID;
  String Status;
  String Date;
  String Address;
  OrderedBooks(
      {Key key, @required this.OrderID, @required this.Status, @required this.Date, @required this.Address})
      : super(key: key);

  @override
  _OrderedBooksState createState() => _OrderedBooksState();
}

class _OrderedBooksState extends State<OrderedBooks> {
  User user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('Users');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: users.doc(user.uid).collection('Your Orders').doc(
            widget.OrderID).collection('Ordered Books').snapshots(),
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
            return ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white30,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                            children: [
                              ListTile(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) =>
                                            OrderDetail(OrderID: widget.OrderID,
                                              Date: widget.Date,
                                              Status: widget.Status,
                                              Address: widget.Address,
                                              Bookname: snapshot.data
                                                  .docs[index].get('Name'),
                                              Quality: snapshot.data.docs[index]
                                                  .get('Quality'),
                                              Quantity: snapshot.data
                                                  .docs[index].get('Quantity'),
                                              imageURL: snapshot.data
                                                  .docs[index].get('imageURL'),
                                              Price: snapshot.data.docs[index]
                                                  .get('Price'),
                                            ))
                                    );
                                  },
                                  leading: CachedNetworkImage(
                                    imageUrl: snapshot.data.docs[index].get(
                                        'imageURL'),
                                    placeholder: (context, url) =>
                                        Center(child: Container(height: 20.0,
                                            width: 20.0,
                                            child: CircularProgressIndicator())),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                  title: Text(
                                      '${widget.Status},Ordered on ${widget
                                          .Date}'),
                                  subtitle: Text(
                                      snapshot.data.docs[index].get('Name'))
                              ),
                              MaterialButton(
                                minWidth: double.infinity,
                                color: Colors.orange,
                                onPressed: () {

                                },
                                child: Text(widget.Status),
                              )
                            ]
                        ),
                      ),
                    ),
                  );
                }
            );
          }
        }
    );
  }
}
/*ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white30,
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                                  OrderDetail())
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: ListTile(
                              leading: Image.network(snapshot.data.docs[index].get('imageURL')),
                              title: Text(widget.OrderID),
                              subtitle: Text(snapshot.data.docs[index].get('Name'))
                          ),
                        ),
                      ),
                    ),
                  );
                }
            );*/