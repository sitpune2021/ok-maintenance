import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
// import 'package:handyman_provider_flutter/utils/constants.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class AMCSelectionScreen extends StatefulWidget {
  @override
  _AMCSelectionScreenState createState() => _AMCSelectionScreenState();
}

class _AMCSelectionScreenState extends State<AMCSelectionScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? amcType;
  String? selectedCategory;

  final categories = ["Electrical", "Plumbing", "HVAC", "Cleaning"];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> submitAMC() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      appStore.setLoading(true);

      // Prepare your request data
      var request = {
        'amcType': amcType,
        'category': selectedCategory,
      };

      await submitAMCRequest(request).then((res) {
        appStore.setLoading(false);
        toast(res.message);
        finish(context);
      }).catchError((e) {
        toast(e.toString(), print: true);
        appStore.setLoading(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "AMCSelection",
        backWidget: BackWidget(),
        showBack: true,
        textColor: white,
        color: context.primaryColor,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Container(
              height: context.height(),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("selectAMCType", style: secondaryTextStyle()),
                    24.height,

                    // AMC Type Selection
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: Text("AMC"),
                          value: "AMC",
                          groupValue: amcType,
                          onChanged: (value) {
                            setState(() {
                              amcType = value;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text("Machine Maintenance"),
                          value: "Machine Maintenance",
                          groupValue: amcType,
                          onChanged: (value) {
                            setState(() {
                              amcType = value;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text("Both"),
                          value: "Both",
                          groupValue: amcType,
                          onChanged: (value) {
                            setState(() {
                              amcType = value;
                            });
                          },
                        ),
                      ],
                    ),
                    16.height,

                    // Category Selection
                    // Category Selection
                    if (amcType == "AMC" || amcType == "Both") ...[
                      DropdownButtonFormField<String>(
                        dropdownColor: context.cardColor,
                        decoration: inputDecoration(context, hint: languages.lblStatus),
                        value: selectedCategory,
                        hint: Text("Select Category"),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return languages.hintRequired;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                    ],

                    AppButton(
                      text: languages.confirm,
                      height: 40,
                      color: primaryColor,
                      textStyle: boldTextStyle(color: white),
                      width: context.width() - context.navigationBarHeight,
                      onTap: () {
                        submitAMC();
                      },
                    ),
                    24.height,
                  ],
                ),
              ),
            ),
          ),
          Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}