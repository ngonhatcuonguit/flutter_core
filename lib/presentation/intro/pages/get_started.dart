import 'package:flutter/material.dart';
import 'package:flutter_core_project/common/widgets/button/basic_app_button.dart';
import 'package:flutter_core_project/core/configs/assets/app_images.dart';
import 'package:flutter_core_project/core/configs/assets/app_vectors.dart';
import 'package:flutter_core_project/core/configs/theme/app_colors.dart';
import 'package:flutter_core_project/presentation/choose_mode/pages/choose_mode.dart';
import 'package:flutter_core_project/services/localization_service.dart';
import 'package:flutter_core_project/services/onboarding_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.introBG),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.15),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(
                    AppVectors.logo,
                    width: MediaQuery.of(context).size.width / 2,
                    height: null,
                  ),
                ),
                const Spacer(),
                Text(
                  localizations?.translate('enjoy_listening') ??
                      'Enjoy listening to music',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 21),
                Text(
                  localizations?.translate('intro_description') ??
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sagittis enim purus sed phasellus. Cursus ornare id scelerisque aliquam.',
                  style: const TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                BasicAppButton(
                  onPressed: () async {
                    // Mark intro as seen
                    await OnboardingService.setIntroSeen();

                    if (!context.mounted) return;

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const ChooseModePage()));
                  },
                  title:
                      localizations?.translate('get_started') ?? 'Get Started',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
