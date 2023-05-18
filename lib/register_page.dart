import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_forms2/custom_validators.dart';
import 'package:flutter_bloc_forms2/main.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class FormRegistrationBloc extends FormBloc<String, String> {
  final testField = TextFieldBloc(validators:[FieldBlocValidators.required]);
  final nameField = TextFieldBloc(validators: [CustomValidators.nameRequired]);
  final emailField = TextFieldBloc(
      validators: [CustomValidators.emailRequired]);
  final dob = InputFieldBloc<DateTime?, Object>(initialValue: null);
  final gender = SelectFieldBloc(
      items: ['Male', 'Female'], validators: [FieldBlocValidators.required]);
  final qualification = SelectFieldBloc(items: ['Degree', 'Masters', 'Others']);

  static String? requiredValues(dynamic value) {
    if (value == null ||
        value == false ||
        ((value is Iterable || value is String || value is Map) &&
            value.length == 0)) {
      return "Enter name";
    }
    return null;
  }

  FormRegistrationBloc() : super(autoValidate: true) {
    addFieldBlocs(fieldBlocs: [
      this.testField,
      this.nameField,
      this.emailField,
      this.gender,
      this.dob,
      this.qualification,
    ]);
  }
  void addErrors(){
    testField.addFieldError("Test Field required");
    nameField.addFieldError("Name required");
    emailField.addFieldError("Email required");
    gender.addFieldError("Gender required");
    dob.addFieldError("D.O.B. required");
    qualification.addFieldError("Qualification required");
  }

  @override
  void onSubmitting() {
    print("On Submit");
    try {
      print(nameField.value);
      emitSuccess();

    }
    catch (e) {
      print(e.toString());
      emitFailure(failureResponse: e.toString());

    }
  }
}

class RegistrationPage extends StatelessWidget {
  RegistrationPage({Key? key}) : super(key: key);
  TextEditingController test = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormRegistrationBloc(),
      child: Builder(
          builder: (context) {
        final registrationBloc = BlocProvider.of<FormRegistrationBloc>(context);
        return Scaffold(
          appBar: AppBar(
            title: Text("Registration Page"),
          ),
          floatingActionButton: Container(child: FloatingActionButton.extended(onPressed: registrationBloc.addErrors,icon: Icon(Icons.error), label: Text("Required Fields")),),
          body: FormBlocListener<FormRegistrationBloc, String, String>(
            onSubmitting: (context, state) {
              print("Submitting..");
            },
            onSubmissionFailed: (context,state){
              print(registrationBloc.testField.value);
              print("Error Occurred");
            },
            onSuccess: (context, state) {
              Navigator.pop(context);
            },
            onFailure: (context, state) {
              print(state.failureResponse);
              final failResponse = state.failureResponse;
            },
            child: ScrollableFormBlocManager(
              formBloc: registrationBloc,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      BlocBuilder<TextFieldBloc, TextFieldBlocState>(
                        bloc: registrationBloc.testField,
                        builder: (context, state) {
                          return TextFormField(
                            controller: test,
                            onChanged: (val){
                              registrationBloc.testField.updateValue(val);
                            },
                            decoration: InputDecoration(labelText: "Test Field",errorText: state.canShowError ? state.error.toString() : ""),);
                        },
                      ),
                      SizedBox(height: 10,),
                      TextFieldBlocBuilder(
                        textFieldBloc: registrationBloc.nameField,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person), labelText: "Name"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: registrationBloc.emailField,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.mail), labelText: "Email"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DateTimeFieldBlocBuilder(
                        dateTimeFieldBloc: registrationBloc.dob,
                        format: DateFormat('dd/MM/yy'),
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon: Icon(Icons.calendar_month)
                        ),
                      ),
                      SizedBox(height: 10,),
                      RadioButtonGroupFieldBlocBuilder<String>(
                          selectFieldBloc: registrationBloc.gender,
                          decoration: InputDecoration(
                            labelText: "Gender",
                          ),
                          groupStyle: FlexGroupStyle(),
                          itemBuilder: (context, item) =>
                              FieldItem(child: Text(item))),
                      SizedBox(height: 10,),
                      DropdownFieldBlocBuilder<String>(
                          selectFieldBloc: registrationBloc.qualification,
                          decoration: InputDecoration(labelText: "Qualification",
                              prefixIcon: Icon(Icons.book_outlined)),
                          itemBuilder: (context, value) =>
                              FieldItem(
                                  child: Text(value))),
                      SizedBox(height: 10,),
                      Container(padding: EdgeInsets.all(5),
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // registrationBloc.addErrors();
                              registrationBloc.submit();
                            }, child: Text(
                            "Register", style: TextStyle(fontSize: 15),),
                            style: ButtonStyle(shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)))),))
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
