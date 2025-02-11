import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geocoding/geocoding.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/city_list_response.dart';
import 'package:handyman_provider_flutter/models/country_list_response.dart';
import 'package:handyman_provider_flutter/models/service_address_response.dart';
import 'package:handyman_provider_flutter/models/state_list_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class AddServiceComponent extends StatefulWidget {
  final bool isFromService;
  final AddressResponse? addressData;

  AddServiceComponent({Key? key, this.isFromService = false, this.addressData}) : super(key: key);

  @override
  State<AddServiceComponent> createState() => _AddServiceComponentState();
}

class _AddServiceComponentState extends State<AddServiceComponent> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController addressNameCont = TextEditingController();

  bool isUpdate = false;
  bool isTextChangedFromPrevious = false;

  List<CountryListResponse> countryList = [];
  List<StateListResponse> stateList = [];
  List<CityListResponse> cityList = [];

  StateListResponse? selectedState;
  CityListResponse? selectedCity;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isUpdate = widget.addressData != null;

    if (isUpdate) {
      addressNameCont.addListener(() {
        isTextChangedFromPrevious = addressNameCont.text != widget.addressData!.address.validate();
        setState(() {});
      });
      addressNameCont.text = widget.addressData!.address.validate();
    }
    if (getIntAsync(COUNTRY_ID) != 0) {
      // await getCountry();
      await getStates(getIntAsync(COUNTRY_ID));
      if (getIntAsync(STATE_ID) != 0) {
        await getCities(getIntAsync(STATE_ID));
      }

      setState(() {});
    } else {
      // await getCountry();
    }

  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }


  Future<void> getStates(int countryId) async {
    appStore.setLoading(true);
    await getStateList({'country_id': countryId}).then((value) async {
      stateList.clear();
      stateList.addAll(value);

      if (value.any((element) => element.id == getIntAsync(STATE_ID))) {
        selectedState = value.firstWhere((element) => element.id == getIntAsync(STATE_ID));
      }
      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }
  Future<void> getCities(int stateId) async {
    appStore.setLoading(true);
    await getCityList({'state_id': stateId}).then((value) {
      cityList.clear();
      cityList.addAll(value);
      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> addUpdateAddress() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      appStore.setLoading(true);

      Map request = {
        AddAddressKey.providerId: appStore.userId,
        AddAddressKey.status: '1',
        AddAddressKey.address: addressNameCont.text.trim(),
        AddAddressKey.stateId: selectedState?.id,
        AddAddressKey.cityId: selectedCity?.id,
      };

      await locationFromAddress(addressNameCont.text).then((value) {
        request.putIfAbsent(AddAddressKey.latitude, () => value.first.latitude);
        request.putIfAbsent(AddAddressKey.longitude, () => value.first.longitude);
      }).catchError((e) async {
        // toast(e.toString(), print: true);
      });
      if (!request.containsKey(AddAddressKey.latitude)) {
        appStore.setLoading(false);
        toast(languages.noServiceAccordingToCoordinates);
      } else {
        request.putIfAbsent(AddAddressKey.id, () => isUpdate ? widget.addressData!.id.validate() : "");

        await addAddresses(request).then((value) {
          appStore.setLoading(false);

          addressNameCont.clear();

          toast(value.message.validate(), print: true);
          if (widget.isFromService.validate()) {
            finish(context, true);
          } else {
            finish(context, true);
          }
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });
      }
    }
  }

  @override
  void dispose() {
    if (isUpdate) {
      addressNameCont.removeListener(() {
        //
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            backgroundColor: primaryColor,
          ),
          padding: EdgeInsets.only(left: 24, right: 8, bottom: 8, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.addressData == null ? languages.lblAddServiceAddress : languages.editAddress, style: boldTextStyle(color: white), textAlign: TextAlign.justify),
              IconButton(
                onPressed: () {
                  finish(context);
                  appStore.setLoading(false);
                },
                icon: Icon(Icons.close, size: 22, color: white),
              ),
            ],
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownSearch<StateListResponse>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: inputDecoration(context, hint: "Search State"),
                        ),
                      ),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: inputDecoration(context, hint: languages.selectState),
                      ),
                      selectedItem: selectedState,
                      itemAsString: (StateListResponse? s) => s!.name!,
                      items: stateList,
                      onChanged: (StateListResponse? value) async {
                        selectedState = value;
                        selectedCity = null; // Reset city when state is changed
                        setState(() {});
                        if (value != null) {
                          await getCities(value.id!);
                          // Update addressNameCont with selected state
                          addressNameCont.text = "${addressNameCont.text.split(' ')[0]}, ${value.name}";
                        }
                      },
                    ),
                    8.height.visible(cityList.isNotEmpty),
                    if (cityList.isNotEmpty)
                      DropdownSearch<CityListResponse>(
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: inputDecoration(context, hint: "Search City"),
                          ),
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: inputDecoration(context, hint: languages.selectCity),
                        ),
                        selectedItem: selectedCity,
                        itemAsString: (CityListResponse? c) => c!.name!,
                        items: cityList,
                        onChanged: (CityListResponse? value) {
                          selectedCity = value;
                          setState(() {});
                          // Update addressNameCont with selected city
                          if (value != null) {
                            addressNameCont.text = "${addressNameCont.text.split(' ')[0]} ${selectedState?.name}, ${value.name}";
                          }
                        },
                      ),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.MULTILINE,
                      controller: addressNameCont,
                      decoration: inputDecoration(context, hint: languages.hintAddress),
                    ),

                    24.height,
                    AppButton(
                      text: isUpdate ? languages.lblUpdate : languages.hintAdd,
                      height: 40,
                      color: primaryColor,
                      enabled: isUpdate ? isTextChangedFromPrevious : true,
                      disabledColor: context.primaryColor.withOpacity(0.5),
                      textStyle: boldTextStyle(color: white),
                      width: context.width() - context.navigationBarHeight,
                      onTap: () async {
                        ifNotTester(context, () {
                          addUpdateAddress();
                        });
                      },
                    ),
                  ],
                ).paddingSymmetric(horizontal: 16, vertical: 24),
              ),
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ],
    );
  }
}