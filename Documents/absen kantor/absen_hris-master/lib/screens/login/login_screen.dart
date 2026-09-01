import 'dart:convert';
import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/custom_snackbar_content.dart';
import 'package:hris_v2/widgets/dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../home/home_navigation.dart';
import 'components/login_header.dart';
import '../../size_config.dart';
import '../../widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
var txtEmail = TextEditingController();
var txtPassword = TextEditingController();
String deviceToken = "";

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  //?[START Helper Method]
  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _doLogin(txtEmail.text, txtPassword.text);
    }
  }

  void _doLogin(String email, String password) async {
    final GlobalKey<State> _keyLoader = GlobalKey<State>();
    Dialogs.loading(context, _keyLoader, "Proses...");

    var url = Uri.parse('$API_URL/v2/login');

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            "userLogin": email,
            "password": password,
          }));
      //Cek userLogin / Password salah
      if (response.statusCode == 401) {
        Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Error",
              msg: "Email / Password salah",
              contentType: ContentType.failure,
            ),
          ),
        );
        return;
      }

      final output = jsonDecode(response.body);

      //cek departemen id lebih dari 1
      String departemenId = output['user']['departemen_id'].toString();
      String resultDepartemenId = "";
      String fixDepartemenId = "";
      if (departemenId.contains('[')) {
        resultDepartemenId = departemenId.replaceAll('[', '');
        resultDepartemenId = resultDepartemenId.replaceAll(']', '');
        resultDepartemenId = resultDepartemenId.replaceAll('"', '');
        resultDepartemenId = resultDepartemenId.replaceAll(' ', '');

        final split = resultDepartemenId.split(',');
        fixDepartemenId = split[0];
      } else {
        //Ga ada Departemen
        if (departemenId == "null") {
          Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              content: CustomSnackbarContent(
                title: "Error",
                msg: "Akun tidak memiliki departemen\nSilahkan hubungi Tim HRD",
                contentType: ContentType.failure,
              ),
            ),
          );
          return;
        }
        fixDepartemenId = departemenId;
      }
      //cek ada API Token ga
      if (output['user']['api_token'] == null) {
        Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Error",
              msg: "Lengkapi data diri terlebih dahulu di HRIS Web",
              contentType: ContentType.failure,
            ),
          ),
        );
        return;
      }

      //cek apakah ada divisi id
      if (output['user']['divisi_id'] == null) {
        Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Error",
              msg: "Akun tidak memiliki divisi\nSilahkan hubungi Tim HRD",
              contentType: ContentType.failure,
            ),
          ),
        );
        return;
      }

      if (output['user']['level'] == null) {
        Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Error",
              msg: "Akun tidak memiliki level\nSilahkan hubungi Tim HRD",
              contentType: ContentType.failure,
            ),
          ),
        );
        return;
      }

      if (response.statusCode == 201) {
        await saveSession(
          output: output,
          departemen: fixDepartemenId,
        );

        Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Login Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const HomeNavigation(),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            //output.toString(),
            'Email / Password Salah',
            style: const TextStyle(fontSize: 16),
          )),
        );
      }
    } catch (e) {
      Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
      Dialogs.popUp(
          context, 'Error API. Please Contact IT Team. $e || $url', null);
      debugPrint('$e');
    }
  }

  Future saveSession({
    required dynamic output,
    required String departemen,
  }) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool('biometric', true);
    await pref.setString("nama_karyawan", output['user']['nama_karyawan']);
    await pref.setString("nama_panggilan", output['user']['name']);
    await pref.setString("email", output['user']['email'] ?? "");
    await pref.setString("nip", output['user']['nip']);
    await pref.setString("no_hp", output['user']['no_hp'] ?? "");
    await pref.setString("gambar", output['user']['profile_photo_path'] ?? "");
    await pref.setString("job_title", output['user']['jobtitle'] ?? "");
    await pref.setString("api_token", output['user']['api_token']);
    await pref.setString("departemen", departemen);
    await pref.setString(
        "divisi", output['user']['divisi_join']['nama_divisi']);
    await pref.setInt("divisi_id", output['user']['divisi_join']['id']);
    await pref.setInt("level", output['user']['level']);
    await pref.setInt("user_id", output['user']['id']);
    await pref.setInt("bisnis_id", output['user']['bisnis_id']);
    await pref.setInt("area_kerja_id", output['user']['area_kerja_id']);
    await pref.setBool("is_login", true);
    await pref.setString('device_token', deviceToken);
    //_saveDeviceTokenToFirestore(
    //    deviceToken, output['user']['nip'], output['user']['nama_karyawan']);
  }

  _saveDeviceTokenToFirestore(
      String token, String nip, String namakaryawan) async {
    await FirebaseFirestore.instance.collection('karyawans').doc(nip).set({
      'token': token,
      'nama': namakaryawan,
      'platform': Platform.isIOS ? "iOS" : "Android",
    });
  }

  void _cekLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var islogin = pref.getBool("is_login");
    if (islogin != null && islogin) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const HomeNavigation(),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _onScanBarcodeBtnPress() async {
    String? barcodeScanRes; // Menggunakan String? untuk menangani nilai null

    try {
      // Menggunakan SimpleBarcodeScanner untuk melakukan pemindaian
      barcodeScanRes = await SimpleBarcodeScanner.scanBarcode(
          context); // Menyediakan konteks sebagai argumen
    } catch (e) {
      barcodeScanRes = 'Failed to scan barcode: $e';
    }

    if (!mounted) return;

    // Memeriksa apakah barcodeScanRes tidak null sebelum menetapkannya
    setState(() {
      txtEmail.text = barcodeScanRes ?? ''; // Jika null, tetapkan string kosong
    });
  }

//?[END Helper Method]

//&[START LifeCycle]
  @override
  void initState() {
    super.initState();
    requestNotifPermission();
    getDeviceToken();
    initInfo();
    _cekLogin();
  }

  void requestNotifPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('user granted provisional permission');
    } else {
      print('user declined or has not accepted permission');
    }
  }

  Future<void> getDeviceToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        print(token);
        deviceToken = token!;
      });
    });

    await pref.setString('device_token', deviceToken);
  }

  initInfo() async {
    var androidInit =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInit = const DarwinInitializationSettings();
    var initSetting =
        InitializationSettings(android: androidInit, iOS: iOSInit);

    await flutterLocalNotificationsPlugin.initialize(initSetting);

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      print("onMessage : ${msg.notification?.title}/${msg.notification?.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        msg.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: msg.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'ess',
        'ess',
        importance: Importance.max,
        styleInformation: bigTextStyleInformation,
        priority: Priority.max,
        playSound: false,
      );

      DarwinNotificationDetails iosNotificationDetails =
          const DarwinNotificationDetails();

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );
      await flutterLocalNotificationsPlugin.show(
        0,
        msg.notification!.title,
        msg.notification!.body,
        platformChannelSpecifics,
        payload: msg.data['title'],
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

//&[END LifeCycle]

//![START Screen Build]
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color(0xFFE6F1F8),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const LoginHeader(),
              Container(
                height: 645.r,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 2,
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.1))
                  ],
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      //*Title

                      Container(
                        padding: const EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: const Text(
                          'Masuk dengan email/nip Anda',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      //*TextField Email Password
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Email / nip *",
                              style: TextStyle(
                                  color: Color(0xFF717171),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTextField(
                              controller: txtEmail,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: (email) =>
                                  email == null || email.isEmpty
                                      ? 'Email atau NIP Harus Diisi'
                                      : null,
                            ),
                            const SizedBox(height: 25),
                            const Text(
                              "Password *",
                              style: TextStyle(
                                  color: Color(0xFF717171),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTextField(
                              controller: txtPassword,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: !_isPasswordVisible,
                              prefixIcon: Icons.lock_outline,
                              validator: (String? arg) {
                                if (arg == null || arg.isEmpty) {
                                  return 'Password harus diisi!';
                                } else {
                                  return null;
                                }
                              },
                              suffixIcon: _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              onSuffixIconPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 75.h,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 20.0, right: 20.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0277B7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: const BorderSide(color: Colors.blue),
                              ),
                              elevation: 10,
                              minimumSize: const Size(200, 58)),
                          onPressed: () => _validateInputs(),
                          label: const Text(
                            "Masuk",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 60,
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 20.0, right: 20.0),
                        child: ElevatedButton.icon(
                          onPressed: () => _onScanBarcodeBtnPress(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(
                                  color: Colors.black, width: 1.5),
                            ),
                          ),
                          label: const Text(
                            "Scan Barcode Kartu",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //![END Screen Build]
}
