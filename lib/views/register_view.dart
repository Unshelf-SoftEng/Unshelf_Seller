import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unshelf_seller/views/login_view.dart';
import 'package:unshelf_seller/views/home_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _sellerNameController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to save user data
  Future<void> saveUserData(
      User user, String name, String phoneNumber, String storeName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': user.email,
        'phoneNumber': phoneNumber,
        'type': 'seller',
        'isBanned': false,
      });

      // Initialization of the store data
      await FirebaseFirestore.instance.collection('stores').doc(user.uid).set({
        'storeSchedule': {
          'Monday': {'open': 'Closed', 'close': 'Closed'},
          'Tuesday': {'open': 'Closed', 'close': 'Closed'},
          'Wednesday': {'open': 'Closed', 'close': 'Closed'},
          'Thursday': {'open': 'Closed', 'close': 'Closed'},
          'Friday': {'open': 'Closed', 'close': 'Closed'},
          'Saturday': {'open': 'Closed', 'close': 'Closed'},
          'Sunday': {'open': 'Closed', 'close': 'Closed'},
        },
        'storeName': "",
        'storeImageUrl': "",
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create user data')),
      );
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        User user = userCredential.user!;
        await saveUserData(user, _sellerNameController.text,
            _phoneNumberController.text, _storeNameController.text);

        // User created successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful')),
        );

        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginView()));
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'The account already exists for that email.';
        } else {
          message = 'An error occurred: ${e.message}. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e. Please try again.')),
        );
      }
    }
  }

  Future<void> _registerWithGoogle() async {
    try {
      GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();

      _auth.signInWithProvider(_googleAuthProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeView()),
      );
    } catch (e) {
      String errorMessage;

      // Check if the error is a FirebaseAuthException
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage =
                'An account already exists with a different credential.';
            break;
          case 'invalid-credential':
            errorMessage = 'The credential provided is not valid.';
            break;
          case 'operation-not-allowed':
            errorMessage =
                'Operation not allowed. Please check your configuration.';
            break;
          case 'user-disabled':
            errorMessage = 'The user has been disabled.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found for this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          default:
            errorMessage = 'An unexpected error occurred. Please try again.';
            break;
        }
      } else {
        // Handle other types of errors, such as network errors
        errorMessage = '${e} Google sign-in failed. Please try again.';
        print(e);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        titleTextStyle: TextStyle(
            color: const Color(0xFF386641),
            fontSize: 20,
            fontWeight: FontWeight.bold),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
              TextFormField(
                controller: _sellerNameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA7C957)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA7C957)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA7C957)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA7C957)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA7C957)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA7C957)),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Password Confirmation',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA7C957)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA7C957)),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA7C957)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA7C957)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (value.length < 11) {
                    return 'Phone number must be at least 11 characters';
                  } else if (value[0] != '0' && value[1] != '9') {
                    return 'Phone number must start with 09';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Color(0xFFA7C957)),
                  foregroundColor: MaterialStatePropertyAll(Color(0xFF386641)),
                ),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 10),
              const Text(
                "By signing up, you agree to Unshelf's Terms of Use and Privacy Policy.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6A994E),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Divider(color: Colors.grey[400])),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text('or', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey[400])),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _registerWithGoogle,
                label: const Text('Log in with Google'),
                icon: Image.asset('assets/images/google_logo.png',
                    width: 24, height: 24, fit: BoxFit.contain),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color(0xFFA7C957),
                  foregroundColor: const Color(0xFF386641),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginView()),
                      );
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: Color(0xFF6A994E)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
