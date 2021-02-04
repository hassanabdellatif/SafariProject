import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/Controllers/firestore/DataBase.dart';
import 'package:project/constants_colors.dart';
import 'package:project/locale_language/localization_delegate.dart';
import 'package:project/models/hotel.dart';
import 'package:project/view/details_screens/hotel_details.dart';
import 'package:provider/provider.dart';
import 'hotel_service.dart';

class HotelSearchStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Hotel>>.value(
      value: AppLocalization.of(context).locale.languageCode=="ar"? DataBase().getAllHotelsAr:DataBase().getAllHotels,
      catchError: (_, err) => throw Exception(err),
      child: HotelsService(),
    );
  }
}

class hotelSearch extends StatefulWidget {
  List<Hotel> hotelList;

  hotelSearch({@required this.hotelList});



  @override
  _hotelSearchState createState() => _hotelSearchState();
}

class _hotelSearchState extends State<hotelSearch> {


  @override
  Widget build(BuildContext context) {
    String currentUser = FirebaseAuth.instance.currentUser.uid;

    return Expanded(
      child: ListView.builder(
          itemCount:
              widget.hotelList != null && widget.hotelList.length > 0 ? widget.hotelList.length : 0,
          itemBuilder: (context, index) {
            final Hotel currentHotel = widget.hotelList[index];
            var isFav = currentHotel.favHotels.contains(currentUser);

            return Padding(
              padding: const EdgeInsets.only(top: 15),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HotelsDetailsScreen(hotel: currentHotel,)));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                            left: AppLocalization.of(context)
                                        .locale
                                        .languageCode ==
                                    "ar"
                                ? Radius.circular(0)
                                : Radius.circular(15),
                            right: AppLocalization.of(context)
                                        .locale
                                        .languageCode ==
                                    "ar"
                                ? Radius.circular(15)
                                : Radius.circular(0),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(currentHotel.images[0]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: AppLocalization.of(context)
                                                  .locale
                                                  .languageCode ==
                                              "ar"
                                          ? EdgeInsets.only(right: 12, top: 12)
                                          : EdgeInsets.only(left: 12, top: 12),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width*0.45,
                                        child: AutoSizeText(
                                            currentHotel.hotelName,
                                            style: TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: AppLocalization.of(context)
                                              .locale
                                              .languageCode ==
                                          'ar'
                                      ? const EdgeInsets.only(right: 9,)
                                      : const EdgeInsets.only(left: 9, top: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_sharp,
                                        color: primaryColor,
                                        size: 16,
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.45,
                                        child: AutoSizeText(
                                          "${currentHotel.hotelCountry}, ${currentHotel.hotelCity}",
                                          style: TextStyle(),
                                          maxLines: 1,
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: AppLocalization.of(context)
                                              .locale
                                              .languageCode ==
                                          "ar"
                                      ? const EdgeInsets.only(right: 12, top: 4)
                                      : const EdgeInsets.only(left: 12, top: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${currentHotel.priceOfDay.toInt()}' +
                                            '${AppLocalization.of(context).locale.languageCode=="ar"?" \جنيه":" \EGP"} ',
                                        style: TextStyle(
                                          color: pink600Color.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: AppLocalization.of(context)
                                          .locale
                                          .languageCode ==
                                      "ar"
                                  ? const EdgeInsets.only(
                                      top: 12, bottom: 14, left: 12)
                                  : const EdgeInsets.only(
                                      top: 12, bottom: 16, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                  onTap: () {
                                    if(isFav){
                                      AppLocalization.of(context).locale.languageCode=="ar"?deleteFavoriteAr(currentHotel.hotelId) :deleteFavorite(currentHotel.hotelId);
                                    }else{
                                      AppLocalization.of(context).locale.languageCode=="ar"?addFavoriteAr(currentHotel.hotelId) :addFavorite(currentHotel.hotelId);
                                    }
                                  },
                                  child: Icon(
                                    Icons.favorite,
                                    color:isFav? redAccentColor:Colors.grey,
                                  ),
                                ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star_rate_rounded,
                                        size: 19,
                                        color: orangeColor,
                                      ),
                                      Text(
                                        '${currentHotel.hotelRate}',
                                        style: TextStyle(
                                            color: grey700Color,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              ),
            );
          }),
    );
  }
  Future addFavorite(hotelId) async {
    String currentUser = FirebaseAuth.instance.currentUser.uid;
    await DataBase().addFavoritesHotel(
        hotelId: hotelId,
        travellerId: currentUser
    );

  }

  Future deleteFavorite(hotelId) async {
    String currentUser = FirebaseAuth.instance.currentUser.uid;
    await DataBase().removeFavoritesHotel(
        hotelId: hotelId,
        travellerId: currentUser
    );
  }

  Future addFavoriteAr(hotelId) async {
    String currentUser = FirebaseAuth.instance.currentUser.uid;
    await DataBase().addFavoritesHotelAr(
        hotelId: hotelId,
        travellerId: currentUser
    );

  }

  Future deleteFavoriteAr(hotelId) async {
    String currentUser = FirebaseAuth.instance.currentUser.uid;
    await DataBase().removeFavoritesHotelAr(
        hotelId: hotelId,
        travellerId: currentUser
    );
  }
}
