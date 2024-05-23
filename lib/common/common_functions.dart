import 'dart:io';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

final commonfuncProvider = Provider<CommonRepo>((ref) {
  return CommonRepo();
});

class CommonRepo {
  Future<void> setwallPaper({required String image}) async {
    var file = await DefaultCacheManager().getSingleFile(image);
    try {
      BotToast.showLoading();
      bool res = (await (WallpaperManager.setWallpaperFromFile(
          file.path, WallpaperManager.HOME_SCREEN)));
      if (res) {
        BotToast.closeAllLoading();

        BotToast.showText(text: "Wallpaper set succesfully");
      }
    } on PlatformException {
      BotToast.closeAllLoading();
      BotToast.showText(text: "Failed to set image ");
    }
  }

  Future<void> setLockScreen({required String image}) async {
    var file = await DefaultCacheManager().getSingleFile(image);
    try {
      BotToast.showLoading();
      bool res = (await (WallpaperManager.setWallpaperFromFile(
          file.path, WallpaperManager.LOCK_SCREEN)));
      if (res) {
        BotToast.closeAllLoading();

        BotToast.showText(text: "Lock Screen set succesfully");
      }
    } on PlatformException {
      BotToast.closeAllLoading();
      BotToast.showText(text: "Failed to set image ");
    }
  }

  Future<void> setBoth({required String image}) async {
    var file = await DefaultCacheManager().getSingleFile(image);
    try {
      BotToast.showLoading();
      bool res = (await (WallpaperManager.setWallpaperFromFile(
          file.path, WallpaperManager.BOTH_SCREEN)));
      if (res) {
        BotToast.closeAllLoading();
        BotToast.showText(text: "Wallpaper and LockScreen set succesfully");
      }
    } on PlatformException {
      BotToast.closeAllLoading();
      BotToast.showText(text: "Failed to set image ");
    }
  }

  Future<void> sharedImage({required String image}) async {
    try {
      BotToast.showLoading();
      final result = await Share.shareUri(Uri.parse(image));
      print("Stat resul;t is $result");
      if (result.status == ShareResultStatus.success) {
        BotToast.closeAllLoading();
        BotToast.showText(text: "Shared succesfully");
      } else if (result.status == ShareResultStatus.dismissed) {
        BotToast.closeAllLoading();
        BotToast.showText(text: "Cacelled operation");
      } else if (result.status == ShareResultStatus.unavailable) {
        BotToast.closeAllLoading();
        BotToast.showText(text: "Unknown Issue");
      }
    } on PlatformException {
      BotToast.closeAllLoading();
      BotToast.showText(text: "Failed to share ");
    }
  }

  Future<void> saveImageToGallery({required String imageUrl}) async {
    try {
      //to download image
      final response = await Dio().get(imageUrl);
      //to get temp directory
      final dir = await getTemporaryDirectory();

      //create a file name
      var fileName = "${dir.path}/image.png";

//for saving to fileSystem
      var file = File(fileName);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      //showing dialog to save user to whichj location using package
      final params = SaveFileDialogParams()
    } catch (e) {}
  }
}