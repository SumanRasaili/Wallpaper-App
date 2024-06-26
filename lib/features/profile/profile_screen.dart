import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vritapp/common/components/circular_progress_indicator.dart';
import 'package:vritapp/common/components/custom_alert_button.dart';
import 'package:vritapp/common/components/custom_text_field.dart';
import 'package:vritapp/config/app_colors.dart';
import 'package:vritapp/core/notification_service/notification_services.dart';
import 'package:vritapp/features/auth/provider/user_data_notifier.dart';
import 'package:vritapp/features/auth/repository/auth_repo.dart';

class ProfileScreen extends StatefulHookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker picker = ImagePicker();
  File? image;
  late SharedPreferences prefs;

  setImage({required File image}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPickedImage', image.path);
  }

  getImage() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.getString('userPickedImage') != null) {
      setState(() {
        image = File(prefs.getString('userPickedImage')!);
      });
    } else {
      setState(() {
        image = null;
      });
    }
  }

  @override
  void initState() {
    getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProfData = ref.watch(userDataProvider);
    final dateController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Profile"),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return CustomAlertButton(
                          titleText: "Log Out",
                          onPressed: () async {
                            await ref
                                .read(userAuthProvider)
                                .signOutUser()
                                .then((value) => Phoenix.rebirth(ctx));
                          },
                          contentText: "Do you really want to LogOut?");
                    });
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  image == null
                      ? CachedNetworkImage(
                          imageUrl: userProfData?.photoURL ?? "",
                          imageBuilder: (context, imageProvider) => Container(
                            width: 150.0,
                            height: 200.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) => Container(
                            width: 150.0,
                            height: 200.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Center(
                              child: CustomLoadedr(),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Container(
                          width: 150.0,
                          height: 200.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                            image: DecorationImage(
                                image: FileImage(image!), fit: BoxFit.cover),
                          ),
                        ),
                  Positioned(
                      bottom: 30,
                      right: 0,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.grey),
                        child: IconButton(
                            onPressed: () async {
                              XFile? file = await picker.pickImage(
                                  source: ImageSource.camera);
                              if (file != null) {
                                setState(() {
                                  image = File(file.path);
                                  setImage(image: File(image?.path ?? ""));
                                });
                              }
                            },
                            iconSize: 20,
                            icon: Icon(
                              Icons.add_a_photo,
                              color: Theme.of(context).colorScheme.primary,
                            )),
                      ))
                ],
              ),
              Text(
                userProfData?.displayName ?? "",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.whiteColor,
                    ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                userProfData?.email ?? "",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.whiteColor,
                    ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Divider(),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Select your date of birth to see magic",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.whiteColor,
                    ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Container(
                    decoration: const BoxDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Date",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                      color: AppColors.whiteColor,
                                      fontSize: 14),
                            ),
                            IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (builder) {
                                        return Dialog(
                                          insetPadding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.31),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Suggestion",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge
                                                        ?.copyWith(
                                                            fontSize: 20,
                                                            color: AppColors
                                                                .whiteColor),
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    "Here, If your BirthDate matches with the Today's Date you will receive a BirtDay Messages.. YAYYY",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                            fontSize: 18,
                                                            color: AppColors
                                                                .whiteColor),
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    "So Lets try",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                            fontSize: 16,
                                                            color: AppColors
                                                                .whiteColor),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Center(
                                                    child: FilledButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          "CLOSE",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .titleSmall
                                                              ?.copyWith(
                                                                  color: AppColors
                                                                      .whiteColor),
                                                        )),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                                icon: const Icon(Icons.info))
                          ],
                        ),
                        CustomTextField(
                          hintText: "Select Date",
                          readOnly: true,
                          labelText: " Select Date",
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2020, 01, 01),
                                lastDate: DateTime(
                                  DateTime.now().year + 5,
                                ));

                            if (pickedDate != null) {
                              var today = DateTime.now().day;
                              var month = DateTime.now().month;
                              var year = DateTime.now().year;
                              if (pickedDate.year == year &&
                                  pickedDate.month == month &&
                                  pickedDate.day == today) {
                                Notificationservice().showNotificationdetail();
                              } else {
                                BotToast.showText(
                                    text: "Mystery remain unsolved");
                              }

                              dateController.text =
                                  DateFormat("yyyy-MM-dd").format(pickedDate);
                            }
                          },
                          controller: dateController,
                        ),
                      ],
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
