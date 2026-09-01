// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';


class ViewLampiranSakitScreen extends StatelessWidget {
  final String urlImage;
  const ViewLampiranSakitScreen({super.key, required this.urlImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lampiran Sakit"),
        backgroundColor: CustomTheme.kFagettiBlue,
        actions: const [],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: CachedNetworkImage(
            imageUrl: urlImage,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                // shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) =>
                const SizedBox(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.error),
                Text("404 Image Not Found\nPlease Contact Us")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
