import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:intl/intl.dart';
import 'package:project/Controllers/firestore/DataBase.dart';
import 'package:project/locale_language/localization_delegate.dart';
import 'package:project/models/booking_car.dart';
import 'package:project/models/car.dart';
import 'package:project/models/rating_car.dart';
import 'package:project/models/users.dart';
import 'package:project/view/booking/booking_car.dart';
import 'package:project/view/details_screens/car_stream_rating.dart';
import '../../constants_colors.dart';

class CarsDetailsScreen extends StatefulWidget {
  final Cars car;

  CarsDetailsScreen({this.car});

  @override
  _CarsDetailsScreenState createState() => _CarsDetailsScreenState();
}

class _CarsDetailsScreenState extends State<CarsDetailsScreen>
    with SingleTickerProviderStateMixin {
  DateTime startOfLease;
  DateTime endOfLease;
  String startLease;
  String endLease;
  TabController _tabController;
  double priceOfDay;
  double numOfRating = 0;
  double updateNumOfRating = 0;
  int totalPrice;
  int duration;
  Timer timer;

  var _formKey = GlobalKey<FormState>();
  TextEditingController _addCommentController = TextEditingController();
  TextEditingController _updateCommentController = TextEditingController();
  OutlineInputBorder borderE = OutlineInputBorder(
    borderSide: BorderSide(
      color: primary200Color,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(50),
  );

  OutlineInputBorder borderF = OutlineInputBorder(
    borderSide: BorderSide(
      width: 2,
      color: primaryColor,
    ),
    borderRadius: BorderRadius.circular(50),
  );

  TextStyle _labelStyle = TextStyle(color: blackColor, inherit: true);

  int lines = 0;
  int currentPos = 0;
  Iterable<String> sliderImages = [];
  String carType;
  DateFormat format = DateFormat("HH:mm ");
  DateFormat format2 = DateFormat.yMd();
  DateTime time = DateTime.now();
  String timeReview;
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  CollectionReference travelerCollection = FirebaseFirestore.instance.collection('Travelers');
  CollectionReference carCollection = FirebaseFirestore.instance.collection("Cars");
  String username, photoUrl;
  String rateId;

  String currentUser = FirebaseAuth.instance.currentUser.uid;
  var isFav;
  // ignore: missing_return
  Stream<DocumentSnapshot> getData()  {
    try {
      travelerCollection.doc(currentUser).get().then((value) {
        username = value.data()["fullName"];
        photoUrl = value.data()["image"];
      });
    } catch (e) {
      print("${e.toString()}");
    }
  }

  Stream<List<CarRating>> getRate() {
    carCollection
        .doc(widget.car.id)
        .collection("CarRating").where("rateId",isEqualTo: currentUser)
        .snapshots()
        .listen((data) {
      data.docs.forEach((element) {
        if (element != null)
        {
          if(!mounted){
            return ;
          }
          setState(() {
            rateId = element.data()["rateId"];
            _updateCommentController.text=element.data()["comment"];
            updateNumOfRating=element.data()["rate"];
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 4, vsync: this);
    startOfLease = DateTime.now();
    endOfLease = DateTime.now().add(Duration(days: 1));

    sliderImages = widget.car.carPhotos.getRange(0, 3);
    carType = widget.car.carType;
    priceOfDay = widget.car.priceOfDay;
    timeReview = format.format(time);
    startLease = format2.format(startOfLease);
    endLease = format2.format(endOfLease);
    timer = Timer.periodic(Duration(microseconds: 500), (Timer t) {

      setState(() {
        duration = endOfLease.difference(startOfLease).inDays;
        totalPrice = (duration * priceOfDay).toInt();
      });
    });
    getData();
    isFav = widget.car.favCars.contains(currentUser);
    getRate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addCommentController.dispose();
    _updateCommentController.dispose();
    timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          _background(context),
          Scaffold(
            resizeToAvoidBottomInset: false,
            key: _scaffoldKey,
            backgroundColor: transparent,
            appBar: AppBar(
              title: Text(
                AppLocalization.of(context).getTranslated("details_title"),
                style: TextStyle(color: whiteColor),
              ),
              centerTitle: true,
              backgroundColor: transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: whiteColor),
                onPressed: () {
                  Navigator.pop(context,isFav);
                },
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 115,
                ),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: grey50Color,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: _bodyContent(context),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 168,
            right: AppLocalization.of(context).locale.languageCode == "ar"
                ? null
                : 25,
            left: AppLocalization.of(context).locale.languageCode == "ar"
                ? 25
                : null,
            child: MaterialButton(
              height: 25,
              minWidth: 25,
              color: whiteColor,
              onPressed: () {
                if (isFav) {
                  setState(() {
                    isFav=!isFav;
                    AppLocalization.of(context).locale.languageCode=="ar"? deleteFavoriteAr():deleteFavorite();
                  });
                } else {
                  setState(() {
                    isFav=!isFav;
                   AppLocalization.of(context).locale.languageCode=="ar"?addFavoriteAr() :addFavorite();
                  });
                }
              },
              child: isFav
                  ? Icon(
                Icons.favorite,
                color: redAccentColor,
                size: 30,
              )
                  : Icon(
                Icons.favorite_border_outlined,
                color: redAccentColor,
                size: 30,
              ),
              padding: EdgeInsets.all(14),
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _background(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider.builder(
            options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.4,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 1,
                aspectRatio: 2.0,
                initialPage: 0,
                scrollDirection: Axis.horizontal,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentPos = index;
                  });
                }),
            itemCount: sliderImages.length,
            itemBuilder: (BuildContext context, int itemIndex) {
              return MyImageView(widget.car.carPhotos[itemIndex]);
            }),
        Padding(
          padding: const EdgeInsets.only(top: 170),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildPageIndicator(sliderImages),
          ),
        ),
      ],
    );
  }

  Widget _bodyContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.car.carName,
              style: TextStyle(
                  color: pink600Color,
                  fontSize: 30,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: AppLocalization.of(context).locale.languageCode == "ar"
                ? const EdgeInsets.only(left: 20, right: 16, top: 5, bottom: 5)
                : const EdgeInsets.only(left: 16, right: 20, top: 5, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      (Icons.star_rate_rounded),
                      color: orangeColor,
                    ),
                    SizedBox(width: 2),
                    Text(
                      widget.car.carRate.toString(),
                      style: TextStyle(
                        color: grey700Color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_sharp,
                      color: deepPurpleColor,
                      size: 18,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      "${widget.car.carCountry}, ${widget.car.carCity}",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: grey700Color),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 0.12,
            child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              indicatorColor: primaryColor,
              unselectedLabelColor: grey800Color,
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
              labelStyle: TextStyle(fontWeight: FontWeight.w600),
              indicatorPadding:
              EdgeInsets.symmetric(vertical: 8, horizontal: 40),
              tabs: [
                Text(AppLocalization.of(context)
                    .getTranslated("text_about_details")),
                Text(AppLocalization.of(context)
                    .getTranslated("text_overview")),
                Text(
                    AppLocalization.of(context).getTranslated("text_photos")),
                Text(AppLocalization.of(context)
                    .getTranslated("text_reviews")),
              ],
            ),
          ),
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding:
                        AppLocalization.of(context).locale.languageCode ==
                            "ar"
                            ? const EdgeInsets.only(left: 23, right: 32)
                            : const EdgeInsets.only(left: 32, right: 23),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalization.of(context)
                                      .getTranslated("text_start_of_lease"),
                                  style: TextStyle(
                                      color: blackColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  child: Row(
                                    children: [
                                      Text(
                                        "${startOfLease.day} - ${startOfLease.month} - ${startOfLease.year}",
                                        style: TextStyle(
                                            color: grey700Color,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: grey700Color,
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      pickDateStart();
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalization.of(context)
                                      .getTranslated("text_end_of_lease"),
                                  style: TextStyle(
                                      color: blackColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  child: Row(
                                    children: [
                                      Text(
                                        "${endOfLease.day} - ${endOfLease.month} - ${endOfLease.year}",
                                        style: TextStyle(
                                            color: grey700Color,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: grey700Color,
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      pickDateEnd();
                                    });
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalization.of(context)
                                      .getTranslated("text_duration"),
                                  style: TextStyle(
                                      color: blackColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "$duration" +
                                      " " +
                                      AppLocalization.of(context)
                                          .getTranslated("text_days"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: grey700Color),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalization.of(context)
                                      .getTranslated("text_price_of_day"),
                                  style: TextStyle(
                                      color: blackColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${widget.car.priceOfDay.toInt()}" +  '${AppLocalization.of(context).locale.languageCode=="ar"?"\جنيه":"\EGP"} ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: grey700Color),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalization.of(context)
                                      .getTranslated("text_car_type"),
                                  style: TextStyle(
                                      color: blackColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  widget.car.carType,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: grey700Color),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    child: Text(
                      widget.car.carOverview,
                      style: TextStyle(color: grey700Color, fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 30, right: 30),
                  child: GridView.count(
                    crossAxisCount: 3,
                    children:
                    List.generate(widget.car.carPhotos.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: FullScreenWidget(
                          child: Hero(
                            tag: "image$index",
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                width: 60,
                                height: 60,
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: widget.car.carPhotos[index],
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 25, right: 17),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.50,
                              child: Text(
                                AppLocalization.of(context)
                                    .getTranslated("text_ques_car"),
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: primaryColor),
                              ),
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              _showReview();
                            },
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                            child: Container(
                              width:rateId == currentUser? MediaQuery.of(context).size.width * 0.3:MediaQuery.of(context).size.width * 0.25,
                              child: rateId == currentUser
                                  ? Text(
                                AppLocalization.of(context)
                                    .getTranslated("text_update_review"),
                                style: TextStyle(color: pink600Color),
                              )
                                  : Text(
                                AppLocalization.of(context)
                                    .getTranslated("text_add_review"),
                                style: TextStyle(color: pink600Color),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      CarRatingStream(
                        carId: Cars(id: widget.car.id),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      '$totalPrice' +
                          AppLocalization.of(context).getTranslated("text_le"),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: pink600Color),
                    ),
                    Text(
                      AppLocalization.of(context)
                          .getTranslated("text_total_price"),
                      style: TextStyle(
                        color: grey800Color,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                  width: 170,
                  child: RaisedButton(
                    color: primaryColor,
                    colorBrightness: Brightness.dark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      AppLocalization.of(context).getTranslated("button_book"),
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 18,
                        letterSpacing: 1.1,
                      ),
                    ),
                    onPressed: () async {
                      AppLocalization.of(context).locale.languageCode=="ar"? await addDataAr():await addDataEn();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BookingCarScreen(
                                car: widget.car,
                                startOfBooking: startOfLease,
                                duration: duration,
                                carType: carType,
                                totalPrice: totalPrice,
                              )));
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  addDataEn() async {
    await DataBase().addBookingCar(
        BookingCar(
          bookingId: widget.car.id,
          duration: duration,
          carType: carType,
          totalPrice: totalPrice,
          startOfLease: startLease,
          endOfLease: endLease,
          carName: widget.car.carName,
          carPhoto: widget.car.carPhotos[0],
          paid: false,
        ),
        Travelers(
          id: currentUser,
        ));
  }

  addDataAr() async {
    await DataBase().addBookingCarAr(
        BookingCar(
          bookingId: widget.car.id,
          duration: duration,
          carType: carType,
          totalPrice: totalPrice,
          startOfLease: startLease,
          endOfLease: endLease,
          carName: widget.car.carName,
          carPhoto: widget.car.carPhotos[0],
          paid: false,
        ),
        Travelers(
          id: currentUser,
        ));
  }

  Future addReview() async {
    await DataBase().addRatingCar(
        CarRating(
          rateId: currentUser,
          comment: _addCommentController.text,
          rate: numOfRating,
          timeStamp: timeReview,
          username: username,
          photoUrl: photoUrl,
        ),
        Travelers(
          id: currentUser,
        ),
        Cars(
          id: widget.car.id,
        ));
  }

  Future updateReview() async {
    await DataBase().updateRatingCar(
        CarRating(
          rateId: currentUser,
          comment: _updateCommentController.text,
          rate: updateNumOfRating,
          timeStamp: timeReview,
          username: username,
          photoUrl: photoUrl,
        ),
        Travelers(
          id: currentUser,
        ),
        Cars(
          id: widget.car.id,
        ));
  }

  List<Widget> _buildPageIndicator(images) {
    List<Widget> list = [];
    for (int i = 0; i < images.length; i++) {
      list.add(i == currentPos ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? whiteColor : grey500Color,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Future<DateTime> pickDateStart() async {
    final DateTime dateStart = await showDatePicker(
      context: context,
      initialDate: startOfLease,
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (dateStart != null) {
      setState(() {
        startOfLease = dateStart;
      });
    }
    return dateStart;
  }

  Future<DateTime> pickDateEnd() async {
    DateTime dateEnd = await showDatePicker(
      context: context,
      initialDate: endOfLease,
      firstDate: DateTime.now().add(Duration(days: 1)).subtract(Duration(days: 0)),
      lastDate: DateTime(DateTime.now().year + 10),

    );
    if (dateEnd != null) {
      setState(() {
        endOfLease = dateEnd;
      });
    }
    return dateEnd;
  }

  void _showReview() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        ),
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 10,
                right: 10,
                top: 10,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${AppLocalization.of(context).getTranslated("text_share_ex")}  ${widget.car.carName}",
                              style: TextStyle(
                                  color: blackColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            Text(
                              AppLocalization.of(context)
                                  .getTranslated("text_help_ex"),
                              style: TextStyle(
                                  color: grey400Color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        color: grey700Color,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "${AppLocalization.of(context).getTranslated("text_rate")} ${widget.car.carName}:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RatingBar.builder(
                                initialRating: currentUser==rateId?updateNumOfRating:numOfRating,
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding:
                                EdgeInsets.symmetric(horizontal: 3.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  if(currentUser==rateId){
                                    setState(() {
                                      this.updateNumOfRating = rating;
                                    });
                                  }else{
                                    setState(() {
                                      this.numOfRating = rating;
                                    });
                                  }
                                },
                              ),
                              Text(
                                "${currentUser==rateId?updateNumOfRating:numOfRating} /5.0",
                                style: TextStyle(
                                    color: grey700Color, fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(
                        color: grey700Color,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        minLines: 1,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        maxLength: 300,
                        controller: currentUser==rateId?_updateCommentController:_addCommentController,
                        style: TextStyle(
                          color: blackColor,
                        ),
                        decoration: InputDecoration(
                          labelText: AppLocalization.of(context)
                              .getTranslated("text_your_review"),
                          labelStyle: _labelStyle,
                          prefixIcon: Icon(
                            Icons.rate_review,
                            color: primaryColor,
                          ),
                          fillColor: Colors.white,
                          focusedBorder: borderF,
                          enabledBorder: borderE,
                          border: borderE,
                          filled: true,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Enter Your Review";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                AppLocalization.of(context)
                                    .getTranslated("button_cancel_profile"),
                                style: TextStyle(color: redColor),
                              )),
                          FlatButton(
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  if(rateId==currentUser){
                                    await updateReview().then((_) {
                                      Navigator.pop(context);
                                      _scaffoldKey.currentState.showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Your Review Updated Success")));
                                    }).catchError((error) {
                                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                                          content: Text(
                                              "Your Review Updated Failed $error")));
                                    });
                                  }else{
                                    await addReview().then((_) {
                                      Navigator.pop(context);
                                      _addCommentController.clear();
                                      _scaffoldKey.currentState.showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Your Review Added Success")));
                                    }).catchError((error) {
                                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                                          content: Text(
                                              "Your Review Added Failed $error")));
                                    });
                                  }

                                }
                              },
                              child: currentUser == rateId
                                  ? Text(
                                "${AppLocalization.of(context).getTranslated("text_update_review")}",
                                style: TextStyle(color: primaryColor),
                              )
                                  : Text(
                                "${AppLocalization.of(context).getTranslated("text_add_review")}",
                                style: TextStyle(color: primaryColor),
                              ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future addFavorite() async {
    String currentUser = FirebaseAuth.instance.currentUser.uid;

    await DataBase().addFavoritesCar(
        carId:  widget.car.id,
        travellerId: currentUser
    );
  }

  Future deleteFavorite() async {
    String currentUser = FirebaseAuth.instance.currentUser.uid;

    await DataBase().removeFavoritesCar(
        carId:  widget.car.id,
        travellerId: currentUser
    );
  }

  Future addFavoriteAr() async {
    String currentUser = FirebaseAuth.instance.currentUser.uid;

    await DataBase().addFavoritesCarAr(
        carId:  widget.car.id,
        travellerId: currentUser
    );
  }

  Future deleteFavoriteAr() async {
    String currentUser = FirebaseAuth.instance.currentUser.uid;

    await DataBase().removeFavoritesCarAr(
        carId:  widget.car.id,
        travellerId: currentUser
    );
  }


}

class MyImageView extends StatelessWidget {
  String imgPath;

  MyImageView(this.imgPath);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CachedNetworkImage(
      fit: BoxFit.cover,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.4,
      imageUrl: imgPath,
      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
