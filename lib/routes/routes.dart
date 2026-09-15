import 'package:get/get.dart';
import 'package:ridelink_admin/views/auth_flow/auth_bindings.dart';
import 'package:ridelink_admin/views/auth_flow/view/login_view.dart';
import 'package:ridelink_admin/views/auth_flow/view/splash_view.dart';
import 'package:ridelink_admin/views/dashboard/dashboard_binding.dart';
import 'package:ridelink_admin/views/dashboard/view/dashboard_view.dart';

import 'routes_name.dart';

GetPage getPage({
  String? name,
  GetPageBuilder? page,
  Bindings? binding,
  List<GetPage<dynamic>>? children,
}) {
  return GetPage(
    name: name!,
    page: page!,
    binding: binding,
    children: children ?? [],
    participatesInRootNavigator: true,
    popGesture: true,
  );
}

List<GetPage> pages = [
  getPage(
    name: AppRoutes.splashView,
    page: () => const SplashView(),
    binding: AuthBindings(),
  ),
  getPage(
    name: AppRoutes.loginView,
    page: () => const LoginView(),
    binding: AuthBindings(),
  ),
  getPage(
    name: AppRoutes.dashboard,
    page: () => const DashboardView(),
    binding: DashboardBinding(),
  ),
];
