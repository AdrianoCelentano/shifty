import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shifty/application/sign_in_form_bloc.dart';
import 'package:shifty/domain/auth/auth_failure.dart';
import 'package:shifty/presentation/sign_in/widget/sign_in_form_animation.dart';

import '../../../injection.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm>
    with SingleTickerProviderStateMixin {

  final SignInFormAnimation signInFormAnimation = getIt<SignInFormAnimation>();

  @override
  void initState() {
    super.initState();
    signInFormAnimation.init(this);
  }

  @override
  void dispose() {
    signInFormAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInFormBloc, SignInFormState>(
      listener: (context, state) => listenToState(state, context),
      builder: (context, state) => buildForm(context, state),
    );
  }

  Widget buildForm(BuildContext context, SignInFormState state) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        autovalidate: state.showErrorMessages,
        child: ListView(
          children: [
            logo(),
            const SizedBox(height: 8),
            emailTextForm(context),
            const SizedBox(height: 8),
            passwordTextForm(context),
            const SizedBox(height: 8),
            SlideTransition(
              position: signInFormAnimation.slideStartAnimation,
              child: Row(
                children: [
                  signInButton(context),
                  registerButton(context),
                ],
              ),
            ),
            googleSignInButton(context)
          ],
        ),
      ),
    );
  }

  SlideTransition logo() {
    return SlideTransition(
            position: signInFormAnimation.slideEndAnimation,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Lottie.network(
                  'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json'),
            ),
          );
  }

  SlideTransition googleSignInButton(BuildContext context) {
    return SlideTransition(
      position: signInFormAnimation.slideEndAnimation,
      child: RaisedButton(
        onPressed: () {
          context
              .bloc<SignInFormBloc>()
              .add(const SignInFormEvent.signInWithGooglePressed());
        },
        color: Colors.lightBlue,
        child: const Text(
          'SIGN IN WITH GOOGLE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Expanded registerButton(BuildContext context) {
    return Expanded(
      child: FlatButton(
        onPressed: () {
          context.bloc<SignInFormBloc>().add(
                const SignInFormEvent.registerWithEmailAndPasswordPressed(),
              );
        },
        child: const Text('REGISTER'),
      ),
    );
  }

  Expanded signInButton(BuildContext context) {
    return Expanded(
      child: FlatButton(
        onPressed: () {
          context.bloc<SignInFormBloc>().add(
                const SignInFormEvent.signInWithEmailAndPasswordPressed(),
              );
        },
        child: const Text('SIGN IN'),
      ),
    );
  }

  SlideTransition passwordTextForm(BuildContext context) {
    return SlideTransition(
      position: signInFormAnimation.slideEndAnimation,
      child: TextFormField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.lock),
          labelText: 'Password',
        ),
        autocorrect: false,
        obscureText: true,
        onChanged: (value) => context
            .bloc<SignInFormBloc>()
            .add(SignInFormEvent.passwordChanged(value)),
        validator: (_) =>
            context.bloc<SignInFormBloc>().state.password.value.fold(
                  (f) => f.maybeMap(
                    shortPassword: (_) => 'Short Password',
                    orElse: () => null,
                  ),
                  (_) => null,
                ),
      ),
    );
  }

  SlideTransition emailTextForm(BuildContext context) {
    return SlideTransition(
      position: signInFormAnimation.slideStartAnimation,
      child: TextFormField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.email),
          labelText: 'Email',
        ),
        autocorrect: false,
        onChanged: (value) => context
            .bloc<SignInFormBloc>()
            .add(SignInFormEvent.emailChanged(value)),
        validator: (_) =>
            context.bloc<SignInFormBloc>().state.emailAddress.value.fold(
                  (f) => f.maybeMap(
                    invalidEmail: (_) => 'Invalid Email',
                    orElse: () => null,
                  ),
                  (_) => null,
                ),
      ),
    );
  }

  void listenToState(SignInFormState state, BuildContext context) {
    handleAuthResult(state, context);
  }

  void handleAuthResult(SignInFormState state, BuildContext context) {
    state.authFailureOrSuccessOption.fold(
      () {},
      (either) => either.fold(
        (failure) => handleFailure(failure, context),
        (_) {
          // TODO: Navigate
        },
      ),
    );
  }

  void handleFailure(AuthFailure failure, BuildContext context) {
    FlushbarHelper.createError(
      message: failure.map(
        cancelledByUser: (_) => 'Cancelled',
        serverError: (_) => 'Server error',
        emailAlreadyInUse: (_) => 'Email already in use',
        invalidEmailAndPasswordCombination: (_) =>
            'Invalid email and password combination',
      ),
    ).show(context);
  }
}
