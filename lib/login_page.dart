import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundary/student/profile.dart';
import 'staff_dash.dart';
import 'admin_dash.dart';

class LoginPage extends StatefulWidget {
  final String userType;

  const LoginPage({super.key, required this.userType});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isError = false;
  bool _isLoading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(BuildContext context) async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _usernameController.text.trim());
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  Future<void> _handleFirebaseAuthError(FirebaseAuthException e) async {
    if (!mounted) return;

    setState(() {
      _isError = true;
      _usernameController.clear();
      _passwordController.clear();
      _isLoading = false;
    });

    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No user found for that email.';
        break;
      case 'wrong-password':
        errorMessage = 'Wrong password provided for that user.';
        break;
      case 'invalid-email':
        errorMessage = 'The email address is badly formatted.';
        break;
      case 'user-disabled':
        errorMessage = 'This user has been disabled.';
        break;
      case 'too-many-requests':
        errorMessage = 'Too many requests to log into this account.';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Login with email and password is not enabled.';
        break;
      default:
        errorMessage = 'An unknown error occurred. Please try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  Future<void> _handleGeneralError(dynamic e) async {
    if (!mounted) return;
    print("Unexpected error: ${e.toString()}");
    setState(() {
      _isError = true;
      _usernameController.clear();
      _passwordController.clear();
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An unexpected error occurred.')),
    );
  }

  Future<void> _validateLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: _usernameController.text.trim(),
          password: _passwordController.text.trim());

      if (!mounted) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final userRole = userDoc.get('role');

        if ((widget.userType == "student" && userRole != "student") ||
            (widget.userType == "staff" && userRole != "staff") ||
            (widget.userType == "admin" && userRole != "admin")) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You are trying to login with the wrong user type.")),
          );
          await FirebaseAuth.instance.signOut();
          setState(() {
            _isLoading = false;
          });
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${widget.userType} Login Successful!")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => widget.userType == "student"
                  ? const ProfilePage()
                  : widget.userType == "staff"
                  ? const StaffDashboard()
                  : const AdminDashboard()), // Redirect Admins
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User role not found.")),
        );
        await FirebaseAuth.instance.signOut();
        setState(() {
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      await _handleFirebaseAuthError(e);
    } catch (e) {
      await _handleGeneralError(e);
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _resetError() {
    if (_isError) {
      setState(() {
        _isError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Login Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.userType == "admin") // Show only for admin
                const Text(
                  "ADMIN",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: widget.userType == "admin" ? 1 : 50),
              Container(
                height: widget.userType == "admin" ? 180 : 150, // Bigger for admin
                width: widget.userType == "admin" ? 180 : 150,  // Bigger for admin
                  child: Image.asset(
                    widget.userType == "admin"
                        ? 'assets/images/admin_logo.jpg' // Different image for admin
                        : 'assets/images/bennett_logo.webp', // Default for students & staff
                  ),
              ),
              SizedBox(height: widget.userType == "admin" ? 20 : 80),
              TextField(
                enableSuggestions: false,
                autocorrect: false,
                controller: _usernameController,
                onChanged: (_) => _resetError(),
                decoration: InputDecoration(
                  hintText: 'Username',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: _isError ? Colors.red : Colors.grey,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                enableSuggestions: false,
                autocorrect: false,
                controller: _passwordController,
                obscureText: !_passwordVisible,
                obscuringCharacter: '*',
                onChanged: (_) => _resetError(),
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: _isError ? Colors.red : Colors.grey,
                      width: 2,
                    ),
                  ),
                  suffixIcon: IconButton(
                  icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off, // Toggle icon
                  color: Colors.grey,
                  ),
                  onPressed: () {
                  setState(() {
                  _passwordVisible = !_passwordVisible; // Toggle state
                  });},
                ),
              ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    _resetPassword(context);
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        _validateLogin();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 150, vertical: 15),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold,fontSize: 14),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}