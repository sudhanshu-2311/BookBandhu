import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:fluttertoast/fluttertoast.dart';


class ProductPage extends StatefulWidget {
  String product_name;
  String product_discountedPrice;
  String product_price;
  String ISBN;
  String imageURL;
  ProductPage(  {Key key, @required this.product_name, @required this.product_discountedPrice, this.product_price,@required this.ISBN, @required this.imageURL})
      : super(key: key);
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  User user=FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    CollectionReference products=FirebaseFirestore.instance.collection('Product').doc(widget.ISBN).collection('Extra Details');
    return   ChangeNotifierProvider<group>(
      create: (_)=>group(),
      child: StreamBuilder<DocumentSnapshot>(
          stream: products.doc(widget.ISBN).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.connectionState == ConnectionState.waiting||snapshot.hasData!=true) {
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
            Map<String, dynamic> data = snapshot.data.data();
            return Scaffold(
                backgroundColor: Colors.grey,
                appBar: AppBar(
                  backgroundColor: Colors.blue,
                  title: Text('Pustak Boy'),
                  actions: [
                    IconButton(icon: Icon(Icons.share), onPressed: (){
                      String text='Checkout ${widget.product_name} by ${data['Author']} at such a low price ${widget.product_discountedPrice}';
                      Share.share(text);
                    }),
                  /*  IconButton(icon: Icon(Icons.shopping_cart), onPressed: (){
                      Navigator.push(context,  MaterialPageRoute(
                          builder: (context) =>   Cart()));
                    })*/
                  ]
                  ),
                body: Column(
                  children:<Widget> [
                    Padding(
                      padding: EdgeInsets.only(top: 32.0,left: 16.0
                      ),
                      child: Text(widget.product_name,
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Container(
                      height: 250.0,
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Hero(
                            tag: widget.ISBN,
                            child: CachedNetworkImage(
                              imageUrl: widget.imageURL,
                              placeholder: (context,url)=>Center(child: Container(height: 20.0, width: 20.0,child: CircularProgressIndicator())),
                              errorWidget: (context,url,error)=>Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(16.0),
                    child:Text('ISBN: ${widget.ISBN}'),),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                        child: Text('Author: ${data['Author']}',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500
                        ),)),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                        child: Text('Subject: ${data['Subject']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 25.0
                        ),
                        )),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                            children:<Widget>[ Text(widget.product_discountedPrice,
                              style: TextStyle(fontWeight: FontWeight.bold,
                                  fontSize: 40.0
                              ),
                            ),
                              Text(widget.product_price==null?'':widget.product_price,
                                style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  fontSize: 18.0
                                ),

                              )
                            ]
                        ),
                    ),
                    Consumer<group>(
                        builder:(_,groupVal,__) {
                          return RadioListTile(value: 'New', groupValue: groupVal.groupValue, onChanged: (current) {groupVal.groupValueChanged(current);
                          },
                            title: Text('New'),
                          );
                        }
                    ),
                    Consumer<group>(
                        builder:(_,groupVal,__) {
                          return RadioListTile(value: 'Old', groupValue: groupVal.groupValue, onChanged: (current){ groupVal.groupValueChanged(current);
                          },
                            title: Text('Old'),
                          );
                        }
                    ),
                    Consumer<group>(
                        builder:(_,groupVal,__) {
                          return RadioListTile(value: 'Very Old', groupValue: groupVal.groupValue, onChanged: (current){ groupVal.groupValueChanged(current);
                          },
                            title: Text('Very '
                                'Old'),
                          );
                        }
                    )
                ],
                ),
                bottomNavigationBar: FlatButton(
                  onPressed: () async {
                QuerySnapshot Book = await FirebaseFirestore
                    .instance
                    .collection('Users').doc(user.uid).collection('Cart').where(
                    'ISBN',isEqualTo: widget.ISBN).where('Quality',isEqualTo: Provider.of<group>(context,listen: false).groupValue).get();
                List<DocumentSnapshot> BookDocument = Book.docs;
                if(BookDocument.length==0){
                      await _firestore.collection('Users')
                          .doc(user.uid).collection('Cart').doc(widget.ISBN+Provider.of<group>(context,listen: false).groupValue)
                          .set({
                        'ISBN': widget.ISBN,
                        'Name': widget.product_name,
                        'Current Price': widget.product_discountedPrice,
                        'Quality': Provider.of<group>(context,listen: false).groupValue,
                        'Quantity': '1',
                        'imageURL': widget.imageURL
                      });
                      Fluttertoast.showToast(msg: 'Successful added to Cart');
                    }
                    else{
                      Fluttertoast.showToast(msg: 'Already added');
                    }
                  },
                  child: Text('Add to Cart'),
                  color: Colors.orange,
                ),
              );
          }
      ),
    );
  }
}

class group extends ChangeNotifier{
  String groupValue='New';
  void groupValueChanged(String current){
      groupValue=current;
      notifyListeners();
  }
}
