import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OrderDetail extends StatefulWidget {
  String OrderID;
  String Status;
  String Date;
  String Address;
  String Bookname;
  String Quality;
  String Quantity;
  String imageURL;
  String Price;
  OrderDetail(
      {Key key, @required this.OrderID,@required this.Status,@required this.Date,@required this.Address, @required this.Bookname,@required this.Quality,@required this.Quantity,@required this.imageURL,@required this.Price})
      : super(key: key);
  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 24.0,right: 40.0),
            child: Text('Order ID: ${widget.OrderID}',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: Text('Ordered on ${widget.Date}',
              style: TextStyle(
                fontSize: 20.0
              ),)),
          Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text('Current Status: ${widget.Status}',
              style: TextStyle(
                fontSize: 16.0
              ),)),
          Padding(
              padding: EdgeInsets.only(top: 52.0,right:150),
              child: Card(
                color: Colors.orange,
                child: Text('Delivered to Address: ${widget.Address}',
                style: TextStyle(
                 fontSize: 20.0
                ),),
              )),
          Padding(
            padding: EdgeInsets.only(top: 32.0,left: 12.0,right: 12.0),
            child: Card(
              color: Colors.white30,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: widget.imageURL,
                          placeholder: (context,url)=>Center(child: Container(height: 20.0, width: 20.0,child: CircularProgressIndicator())),
                          errorWidget: (context,url,error)=>Icon(Icons.error),
                        ),
                        title: Text('${widget.Bookname}(${widget.Quality})'),
                          subtitle: Text('Quantity: ${widget.Quantity}'),
                          trailing: Text(widget.Price)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
