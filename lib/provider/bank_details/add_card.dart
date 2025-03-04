import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';


import '../../../main.dart';

import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/model_keys.dart';
import '../../components/base_scaffold_widget.dart';
import '../../models/bank_list_response.dart';
import '../../models/base_response.dart';
import '../../networks/network_utils.dart';
import '../../utils/configs.dart';

class AddCardScreen extends StatefulWidget {
  // final CardDetails? data;
  final CardHistory? data;

  const AddCardScreen({super.key, this.data});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController cardHolderNameCont = TextEditingController();
  TextEditingController cardNumberCont = TextEditingController();
  TextEditingController expiryDateCont = TextEditingController();
  TextEditingController cvvCont = TextEditingController();
  TextEditingController billingAddressCont = TextEditingController();

  FocusNode cardHolderNameFocus = FocusNode();
  FocusNode cardNumberFocus = FocusNode();
  FocusNode expiryDateFocus = FocusNode();
  FocusNode cvvFocus = FocusNode();
  FocusNode billingAddressFocus = FocusNode();

  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    isUpdate = widget.data != null;
    if (isUpdate) {
      cardHolderNameCont.text = widget.data!.cardHolderName.validate();
      cardNumberCont.text = widget.data!.cardNumber.validate();
      expiryDateCont.text = widget.data!.expiryDate.validate();
      cvvCont.text = widget.data!.cvv.validate();
      billingAddressCont.text = widget.data!.billingAddress.validate();
    }
  }

  Future<void> saveCardHistory() async {
    MultipartRequest multiPartRequest = await getMultiPartRequest('save-card');
    multiPartRequest.fields[UserKeys.id] = isUpdate ? widget.data!.id.toString() : "";
    // multiPartRequest.fields[UserKeys.userId] = appStore.userId.toString();
    multiPartRequest.fields[UserKeys.providerId] = appStore.userId.toString();
    multiPartRequest.fields['cardHolderName'] = cardHolderNameCont.text;
    multiPartRequest.fields['cardNumber'] = cardNumberCont.text;
    multiPartRequest.fields['expiryDate'] = expiryDateCont.text;
    multiPartRequest.fields['cvv'] = cvvCont.text;
    multiPartRequest.fields['billingAddress'] = billingAddressCont.text;

    multiPartRequest.headers.addAll(buildHeaderTokens());

    appStore.setLoading(true);

    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        if (data != null) {
          if ((data as String).isJson()) {
            BaseResponseModel res = BaseResponseModel.fromJson(jsonDecode(data));
            finish(context, [true, cardHolderNameCont.text]);
            snackBar(context, title: res.message!);
          }
        }
      },
      onError: (error) {
        toast(error.toString(), print: true);
        appStore.setLoading(false);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: AppScaffold(
        appBarTitle: "Add Card",
        body: Stack(
          children: [
            Form(
              key: formKey,
              child: AnimatedScrollView(
                padding: EdgeInsets.all(16),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: cardHolderNameCont,
                    focus: cardHolderNameFocus,
                    nextFocus: cardNumberFocus,
                    decoration: inputDecoration(context, hintText: "Cardholder Name"),
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NUMBER,
                    controller: cardNumberCont,
                    focus: cardNumberFocus,
                    nextFocus: expiryDateFocus,
                    maxLength: 16,
                    decoration: inputDecoration(context, hintText: "Card Number"),
                  ),
                  16.height,
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          textFieldType: TextFieldType.NUMBER,
                          controller: expiryDateCont,
                          focus: expiryDateFocus,
                          nextFocus: cvvFocus,
                          decoration: inputDecoration(context, hintText: "MM/YY"),
                        ),
                      ),
                      16.width,
                      Expanded(
                        child: AppTextField(
                          textFieldType: TextFieldType.NUMBER,
                          controller: cvvCont,
                          focus: cvvFocus,
                          nextFocus: billingAddressFocus,
                          maxLength: 3,
                          decoration: inputDecoration(context, hintText: "CVV"),
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: billingAddressCont,
                    focus: billingAddressFocus,
                    decoration: inputDecoration(context, hintText: "Billing Address (Optional)"),
                  ),
                  100.height,
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: AppButton(
                text: languages.btnSave,
                color: primaryColor,
                textStyle: boldTextStyle(color: white),
                width: context.width(),
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    saveCardHistory();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class CardListResponse {
  Pagination pagination;
  List<CardHistory> data;

  CardListResponse({
    required this.pagination,
    this.data = const <CardHistory>[],
  });

  factory CardListResponse.fromJson(Map<String, dynamic> json) {
    return CardListResponse(
      pagination: json['pagination'] is Map
          ? Pagination.fromJson(json['pagination'])
          : Pagination(),
      data: json['data'] is List
          ? List<CardHistory>.from(
          json['data'].map((x) => CardHistory.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination.toJson(),
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class CardHistory {
  int id;
  int userId;
  String cardHolderName;
  String cardNumber;
  String expiryDate;
  String cvv;
  String billingAddress;
  int isDefault;

  CardHistory({
    this.id = -1,
    this.userId = -1,
    this.cardHolderName = "",
    this.cardNumber = "",
    this.expiryDate = "",
    this.cvv = "",
    this.billingAddress = "",
    this.isDefault = 0,
  });

  factory CardHistory.fromJson(Map<String, dynamic> json) {
    return CardHistory(
      id: json['id'] is int ? json['id'] : -1,
      userId: json['user_id'] is int ? json['user_id'] : -1,
      cardHolderName:
      json['card_holder_name'] is String ? json['card_holder_name'] : "",
      cardNumber: json['card_number'] is String ? json['card_number'] : "",
      expiryDate: json['expiry_date'] is String ? json['expiry_date'] : "",
      cvv: json['cvv'] is String ? json['cvv'] : "",
      billingAddress:
      json['billing_address'] is String ? json['billing_address'] : "",
      isDefault: json['is_default'] is int ? json['is_default'] : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_holder_name': cardHolderName,
      'card_number': cardNumber,
      'expiry_date': expiryDate,
      'cvv': cvv,
      'billing_address': billingAddress,
      'is_default': isDefault,
    };
  }
}
