import 'package:authentication_app/HomePageThings/GridPageSingleProduct.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class GridItemList extends StatefulWidget {
  @override
  _GridItemListState createState() => _GridItemListState();
}

class _GridItemListState extends State<GridItemList> {
  @override
  Widget build(BuildContext context) {
    CollectionReference products = FirebaseFirestore.instance.collection('Product');
    return StreamBuilder<QuerySnapshot>(
        stream: products.snapshots(),
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
            return GridView.builder(
                itemCount: snapshot.data.docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (BuildContext context, int index) {
                  return GridPageSingleProduct(product_name: snapshot.data.docs[index].get('Name'),
                      product_discountedPrice: snapshot.data.docs[index].get('Discounted Price'),
                      product_price: snapshot.data.docs[index].get('Price'),
                  ISBN: snapshot.data.docs[index].get('ISBN'),
                  imageURL: snapshot.data.docs[index].get('imageURL'),);
                });
    }
        }
    );
  }
  }
