import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
        'phone_number': phoneNumber,
      });

      await FirebaseFirestore.instance.collection('stores').doc(user.uid).set({
        'store_name': storeName,
        'store_schedule': {
          'Monday': {'open': 'Closed', 'close': 'Closed'},
          'Tuesday': {'open': 'Closed', 'close': 'Closed'},
          'Wednesday': {'open': 'Closed', 'close': 'Closed'},
          'Thursday': {'open': 'Closed', 'close': 'Closed'},
          'Friday': {'open': 'Closed', 'close': 'Closed'},
          'Saturday': {'open': 'Closed', 'close': 'Closed'},
          'Sunday': {'open': 'Closed', 'close': 'Closed'},
        },
        'longitude': 0,
        'latitude': 0,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create user data')),
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

        // Go to login page
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
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Image.network(
                'https://firebasestorage.googleapis.com/v0/b/unshelf-d4567.appspot.com/o/Unshelf.png?alt=media&token=ea449292-f36d-4dfe-a90a-2bef5c341694',
                height: 100,
              ),
              TextFormField(
                controller: _sellerNameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
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
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
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
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 10),
              const Text(
                  "By signing up, you agree to Unshelf's Terms of Use and Privacy Policy"),
              const SizedBox(height: 20),
              // Adding space above the sign-in section
              const SizedBox(height: 20),

              // Styled separator text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: Divider(color: Colors.grey[400])),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text('or sign up with',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider(color: Colors.grey[400])),
                ],
              ),

              const SizedBox(height: 20),

              // Google Sign-In button with icon
              ElevatedButton.icon(
                onPressed: _registerWithGoogle,
                label: const Text('Sign up with Google'),
                icon: Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/unshelf-d4567.appspot.com/o/image8-2.png?alt=media&token=4bfbc600-ed28-449e-ae22-86074884db57',
                    width: 24,
                    height: 24),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),

              const SizedBox(height: 40),
              const Text('Already have an account?'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginView()));
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
