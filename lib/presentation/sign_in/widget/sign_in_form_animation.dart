
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:injectable/injectable.dart';

@injectable
class SignInFormAnimation {

  AnimationController _animController;
  Animation<Offset> slideStartAnimation;
  Animation<Offset> slideEndAnimation;

  void init(SingleTickerProviderStateMixin ticker) {
    _animController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: ticker,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.bounceIn,
    );

    slideStartAnimation = Tween<Offset>(
      begin: Offset(10, 0),
      end: Offset(0, 0),
    ).animate(curvedAnimation);

    slideEndAnimation = Tween<Offset>(
      begin: Offset(-10, 0),
      end: Offset(0, 0),
    ).animate(curvedAnimation);

    _animController.forward();
  }

  void dispose() {
    _animController.dispose();
  }

}