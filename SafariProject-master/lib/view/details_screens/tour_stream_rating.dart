import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:project/Controllers/firestore/DataBase.dart';
import 'package:project/constants_colors.dart';
import 'package:project/locale_language/localization_delegate.dart';
import 'package:project/models/rating_tour.dart';
import 'package:project/models/tour.dart';
import 'package:project/models/users.dart';



class TourRatingStream extends StatelessWidget {
  final Tour tourId;
  TourRatingStream({this.tourId});

  @override
  Widget build(BuildContext context) {
    String currentUser = FirebaseAuth.instance.currentUser.uid;

    return StreamBuilder(
      stream: DataBase().getAllTourComment(tourId),
      builder:(context,AsyncSnapshot<List<TourRating>>snapshot){
        if(snapshot.hasData){
          return Expanded(
            child: ListView.builder(
              itemCount: snapshot.data != null && snapshot.data.length > 0 ? snapshot.data.length : 0,
              itemBuilder: (context, index) {
                final TourRating currentRate = snapshot.data[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: primaryColor,
                                child: CircleAvatar(
                                  backgroundColor: whiteColor,
                                  radius: 22,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        currentRate.photoUrl),
                                    radius: 20,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: AppLocalization.of(context)
                                              .locale
                                              .languageCode ==
                                              "ar"
                                              ? const EdgeInsets.only(
                                              right: 10)
                                              : const EdgeInsets.only(
                                              left: 10),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width *
                                                0.50,
                                            child: AutoSizeText(
                                              currentRate.username,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: pink600Color),
                                              softWrap: true,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: AppLocalization.of(context)
                                              .locale
                                              .languageCode ==
                                              "ar"
                                              ? const EdgeInsets.only(
                                              top: 2, right: 8)
                                              : const EdgeInsets.only(
                                              top: 2, left: 8),
                                          child: Row(
                                            children: [
                                              Icon(
                                                (Icons.star_rate_rounded),
                                                color: orangeColor,
                                                size: 20,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                currentRate.rate.toString(),
                                                style: TextStyle(
                                                    color: grey700Color,
                                                    fontWeight:
                                                    FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 30,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: Colors.red.withOpacity(0.1),
                                          ),
                                          height: 30,
                                          child: Icon(
                                            Icons.remove,
                                            color: redColor,
                                            size: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Align(
                              alignment: AppLocalization.of(context)
                                  .locale
                                  .languageCode ==
                                  "ar"
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Text(currentRate.comment),
                            ),
                          ),
                          Align(
                            alignment: AppLocalization.of(context)
                                .locale
                                .languageCode ==
                                "ar"
                                ? Alignment.bottomLeft
                                : Alignment.bottomRight,
                            child: Text(
                              currentRate.timeStamp,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: grey600Color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }else if(snapshot.hasError){
          return Text(snapshot.error.toString());
        }else
          return Center(child: CircularProgressIndicator());

      },
    );
  }
}