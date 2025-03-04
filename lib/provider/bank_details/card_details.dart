import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:nb_utils/nb_utils.dart';


import '../../../main.dart';


import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/images.dart';

import '../../components/cached_image_widget.dart';
import '../../networks/rest_apis.dart';
import '../../utils/configs.dart';
import 'add_card.dart';

class CardDetailsScreen extends StatefulWidget {
  final CardHistory? cardHistory;

  const CardDetailsScreen({super.key, this.cardHistory});

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  Future<List<CardHistory>>? future;
  List<CardHistory> cardHistoryList = [];
  int page = 1;
  bool isLastPage = false;
  CardHistory _selectedCard = CardHistory();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> update() async {
    // appStore.setLoading(true);
    // setDefaultCard(cardId: _selectedCard.id).then((value) {
    //   init();
    //   setState(() {});
    // }).catchError((value) async {
    //   toast(value);
    // }).whenComplete(() {
    //   appStore.setLoading(false);
    // });
    appStore.setLoading(true);
    chooseDefaulBank(bankId: _selectedCard.id).then((value) {
      init();
      setState(() {});
    }).catchError((value) async {
      toast(value);
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  Future<void> delete(cardId) async {
    appStore.setLoading(true);
    // deleteCard(cardId: cardId).then((value) {
      deleteBank(bankId: cardId).then((value) {
      init();
      setState(() {});
    }).catchError((value) async {
      toast(value);
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  void setDefault() {
    for (var value in cardHistoryList) {
      if (value.isDefault == 1) {
        _selectedCard = value;
        setState(() {});
      }
    }
  }

  init() async {
    future = getCardListDetail(
      page: page,
      list: cardHistoryList,
      lastPageCallback: (b) {
        isLastPage = b;
      },
      userId: appStore.userId,
    );
  }

  List<OptionModel> optionList({required CardHistory cardHistory}) {
    return [
      OptionModel(
        title: languages.lblEdit,
        onTap: () {
          AddCardScreen(data: cardHistory)
              .launch(context, pageRouteAnimation: PageRouteAnimation.Fade)
              .then((value) {
            if (value[0]) {
              init();
              setState(() {});
            }
          });
        },
      ),
      if (cardHistory.isDefault == 0)
        OptionModel(
          title: languages.lblDelete,
          onTap: () {
            showConfirmDialogCustom(
              context,
              dialogType: DialogType.DELETE,
              title: "Delete Card Title",
              positiveText: languages.lblDelete,
              negativeText: languages.lblCancel,
              onAccept: (v) {
                delete(cardHistory.id);
              },
            );
          },
        ),
      if (cardHistory.isDefault == 0)
        OptionModel(
          title: languages.setAsDefault,
          onTap: () {
            setState(() {
              _selectedCard = cardHistory;
              update();
            });
          },
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: "Card List",
      actions: [
        IconButton(
          onPressed: () {
            AddCardScreen().launch(context).then((value) {
              if (value[0]) {
                init();
                setState(() {});
              }
            });
          },
          icon: CachedImageWidget(
            url: ic_add,
            height: 14,
            width: 14,
            color: white,
          ),
        ),
      ],
      body: SnapHelperWidget<List<CardHistory>>(
        future: future,
        initialData: cachedCardList,
        // initialData: cachedBankList,
        onSuccess: (snap) {
          return AnimatedListView(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            slideConfiguration:
            SlideConfiguration(duration: 400.milliseconds, delay: 50.milliseconds),
            padding: EdgeInsets.all(8),
            itemCount: snap.length,
            itemBuilder: (BuildContext context, index) {
              CardHistory data = snap[index];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                margin: EdgeInsets.all(8),
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: context.cardColor,
                ),
                width: context.width(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Marquee(
                            child: Text(data.cardHolderName.validate(),
                                style: primaryTextStyle(
                                    size: 14, weight: FontWeight.bold)))
                            .expand(),
                        16.width,
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(50)),
                          child: Text(languages.lbldefault,
                              style: primaryTextStyle(size: 10, color: white)),
                        ).visible(data.isDefault == 1),
                      ],
                    ),
                    8.height,
                    Text(maskCardNumber(data.cardNumber.validate()),
                        style: secondaryTextStyle()),

                    8.height,
                    OptionListWidget(optionList: optionList(cardHistory: data)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
