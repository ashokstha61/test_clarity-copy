import 'package:Sleephoria/custom/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme.dart';

class SubscriptionManagementView extends StatefulWidget {
  const SubscriptionManagementView({super.key});

  @override
  State<SubscriptionManagementView> createState() =>
      _SubscriptionManagementViewState();
}

class _SubscriptionManagementViewState
    extends State<SubscriptionManagementView> {
  String subscriptionType = "Free";
  String timeRemaining = "N/A";

  void updateSubscriptionInfo(String type, String time) {
    setState(() {
      subscriptionType = type;
      timeRemaining = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.backgroundColor(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Subscription Management',
          style: TextStyle(
            color: ThemeHelper.appBarTitle(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                labelText: 'Subscription Type',
                initialValue: subscriptionType,
                readOnly: true,
              ),

              CustomTextField(
                labelText: 'Time Remaining',
                initialValue: timeRemaining,
                readOnly: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
