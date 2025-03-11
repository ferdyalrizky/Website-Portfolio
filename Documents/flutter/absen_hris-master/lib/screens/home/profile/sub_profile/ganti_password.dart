import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/utils/constant.dart';

import '../../../../theme/colors/light_colors.dart';
import '../../../../widgets/custom_snackbar_content.dart';
import '../../../../widgets/dialog.dart';
import '../../dashboard/sub_dashboard/components/custom_text_field_and_header.dart';

import 'package:http/http.dart' as http;

class GantiPasswordScreen extends StatefulWidget {
  final Karyawan currUser;
  const GantiPasswordScreen({super.key, required this.currUser});

  @override
  State<GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends State<GantiPasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  _onUpdatePasswordBtnPress() async {
    final validationSuccess = _formKey.currentState!.validate();
    final GlobalKey<State> keyLoader = GlobalKey<State>();

    String newPass = _formKey.currentState?.fields['new_pass']?.value;

    if (validationSuccess) {
      if (newPass.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Warning",
              msg: "Password harus min. 6 karakter",
              contentType: ContentType.warning,
            ),
          ),
        );
        return;
      }
      if (_formKey.currentState?.fields['new_pass']?.value !=
          _formKey.currentState?.fields['confirm_new_pass']?.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Warning",
              msg: "Password baru tidak cocok",
              contentType: ContentType.warning,
            ),
          ),
        );
        return;
      } else {
        Dialogs.loading(context, keyLoader, "Proses...");
      }
    } else {
      return;
    }

    var header = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };

    Map<String, String> body = {
      "password": _formKey.currentState?.fields['old_pass']?.value,
      "new_password": _formKey.currentState?.fields['new_pass']?.value,
    };

    print(body);
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$API_URL/v2/gantiPassword/${widget.currUser.id}'))
        ..headers.addAll(header)
        ..fields.addAll(body);
      var response = await request.send();

      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Ganti Password Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Failed",
              msg: "Password Lama Tidak Sesuai",
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title:
            const Text("Ganti Password", style: TextStyle(color: Colors.white)),
        backgroundColor: LightColors.kFagettiBlue,
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                const CustomTextFieldAndHeader(
                  header: "Password Lama",
                  txtFieldName: "old_pass",
                  keyboardType: TextInputType.name,
                  isRequired: true,
                  isObscure: true,
                ),
                const CustomTextFieldAndHeader(
                  header: "Password Baru",
                  txtFieldName: "new_pass",
                  keyboardType: TextInputType.name,
                  isRequired: true,
                  isObscure: true,
                ),
                const CustomTextFieldAndHeader(
                  header: "Confirm Password Baru",
                  txtFieldName: "confirm_new_pass",
                  keyboardType: TextInputType.name,
                  isRequired: true,
                  isObscure: true,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white24,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: LightColors.kFagettiBlue,
          ),
          onPressed: () async {
            showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Kamu yakin mengubah Password?',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Jika yakin, tidak bisa diubah",
                      style: TextStyle(
                        color: const Color(0xFF585858),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 131.w,
                        height: 40.r,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cek dulu deh',
                            style: TextStyle(
                              color: const Color(0xFF142638),
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 120.w,
                        height: 40.h,
                        child: TextButton(
                          onPressed: _onUpdatePasswordBtnPress,
                          style: TextButton.styleFrom(
                            backgroundColor: LightColors.kFagettiBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Yakin dong',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          child: const Text(
            'Update',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
