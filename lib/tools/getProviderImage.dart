import "package:flutter/material.dart";

Widget getProviderImage(String providerName) {
  switch (providerName) {
    case "Netflix":
      return Image.network(
        "https://s3.amazonaws.com/ionic-marketplace/ionic-4-netflix-style-video-streaming/icon.png",
      );
    case "Yelo Play":
      return Image.network(
          "https://cdn.fing.io/images/isp/BE/logo/telenet_logo.png");
    case "Disney Plus":
      return Image.network("https://pic.clubic.com/v1/images/1787948/raw");
    default:
      return Text(providerName);
  }
}
