import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'main_common.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env.prod");
  await mainCommon();
}
