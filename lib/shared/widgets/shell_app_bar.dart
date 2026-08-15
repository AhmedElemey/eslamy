import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// App bar that shows a back button on pushed routes and the shell menu
/// when the page is hosted as a tab.
class ShellAwareAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShellAwareAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  final Widget title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    return AppBar(
      title: title,
      actions: actions,
      leading: canPop
          ? null
          : IconButton(
              icon: Icon(Icons.menu_rounded, color: AppColors.heading(context)),
              onPressed: () => _openShellDrawer(context),
            ),
    );
  }
}

/// Nested tab Scaffolds intercept [Scaffold.of]; walk up to the shell drawer.
void _openShellDrawer(BuildContext context) {
  context.visitAncestorElements((element) {
    if (element is StatefulElement && element.state is ScaffoldState) {
      final scaffold = element.state as ScaffoldState;
      if (scaffold.hasDrawer) {
        scaffold.openDrawer();
        return false;
      }
    }
    return true;
  });
}
