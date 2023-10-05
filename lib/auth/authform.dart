import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formkey = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _username = '';
  bool isLoginPage = false;
  //-----------------------------------------------------
  startAuthentication()  {
    FocusScope.of(context).unfocus();
    if (_formkey.currentState!.validate()){
      _formkey.currentState?.save();
      submitForm(_email,_password,_username);
    }
  }

  submitForm(String email,String password,String username,) async {
    final auth = FirebaseAuth.instance;
    UserCredential userCredential;

    try{
      if(isLoginPage){
        userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      }
      else{
        userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
        String? uid = userCredential.user?.uid;
        await FirebaseFirestore.instance.collection('user').doc(uid).set({
          'username': username,
          'email': email,
        });
      }
    }
    catch (err){
      print(err);
    }


  }
  //-----------------------------------------------------


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          Container(
            color: Colors.white,
            child: Image(
              image: const AssetImage("assets/images/img1.jpg"),
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isLoginPage)
                    TextFormField(
                      keyboardType: TextInputType.name,
                      key: const ValueKey('username'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Incorrect Username';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _username = value!;
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide()),
                          labelText: "Enter Username",
                          labelStyle: GoogleFonts.roboto()),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    key: const ValueKey('email'),
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Incorrect Email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide()),
                        labelText: "Enter Email",
                        labelStyle: GoogleFonts.roboto()),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    key: const ValueKey('password'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Incorrect Password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide()),
                        labelText: "Enter Password",
                        labelStyle: GoogleFonts.roboto()),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () {
                        startAuthentication();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10),
                        ),
                      ),
                      child: isLoginPage
                          ? Text(
                              'Login',
                              style: GoogleFonts.roboto(fontSize: 16),
                            )
                          : Text(
                              'SignUp',
                              style: GoogleFonts.roboto(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: (){
                      setState(() {
                        isLoginPage = !isLoginPage;
                      });
                    },
                    child: isLoginPage?  Text('Not a Member?',style: GoogleFonts.roboto(fontSize: 16)) :  Text('Already a Member?',style: GoogleFonts.roboto(fontSize: 16)),

                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
