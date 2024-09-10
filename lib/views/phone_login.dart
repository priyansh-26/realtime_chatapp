// ignore_for_file: prefer_final_fields

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chatapp/constants/colors.dart';
import 'package:realtime_chatapp/controllers/appwrite_controllers.dart';
import 'package:realtime_chatapp/providers/user_data_provider.dart';

class PhoneLoginState extends StatefulWidget {
  const PhoneLoginState({super.key});

  @override
  State<PhoneLoginState> createState() => _PhoneLoginStateState();
}

class _PhoneLoginStateState extends State<PhoneLoginState> {
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  String countryCode = "+91";

  void handleOtpSubmit(String userId, BuildContext context) {
    if (_formKey1.currentState!.validate()) {
      loginWithOtp(otp: _otpController.text, userId: userId).then((value) {
        if (value) {
          Provider.of<UserDataProvider>(context, listen: false)
              .setUserId(userId);
          Provider.of<UserDataProvider>(context, listen: false)
              .setUserPhone(countryCode+_phoneNumberController.text);
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/update",
            (route) => false,
            arguments: {"title":"add"}
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Login Failed")));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  "assets/login.png",
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome to ChatApp 👋",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const Text(
                      "Enter your phone number to continue.",
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.length != 10) {
                            return "Inavlid phone number";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: CountryCodePicker(
                            onChanged: (value) {
                              print(value.dialCode);
                              countryCode = value.dialCode!;
                            },
                            initialSelection: "IN",
                          ),
                          labelText: "Enter your phone number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        child: const Text('Send OTP'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            createPhoneSession(
                                    phone: countryCode +
                                        _phoneNumberController.text)
                                .then(
                              (value) {
                                if (value != "login_error") {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('OTP Sent'),
                                      content: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text("Enter 6 digit OTP"),
                                          const SizedBox(height: 12),
                                          Form(
                                            key: _formKey1,
                                            child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: _otpController,
                                              validator: (value) {
                                                if (value!.length != 6) {
                                                  return "Invalid OTP";
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                labelText: "Enter the OTP",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              handleOtpSubmit(value, context);
                                            },
                                            child: const Text("Submit"))
                                      ],
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("Failed to send OTP")));
                                }
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
