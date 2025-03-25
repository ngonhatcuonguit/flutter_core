
import 'package:flutter/material.dart';
import 'package:flutter_core_project/core/configs/assets/app_vectors.dart';
import 'package:flutter_core_project/presentation/intro/pages/get_started.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();

}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
          AppVectors.logo,
          // width: MediaQuery.of(context).size.width/2,
          // height: null,
          // fit: BoxFit.cover,
        )
      ),
    );
  }

  Future<void> redirect() async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedPage())
    );
  }

}