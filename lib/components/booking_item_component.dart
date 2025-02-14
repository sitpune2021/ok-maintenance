import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/components/assign_handyman_screen.dart';
import 'package:handyman_provider_flutter/screens/booking_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/color_extension.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/user_data.dart';
import '../networks/firebase_services/notification_service.dart';

class BookingItemComponent extends StatefulWidget {
  final String? status;
  final BookingData bookingData;
  final int? index;
  final bool showDescription;

  BookingItemComponent({this.status, required this.bookingData, this.index, this.showDescription = true});

  @override
  BookingItemComponentState createState() => BookingItemComponentState();
}

class BookingItemComponentState extends State<BookingItemComponent> {
  int page = 1;
  bool isLastPage = false;

  List<UserData> handymanList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  String buildTimeWidget({required BookingData bookingDetail}) {
    if (bookingDetail.bookingSlot == null) {
      return formatDate(bookingDetail.date.validate(), isTime: true);
    }
    return formatDate(getSlotWithDate(date: bookingDetail.date.validate(), slotTime: bookingDetail.bookingSlot.validate()), isTime: true);
  }

  // Future<void> updateBooking(BookingData booking, String updatedStatus, int index) async {
  //   appStore.setLoading(true);
  //   Map request = {
  //     CommonKeys.id: booking.id,
  //     BookingUpdateKeys.status: updatedStatus,
  //     BookingUpdateKeys.paymentStatus: booking.isAdvancePaymentDone ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID : booking.paymentStatus.validate(),
  //   };
  //   await bookingUpdate(request).then((res) async {
  //     setState(() {});
  //     // appStore.setLoading(false);
  //   }).catchError((e) {
  //     // appStore.setLoading(false);
  //   });
  // }

  ///  accept booking
  // Future<void> updateBooking(BookingData booking, String updatedStatus, int index) async {
  //   appStore.setLoading(true);
  //   Map request = {
  //     CommonKeys.id: booking.id,
  //     BookingUpdateKeys.status: updatedStatus,
  //     BookingUpdateKeys.paymentStatus: booking.isAdvancePaymentDone
  //         ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
  //         : booking.paymentStatus.validate(),
  //   };
  //
  //   await bookingUpdate(request).then((res) async {
  //     setState(() {});
  //
  //     // Send Notification on Booking Accepted
  //     if (updatedStatus == BookingStatusKeys.accept) {
  //       UserData receiverUser = UserData(
  //         id: booking.customerId.validate(),
  //         firstName: booking.customerName.validate(),
  //         // Add other required fields for the receiver user
  //       );
  //
  //       // Fetch the sender user data (e.g., the provider or handyman)
  //       UserData senderUserData = UserData(
  //         id: appStore.userId.validate(),
  //         firstName: appStore.userFirstName.validate(),
  //         lastName: appStore.userLastName.validate(),
  //         email: appStore.userEmail.validate(),
  //         profileImage: appStore.userProfileImage.validate(),
  //         // Add other required fields for the sender user
  //       );
  //
  //       // Send the notification
  //       String title = "Booking Accepted";
  //       String content = "${senderUserData.firstName} ${senderUserData.lastName} has accepted your booking.";
  //
  //       // Optional: You can provide an image if needed
  //       String? image = null;
  //
  //       // Call the sendPushNotifications method
  //       NotificationService notificationService = NotificationService();
  //       await notificationService.sendPushNotifications(title, content, image: image, receiverUser: receiverUser, senderUserData: senderUserData);
  //     }
  //
  //     // appStore.setLoading(false);
  //   }).catchError((e) {
  //     // Handle error
  //     // appStore.setLoading(false);
  //   });
  // }
  ///  accept / reject booking
  Future<void> updateBooking(BookingData booking, String updatedStatus, int index) async {
    appStore.setLoading(true);
    Map request = {
      CommonKeys.id: booking.id,
      BookingUpdateKeys.status: updatedStatus,
      BookingUpdateKeys.paymentStatus: booking.isAdvancePaymentDone
          ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
          : booking.paymentStatus.validate(),
    };

    await bookingUpdate(request).then((res) async {
      setState(() {});

      // Prepare user data for receiver (customer)
      UserData receiverUser = UserData(
        id: booking.customerId.validate(),
        firstName: booking.customerName.validate(),
        // Add other required fields for the receiver user
      );

      // Prepare sender data (provider or handyman)
      UserData senderUserData = UserData(
        id: appStore.userId.validate(),
        firstName: appStore.userFirstName.validate(),
        lastName: appStore.userLastName.validate(),
        email: appStore.userEmail.validate(),
        profileImage: appStore.userProfileImage.validate(),
        // Add other required fields for the sender user
      );

      // Determine the notification content based on the updated status
      String title = updatedStatus == BookingStatusKeys.accept
          ? "Booking Accepted"
          : updatedStatus == BookingStatusKeys.rejected
          ? "Booking Rejected"
          : updatedStatus == BookingStatusKeys.cancelled
          ? "Booking Cancelled"
          : "Booking Status Updated";

      String content = updatedStatus == BookingStatusKeys.accept
          ? "${senderUserData.firstName} ${senderUserData.lastName} has accepted your booking."
          : updatedStatus == BookingStatusKeys.rejected
          ? "${senderUserData.firstName} ${senderUserData.lastName} has rejected your booking."
          : updatedStatus == BookingStatusKeys.cancelled
          ? "${senderUserData.firstName} ${senderUserData.lastName} has cancelled your booking."
          : "${senderUserData.firstName} ${senderUserData.lastName} has updated your booking status.";

      // Optional: You can provide an image if needed
      String? image = null;

      // Send notification to customer
      NotificationService notificationService = NotificationService();
      await notificationService.sendPushNotifications(title, content, image: image, receiverUser: receiverUser, senderUserData: senderUserData);

      // Send notification to the provider as well
      UserData providerReceiverUser = UserData(
        id: appStore.userId.validate(),
        firstName: appStore.userFirstName.validate(),
        lastName: appStore.userLastName.validate(),
        // Add other required fields for the provider user
      );

      String providerTitle = updatedStatus == BookingStatusKeys.accept
          ? "Booking Accepted"
          : updatedStatus == BookingStatusKeys.rejected
          ? "Booking Rejected"
          : updatedStatus == BookingStatusKeys.cancelled
          ? "Booking Cancelled"
          : "Booking Status Updated";

      String providerContent = updatedStatus == BookingStatusKeys.accept
          ? "You have accepted the booking from ${receiverUser.firstName}."
          : updatedStatus == BookingStatusKeys.rejected
          ? "You have rejected the booking from ${receiverUser.firstName}."
          : updatedStatus == BookingStatusKeys.cancelled
          ? "You have cancelled the booking with ${receiverUser.firstName}."
          : "You have updated the booking status with ${receiverUser.firstName}.";

      await notificationService.sendPushNotifications(providerTitle, providerContent, image: image, receiverUser: providerReceiverUser, senderUserData: senderUserData);

      // appStore.setLoading(false);
    }).catchError((e) {
      // Handle error
      // appStore.setLoading(false);
    });
  }


  Future<void> confirmationRequestDialog(BuildContext context, int index, String status) async {
    showConfirmDialogCustom(
      context,
      title: languages.confirmationRequestTxt,
      positiveText: languages.lblYes,
      negativeText: languages.lblNo,
      primaryColor: status == BookingStatusKeys.rejected ? Colors.redAccent : primaryColor,
      onAccept: (context) async {
        updateBooking(widget.bookingData, status, index);
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 16),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.scaffoldBackgroundColor,
        border: Border.all(color: context.dividerColor, width: 1.0),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.bookingData.isPackageBooking && widget.bookingData.bookingPackage != null)
                CachedImageWidget(
                  url: widget.bookingData.bookingPackage!.imageAttachments.validate().isNotEmpty ? widget.bookingData.bookingPackage!.imageAttachments.validate().first.validate() : "",
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  radius: defaultRadius,
                )
              else
                CachedImageWidget(
                  url: widget.bookingData.imageAttachments.validate().isNotEmpty ? widget.bookingData.imageAttachments!.first.validate() : '',
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                  radius: defaultRadius,
                ),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.bookingData.status.validate().getBookingStatusBackgroundColor.withOpacity(0.1),
                              borderRadius: radius(8),
                            ),
                            child: Marquee(
                              child: Text(
                                widget.bookingData.status.validate().toBookingStatus(),
                                style: boldTextStyle(color: widget.bookingData.status.validate().getBookingStatusBackgroundColor, size: 12),
                              ),
                            ),
                          ).flexible(),
                          if (widget.bookingData.isPostJob)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.1),
                                borderRadius: radius(8),
                              ),
                              child: Text(
                                languages.postJob,
                                style: boldTextStyle(color: context.primaryColor, size: 12),
                              ),
                            ),
                          if (widget.bookingData.isPackageBooking)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: context.primaryColor.withOpacity(0.1),
                                borderRadius: radius(8),
                              ),
                              child: Text(
                                languages.package,
                                style: boldTextStyle(color: context.primaryColor, size: 12),
                              ),
                            ),
                        ],
                      ).flexible(),
                      Text(
                        '#${widget.bookingData.id.validate()}',
                        style: boldTextStyle(color: context.primaryColor),
                      ),
                    ],
                  ),
                  8.height,
                  Marquee(
                    child: Text(
                      widget.bookingData.isPackageBooking ? '${widget.bookingData.bookingPackage!.name.validate()}' : '${widget.bookingData.serviceName.validate()}',
                      style: boldTextStyle(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  8.height,
                  if (widget.bookingData.bookingPackage != null)
                    PriceWidget(
                      price: widget.bookingData.totalAmount.validate(),
                      color: primaryColor,
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PriceWidget(
                          isFreeService: widget.bookingData.type == SERVICE_TYPE_FREE,
                          price: widget.bookingData.totalAmount.validate(),
                          color: primaryColor,
                        ),
                        if (widget.bookingData.isHourlyService)
                          Row(
                            children: [
                              4.width,
                              Text('${widget.bookingData.amount.validate().toPriceFormat()}/${languages.lblHr}', style: secondaryTextStyle()),
                            ],
                          ),
                        if (widget.bookingData.discount.validate() != 0)
                          Row(
                            children: [
                              4.width,
                              Text('(${widget.bookingData.discount.validate()}%', style: boldTextStyle(size: 12, color: Colors.green)),
                              Text(' ${languages.lblOff})', style: boldTextStyle(size: 12, color: Colors.green)),
                            ],
                          ),
                      ],
                    ),
                ],
              ).expand(),
            ],
          ).paddingAll(8),
          if (widget.showDescription)
            Container(
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.cardColor,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              margin: EdgeInsets.all(8),
              child: Column(
                children: [
                  if (widget.bookingData.address.validate().isNotEmpty)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(languages.lblAddress, style: secondaryTextStyle()),
                            8.width,
                            Marquee(
                              child: Text(
                                widget.bookingData.address.validate(),
                                style: boldTextStyle(size: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ).flexible(),
                          ],
                        ).paddingAll(8),
                        Divider(height: 0, color: context.dividerColor),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('${languages.lblDate} & ${languages.lblTime}', style: secondaryTextStyle()),
                      8.width,
                      Text(
                        "${formatDate(widget.bookingData.date.validate(), format: DATE_FORMAT_2)} At ${buildTimeWidget(bookingDetail: widget.bookingData)}",
                        style: boldTextStyle(size: 12),
                        maxLines: 2,
                        textAlign: TextAlign.right,
                      ).expand(),
                    ],
                  ).paddingAll(8),
                  if (widget.bookingData.customerName.validate().isNotEmpty)
                    Column(
                      children: [
                        Divider(height: 0, color: context.dividerColor),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(languages.customer, style: secondaryTextStyle()),
                            8.width,
                            Text(widget.bookingData.customerName.validate(), style: boldTextStyle(size: 12), textAlign: TextAlign.right).flexible(),
                          ],
                        ).paddingAll(8),
                      ],
                    ),
                  if (widget.bookingData.handyman.validate().isNotEmpty && isUserTypeProvider)
                    Column(
                      children: [
                        Divider(height: 0, color: context.dividerColor),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(languages.handyman, style: secondaryTextStyle()),
                            Text(widget.bookingData.handyman.validate().first.handyman!.displayName.validate(), style: boldTextStyle(size: 12)).flexible(),
                          ],
                        ).paddingAll(8),
                      ],
                    ),
                  if (widget.bookingData.paymentStatus != null && widget.bookingData.status == BookingStatusKeys.complete)
                    Column(
                      children: [
                        Divider(height: 0, color: context.dividerColor),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(languages.paymentStatus, style: secondaryTextStyle()).expand(),
                            Text(
                              buildPaymentStatusWithMethod(widget.bookingData.paymentStatus.validate(), widget.bookingData.paymentMethod.validate().capitalizeFirstLetter()),
                              style: boldTextStyle(
                                size: 12,
                                color: (widget.bookingData.paymentStatus.validate() == PAID || widget.bookingData.paymentStatus.validate() == PENDING_BY_ADMINS) ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ).paddingAll(8),
                      ],
                    ),
                  if (isUserTypeProvider && widget.bookingData.status == BookingStatusKeys.pending || (isUserTypeHandyman && widget.bookingData.status == BookingStatusKeys.accept))
                    Row(
                      children: [
                        if (isUserTypeProvider)
                          AppButton(
                            child: Text(languages.accept, style: boldTextStyle(color: white)),
                            width: context.width(),
                            color: primaryColor,
                            elevation: 0,
                            onTap: () async {
                              /// If Auto Assign is enabled, Assign to current Provider it self
                              if (appConfigurationStore.autoAssignStatus) {
                                showConfirmDialogCustom(
                                  context,
                                  title: languages.lblAreYouSureYouWantToAssignToYourself,
                                  primaryColor: context.primaryColor,
                                  positiveText: languages.lblYes,
                                  negativeText: languages.lblCancel,
                                  onAccept: (c) async {
                                    var request = {
                                      CommonKeys.id: widget.bookingData.id.validate(),
                                      CommonKeys.handymanId: [appStore.userId.validate()],
                                    };

                                    appStore.setLoading(true);

                                    await assignBooking(request).then((res) async {
                                      appStore.setLoading(false);

                                      setState(() {});
                                      LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);

                                      finish(context);

                                      toast(res.message);
                                    }).catchError((e) {
                                      appStore.setLoading(false);

                                      toast(e.toString());
                                    });
                                  },
                                );
                              } else {
                                await showConfirmDialogCustom(
                                  context,
                                  title: languages.wouldYouLikeToAssignThisBooking,
                                  primaryColor: primaryColor,
                                  positiveText: languages.lblYes,
                                  negativeText: languages.lblNo,
                                  onAccept: (_) async {
                                    var request = {
                                      CommonKeys.id: widget.bookingData.id.validate(),
                                      BookingUpdateKeys.status: BookingStatusKeys.accept,
                                      BookingUpdateKeys.paymentStatus: widget.bookingData.isAdvancePaymentDone ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID : widget.bookingData.paymentStatus.validate(),
                                    };
                                    appStore.setLoading(true);

                                    bookingUpdate(request).then((res) async {
                                      setState(() {});
                                      LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);
                                    }).catchError((e) {
                                      appStore.setLoading(false);
                                      toast(e.toString());
                                    });

                                    /*var request = {
                                    CommonKeys.id: widget.bookingData.id.validate(),
                                    BookingUpdateKeys.status: BookingStatusKeys.accept,
                                    BookingUpdateKeys.paymentStatus: widget.bookingData.isAdvancePaymentDone ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID : widget.bookingData.paymentStatus.validate(),
                                  };
                                  appStore.setLoading(true);

                                  bookingUpdate(request).then((res) async {
                                    /// If Auto Assign Provider it self when Handyman List is Empty
                                    if (appConfigurationStore.autoAssignStatus) {
                                      if (appStore.totalHandyman >= 1) {
                                        if (appStore.isLoading) return;

                                        showConfirmDialogCustom(
                                          context,
                                          title: languages.lblAreYouSureYouWantToAssignToYourself,
                                          primaryColor: context.primaryColor,
                                          positiveText: languages.lblYes,
                                          negativeText: languages.lblCancel,
                                          onAccept: (c) async {
                                            var request = {
                                              CommonKeys.id: widget.bookingData.id.validate(),
                                              CommonKeys.handymanId: [appStore.userId.validate()],
                                            };

                                            appStore.setLoading(true);

                                            await assignBooking(request).then((res) async {
                                              appStore.setLoading(false);

                                              setState(() {});
                                              LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);

                                              finish(context);

                                              toast(res.message);
                                            }).catchError((e) {
                                              appStore.setLoading(false);

                                              toast(e.toString());
                                            });
                                          },
                                        );
                                      } else {
                                        appStore.setLoading(false);
                                        finish(context, true);
                                      }
                                    } else {
                                      appStore.setLoading(false);
                                      finish(context, true);
                                    }
                                  }).catchError((e) {
                                    if (mounted) {
                                      finish(context);
                                    }
                                    appStore.setLoading(false);
                                    toast(e.toString());
                                  });*/
                                  },
                                );
                              }
                            },
                          ).expand(),
                        12.width,
                        AppButton(
                          child: Text(languages.decline, style: boldTextStyle()),
                          width: context.width(),
                          elevation: 0,
                          color: appStore.isDarkMode ? context.scaffoldBackgroundColor : white,
                          onTap: () {
                            if (isUserTypeProvider) {
                              confirmationRequestDialog(context, widget.index!, BookingStatusKeys.rejected);
                            } else {
                              confirmationRequestDialog(context, widget.index!, BookingStatusKeys.pending);
                            }
                          },
                        ).expand(),
                      ],
                    ).paddingOnly(bottom: 8, left: 8, right: 8, top: 16),
                  if (isUserTypeProvider && widget.bookingData.handyman!.isEmpty && widget.bookingData.status == BookingStatusKeys.accept)
                    Column(
                      children: [
                        8.height,
                        AppButton(
                          width: context.width(),
                          child: Text(languages.lblAssign, style: boldTextStyle(color: white)),
                          color: primaryColor,
                          elevation: 0,
                          onTap: () {
                            AssignHandymanScreen(
                              bookingId: widget.bookingData.id,
                              serviceAddressId: widget.bookingData.bookingAddressId,
                              onUpdate: () {
                                setState(() {});
                                LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);
                              },
                            ).launch(context);
                          },
                        ),
                      ],
                    ).paddingAll(8),
                ],
              ).paddingAll(8),
            ),
        ],
      ), //booking card change
    ).onTap(
      () async {
        BookingDetailScreen(bookingId: widget.bookingData.id.validate()).launch(context);
      },
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
    );
  }
}
