import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/Controllers/firestore/DataBase.dart';
import 'package:project/constants_colors.dart';
import 'package:project/models/users.dart';

import '../../../locale_language/localization_delegate.dart';
import '../profile_screen.dart';
import 'car_notification.dart';
import 'hotel_notification.dart';
import 'tour_notification.dart';


class NotificationScreen extends StatefulWidget {
  int index=0;
 final String payload;


  NotificationScreen({this.index, this.payload,});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin{

  TabController _tabController;
  User firebaseUser;
  FirebaseAuth _auth = FirebaseAuth.instance;
  // ignore: missing_return
  Stream<DocumentSnapshot> getData()  {
    try {
      if (_auth.currentUser != null) {
        firebaseUser = _auth.currentUser;
      }
      return DataBase().getTraveler(Travelers(id: firebaseUser.uid));
    } catch (e) {
      print("${e.toString()}");
    }
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: widget.index, length: 3, vsync: this);
    getData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalization.of(context).getTranslated("notification_title"),
          style: TextStyle(
              color: blackColor, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        backgroundColor: grey50Color,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProfileScreen();
              }));
            },
            child: Padding(
              padding: AppLocalization.of(context).locale.languageCode=='ar'? const EdgeInsets.only(left: 10, top: 6) : const EdgeInsets.only(right: 10, top: 6),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: primaryColor,
                child: CircleAvatar(
                  backgroundColor: whiteColor,
                  radius: 23,
                  child: StreamBuilder<DocumentSnapshot>(
                      stream: getData(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text(snapshot.error);
                        } else if (snapshot.hasData) {
                          var data=snapshot.data;
                          return CircleAvatar(
                            backgroundImage: NetworkImage(data["image"] ==
                                null
                                ? "https://png.pngtree.com/png-clipart/20190516/original/pngtree-users-vector-icon-png-image_3723374.jpg"
                                : data["image"]),
                            radius: 21.5,
                          );
                        }else
                          return Text("No Data");
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height*0.10,
            width: MediaQuery.of(context).size.width,
            child: TabBar(
              indicatorPadding:
              EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              controller: _tabController,
              labelColor: primaryColor,
              indicatorColor: primaryColor,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelColor: grey600Color,
              tabs: [
                Text(AppLocalization.of(context).getTranslated("text_tab1_notification")),
                Text(AppLocalization.of(context).getTranslated("text_tab2_notification")),
                Text(AppLocalization.of(context).getTranslated("text_tab3_notification")),
              ],
            ),
          ),
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                HotelsNotifications(),
                ToursNotifications(),
                CarsNotifications(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}