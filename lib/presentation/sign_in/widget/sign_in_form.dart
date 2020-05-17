import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shifty/application/sign_in_form_bloc.dart';
import 'package:shifty/domain/auth/auth_failure.dart';

class SignInForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInFormBloc, SignInFormState>(
      listener: (context, state) => listenToState(state, context),
      builder: (context, state) => buildForm(context, state),
    );
  }

  Widget buildForm(BuildContext context, SignInFormState state) {
    return Form(
      autovalidate: state.showErrorMessages,
      child: ListView(
        children: [
          const Text(
            '📝',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 130),
          ),
          const SizedBox(height: 8),
          emailTextForm(context),
          const SizedBox(height: 8),
          passwordTextForm(context),
          const SizedBox(height: 8),
          Row(
            children: [
              signInButton(context),
              registerButton(context),
            ],
          ),
          googleSignInButton(context)
        ],
      ),
    );
  }

  RaisedButton googleSignInButton(BuildContext context) {
    return RaisedButton(
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
        );
  }

  Expanded registerButton(BuildContext context) {
    return Expanded(
              child: FlatButton(
                onPressed: () {
                  context.bloc<SignInFormBloc>().add(
                    const SignInFormEvent
                        .registerWithEmailAndPasswordPressed(),
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
                    const SignInFormEvent
                        .signInWithEmailAndPasswordPressed(),
                  );
                },
                child: const Text('SIGN IN'),
              ),
            );
  }

  TextFormField passwordTextForm(BuildContext context) {
    return TextFormField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock),
            labelText: 'Password',
          ),
          autocorrect: false,
          obscureText: true,
          onChanged: (value) =>
              context
                  .bloc<SignInFormBloc>()
                  .add(SignInFormEvent.passwordChanged(value)),
          validator: (_) =>
              context
                  .bloc<SignInFormBloc>()
                  .state
                  .password
                  .value
                  .fold(
                    (f) =>
                    f.maybeMap(
                      shortPassword: (_) => 'Short Password',
                      orElse: () => null,
                    ),
                    (_) => null,
              ),
        );
  }

  TextFormField emailTextForm(BuildContext context) {
    return TextFormField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.email),
            labelText: 'Email',
          ),
          autocorrect: false,
          onChanged: (value) =>
              context
                  .bloc<SignInFormBloc>()
                  .add(SignInFormEvent.emailChanged(value)),
          validator: (_) =>
              context
                  .bloc<SignInFormBloc>()
                  .state
                  .emailAddress
                  .value
                  .fold(
                    (f) =>
                    f.maybeMap(
                      invalidEmail: (_) => 'Invalid Email',
                      orElse: () => null,
                    ),
                    (_) => null,
              ),
        );
  }

  void listenToState(SignInFormState state, BuildContext context) {
    state.authFailureOrSuccessOption.fold(
          () {},
          (either) =>
          either.fold(
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