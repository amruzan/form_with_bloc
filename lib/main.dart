import 'package:flutter/material.dart';
import 'package:flutter_bloc_forms2/custom_validators.dart';
import 'package:flutter_bloc_forms2/register_page.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) {
        return FormThemeProvider(
            theme: FormTheme(
                checkboxTheme: CheckboxFieldTheme(canTapItemTile: true)),
            child: child!);
      },
      home: AllFormFields(),
    );
  }
}

class FieldsFormBloc extends FormBloc<String, String> {
  final nameText = TextFieldBloc(validators: [CustomValidators.nameRequired]);
  final pwdText = TextFieldBloc(validators: [CustomValidators.passwordRequired]);

  FieldsFormBloc() : super(autoValidate: true) {
    addFieldBlocs(fieldBlocs: [
      nameText,
      pwdText,
    ]);
  }

  @override
  void onSubmitting() async {
    try {
      emitSuccess(canSubmitAgain: true);
    } catch (e) {
      emitFailure(failureResponse: "Failed to Save");
    }
  }
}

class AllFormFields extends StatelessWidget {
  const AllFormFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FieldsFormBloc(),
      child: Builder(builder: (context) {
        final formBloc = BlocProvider.of<FieldsFormBloc>(context);
        return Scaffold(
          appBar: AppBar(
            title: Text("Login Page"),
          ),
          body: FormBlocListener<FieldsFormBloc, String, String>(
              onSubmitting: (context, state) {
                LoadingDialog.show(context);
              },
              onSubmissionFailed: (context, state) {
                LoadingDialog.hide(context);
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
              },
              onSuccess: (context, state) {
                LoadingDialog.hide(context);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => SuccessScreen(
                          name: formBloc.nameText.value,
                        )));
              },
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      Text("Welcome",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 30,color: Colors.blue),),
                      SizedBox(height: 20,),
                      TextFieldBlocBuilder(
                        textFieldBloc: formBloc.nameText,
                        decoration: InputDecoration(
                            labelText: "Enter Name",
                            prefixIcon: Icon(Icons.person)),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: formBloc.pwdText,
                        suffixButton: SuffixButton.obscureText,
                        decoration: InputDecoration(
                            labelText: "Enter Password",
                            prefixIcon: Icon(Icons.lock)),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0)),
                            )),
                            onPressed: () {
                              formBloc.submit();
                            },
                            child: Text("Sign In",style: TextStyle(fontSize: 15),)),
                      ),
                      SizedBox(height: 15,),
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Do not have an Account?",style: TextStyle(fontSize: 20,),),
                      TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>RegistrationPage()));
                      }, child: Text("Sign Up",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),))],)
                    ],
                  ),
                ),
              )),
        );
      }),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key? key}) => showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => LoadingDialog(key: key),
      ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(12.0),
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  SuccessScreen({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.tag_faces, size: 100),
            const SizedBox(height: 10),
            Text(
              'Welcome $name',
              style: TextStyle(fontSize: 54, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => AllFormFields())),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
