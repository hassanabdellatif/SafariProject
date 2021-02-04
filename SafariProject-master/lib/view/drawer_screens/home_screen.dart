import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/Controllers/firestore/DataBase.dart';
import 'package:project/constants_colors.dart';
import 'package:project/locale_language/localization_delegate.dart';
import 'package:project/models/Provider_Offset.dart';
import 'package:project/models/users.dart';
import 'package:project/view/hotel_stream_screen.dart';
import 'package:project/view/services_tabs_screens/service_screen.dart';
import 'package:project/view/tour_stream_screen.dart';
import 'package:provider/provider.dart';
import '../car_stream_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  
  //check page is display
  int selectedButtonIndex = 1;
  int checkIndex = 1;
  CollectionReference travelerCollection = FirebaseFirestore.instance.collection('Travelers');
  User firebaseUser;
  FirebaseAuth _auth=FirebaseAuth.instance;

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

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {

     getData();
    refreshList();
    super.initState();
  }
  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      getData();
    });

    return null;
  }
  @override
  Widget build(BuildContext context) {
    var providerType = Provider.of<ProviderOffset>(context);
    List<Map> categories = [
      {'name': AppLocalization.of(context).getTranslated("text_category1"), 'icon': FontAwesomeIcons.hotel},
      {'name': AppLocalization.of(context).getTranslated("text_category2"), 'icon': FontAwesomeIcons.snowboarding},
      {'name': AppLocalization.of(context).getTranslated("text_category3"), 'icon': Icons.directions_car_rounded}
    ];
    return WillPopScope(
      onWillPop: _onWillPop,
      child: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: AnimatedContainer (
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          transform: Matrix4.translationValues(
              providerType.xOffset, providerType.yOffset, 0)
            ..scale(providerType.scaleFactor),
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
          color: grey50Color,
              borderRadius:
                  BorderRadius.circular(providerType.isDrawerOpen ? 20 : 0.0)),
          child: GestureDetector(
            onTap: () {
              {
                if (providerType.isDrawerOpen) {
                  providerType.drawerClose();
                }
              }
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15,),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          providerType.isDrawerOpen
                              ? IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    size: 35,
                                    color: primaryColor,
                                  ),
                                  onPressed: () {
                                    AppLocalization.of(context).locale.languageCode=='ar'? providerType.drawerCloseAR():providerType.drawerClose();
                                  },
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.menu,
                                    size: 25,
                                    color: primaryColor,
                                  ),
                                  onPressed: () {
                                    AppLocalization.of(context).locale.languageCode=='ar'? providerType.drawerOpenAR():providerType.drawerOpen();
                                  }),
                          InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ProfileScreen();
                              }));
                            },
                            child: StreamBuilder<DocumentSnapshot>(
                              stream:getData(),
                              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                }
                                else if (snapshot.hasData) {
                                  var data = snapshot.data;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: CircleAvatar(
                                      radius: 27,
                                      backgroundColor: primaryColor,
                                      child: CircleAvatar(
                                        backgroundColor: whiteColor,
                                        radius: 25,
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              data["image"] == null
                                                  ? "https://png.pngtree.com/png-clipart/20190516/original/pngtree-users-vector-icon-png-image_3723374.jpg"
                                                  : data["image"]),
                                          radius: 23,
                                        ),
                                      ),
                                    ),
                                  );
                                }else
                                  return Center(child: CircularProgressIndicator(),);


                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          head(),
                          body(categories),
                          Swipe_Screen(checkIndex),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget head() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: getData(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {

                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else if (snapshot.hasData) {
                    var  data = snapshot.data;

                    return Text(
                      '${AppLocalization.of(context).getTranslated("text_hi")} ${data['fullName']}' + '!',
                      style: TextStyle(
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: grey900Color,
                      ),
                    );
                  }else
                    return Text("No Data");

                },
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                AppLocalization.of(context).getTranslated("text_find_your_service"),
                style: TextStyle(
                  fontSize: 25,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w500,
                  color: pink600Color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget body(categories) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (checkIndex == 1) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ServicesScreen(
                                selectedIndex: 0,
                              )));
                } else if (checkIndex == 2) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ServicesScreen(
                                selectedIndex: 1,
                              )));
                } else if (checkIndex == 3) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ServicesScreen(
                                selectedIndex: 2,
                              )));
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
               color: whiteColor,
              ),
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      AppLocalization.of(context).getTranslated("text_search"),
                      style: TextStyle(
                        color: grey500Color,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: grey50Color,
                      child: Icon(
                        Icons.search,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20
            ),
            child: Text(
              AppLocalization.of(context).getTranslated("text_categories"),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18,color: blackColor),
            ),
          ),
          Container(
            height: 110,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              //physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 15,),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        checkIndex = index + 1;
                        selectedButtonIndex = checkIndex;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: selectedButtonIndex == index + 1
                              ? deepPurpleColor
                              : whiteColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              categories[index]['icon'],
                              color: selectedButtonIndex == index + 1
                                  ? whiteColor
                                  : deepPurpleColor,
                              size: index == 0 ? 30 : 35,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                categories[index]['name'],
                                style: TextStyle(
                                  color: selectedButtonIndex == index + 1
                                      ? whiteColor
                                      : blackColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalization.of(context).getTranslated("text_most_popular"),
                  style: TextStyle(
                    color: blackColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (checkIndex == 1) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ServicesScreen(
                                      selectedIndex: 0,
                                    )));
                      } else if (checkIndex == 2) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ServicesScreen(
                                      selectedIndex: 1,
                                    )));
                      } else if (checkIndex == 3) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ServicesScreen(
                                      selectedIndex: 2,
                                    )));
                      }
                    });
                  },
                  child: Text(
                    AppLocalization.of(context).getTranslated("text_see_all"),
                    style: TextStyle(color: deepPurpleColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget Swipe_Screen(int index) {
    if (index == 1) {
      return HotelStream();
    } else if (index == 2) {
      return TourStream();
    } else if (index == 3) {
      return CarStream();
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit the App?'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () async {
                  exit(0);
                },
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
