import 'package:flutter/material.dart';
import 'package:parking_app/main.dart';

class NavbarFloatingButton extends StatefulWidget {
  NavbarFloatingButton({
    super.key,
    required this.currentPage,
    required this.setPage,
  });

  AppPage currentPage;
  void Function(AppPage page) setPage;

  @override
  NavbarFloatingButtonState createState() => NavbarFloatingButtonState();
}

class NavbarFloatingButtonState extends State<NavbarFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<Color?> _foregroundColorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _sizeAnimation = Tween<double>(
      begin: 32,
      end: 42,
    ).animate(_animationController);

    widget.currentPage == AppPage.dashboard
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _backgroundColorAnimation = ColorTween(
      begin: Theme.of(context).menuBackground,
      end: Theme.of(context).colorScheme.primary,
    ).animate(_animationController);

    _foregroundColorAnimation = ColorTween(
      begin: Theme.of(context).menuForeground,
      end: Theme.of(context).menuBackground,
    ).animate(_animationController);
  }

  @override
  void didUpdateWidget(NavbarFloatingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget != oldWidget) {
      widget.currentPage == AppPage.dashboard
          ? _animationController.forward()
          : _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundColorAnimation,
          _foregroundColorAnimation,
          _sizeAnimation
        ]),
        builder: (context, child) {
          return FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: _backgroundColorAnimation.value,
            foregroundColor: _foregroundColorAnimation.value,
            tooltip: 'Dashboard',
            onPressed: () => widget.setPage(AppPage.dashboard),
            child: Icon(
              Icons.dashboard_rounded,
              size: _sizeAnimation.value,
            ),
          );
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
