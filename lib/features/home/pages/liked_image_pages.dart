import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vritapp/features/home/model/liked_photos_model.dart';
import 'package:vritapp/features/home/provider/liked_state_notifier.dart';
import 'package:vritapp/common/components/custom_alert_button.dart';
import 'package:vritapp/widgets/display_image.dart';

import 'package:vritapp/features/home/repo/liked/cloud_firestore_services.dart';

class LikedImagesScreen extends ConsumerWidget {
  const LikedImagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamData = ref.watch(likedProvider);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text("Liked Images"),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            if (streamData.isLoading && streamData.likedPics == null) ...{
              const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ))
            } else if ((!streamData.isLoading &&
                streamData.likedPics == null)) ...{
              const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text("No data"),
                  ))
            } else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.67,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2),
                itemCount: streamData.likedPics!.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      GridTile(
                          child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DisplayImage(
                                  image:
                                      "${streamData.likedPics?[index].imageUrl}",
                                  id: "${streamData.likedPics?[index].id}")));
                        },
                        child: Hero(
                          tag: "$index",
                          child: CachedNetworkImage(
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: imageProvider),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      color: Colors.grey.shade800),
                                );
                              },
                              placeholder: (context, url) {
                                return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      color: Colors.grey.shade300),
                                );
                              },
                              imageUrl:
                                  streamData.likedPics?[index].imageUrl ?? ""),
                        ),
                      )),
                      Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                              iconSize: 35,
                              color: Colors.red.shade400,
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return CustomAlertButton(
                                          titleText: "Delete ?",
                                          onPressed: () async {
                                            await ref
                                                .read(firebaseFirestoreProvider)
                                                .deleteLikedPhotos(
                                                    ref: ref,
                                                    likedPhotosModel: streamData
                                                        .likedPics![index])
                                                .then((value) =>
                                                    Navigator.of(ctx).pop());
                                          },
                                          contentText:
                                              "Do you really want to delete ?");
                                    });
                              },
                              icon: const Icon(Icons.delete_outline_outlined)))
                    ],
                  );
                },
              ),
          ]),
        ));
  }
}
