import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
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
}
