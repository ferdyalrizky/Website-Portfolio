import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/dialog.dart';
import 'package:hris_v2/widgets/profile_container.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../../../widgets/custom_snackbar_content.dart';

import 'package:http/http.dart' as http;

class ProfileBannerColumn extends StatefulWidget {
  final String name;
  final String jobTitle;
  final String? photoUrl;
  final String nip;
  final String apiToken;
  final String divisi;
  final int kryId;
  final Function onCallback;
  const ProfileBannerColumn({
    super.key,
    required this.name,
    required this.jobTitle,
    this.photoUrl,
    required this.nip,
    required this.onCallback,
    required this.apiToken,
    required this.kryId,
    required this.divisi,
  });

  @override
  State<ProfileBannerColumn> createState() => _ProfileBannerColumnState();
}

class _ProfileBannerColumnState extends State<ProfileBannerColumn> {
  pickProfilePicture() async {
    final GlobalKey<State> keyLoader = GlobalKey<State>();

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512.w,
      maxHeight: 512.w,
      imageQuality: 75,
    );
    if (image == null) return;

    Dialogs.loading(context, keyLoader, "Proses...");

    var header = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${widget.apiToken}',
    };
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$API_URL/v2/updateProfilePicture/${widget.kryId}'))
        ..headers.addAll(header);
      request.files.add(await http.MultipartFile.fromPath('photo', image.path));
      var response = await request.send();

      if (response.statusCode == 201) {
        var newUrlPath = await response.stream.bytesToString();
        newUrlPath = newUrlPath.replaceAll("\\", "");
        newUrlPath = newUrlPath.replaceAll("\"", "");
        SharedPreferences pref = await SharedPreferences.getInstance();

        await pref.setString("gambar", "asd");
        await pref.setString("gambar", newUrlPath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Berhasil ganti profile picture",
              contentType: ContentType.success,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Error",
              msg: "Gagal ganti profile picture",
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('error $e');
    }
    widget.onCallback();
    Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();
  }

  String capitalizeWords(String text) {
    // Memisahkan kata berdasarkan spasi
    List<String> words = text.split(' ');
    // Mengkapitalisasi huruf pertama dari setiap kata
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] =
            words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
      }
    }
    // Menggabungkan kembali kata-kata menjadi satu string
    return words.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return ProfileContainer(
      height: 200.w,
      width: double.infinity,
      color: CustomTheme.kFagettiBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          //Photo
          Padding(
            padding: EdgeInsets.all(1.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    widget.photoUrl == null || widget.photoUrl == ""
                        ? Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.1))
                              ],
                              color: LightColors.kFagettiBlue,
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: AssetImage('assets/images/avatar.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              border: Border.all(width: 0, color: Colors.white),
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.1))
                              ],
                              color: LightColors.kFagettiBlue,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                    '$API_URL_PROFILE_PICT/${widget.photoUrl}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    Positioned(
                      bottom: 0.r,
                      right: 0.r,
                      child: Container(
                        height: 32.w,
                        width: 36.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 4.w, color: Colors.white),
                          color: Colors.white,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            pickProfilePicture();
                          },
                          child: Icon(
                            size: 23.w,
                            Icons.camera_alt,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                //Name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
                      child: Text(
                        capitalizeWords(widget
                            .name), // Menggunakan fungsi untuk memformat teks
                        style: TextStyle(
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    //NIP
                    Text(
                      widget.nip,
                      style: TextStyle(
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Text(
                      widget.divisi,
                      style: TextStyle(
                        fontSize: 14.0.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      softWrap: true, // Menambahkan properti softWrap
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
