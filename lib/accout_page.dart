import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leona/login_page.dart';


class AccountPage extends StatefulWidget {

  @override
  _State createState() => _State();
}

class _State extends State<AccountPage>{


  void navigateToLoginScreen(){
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => LoginPage()),
            (route) => false
    );
  }

  void logout() async{
    await FirebaseAuth.instance.signOut();
    navigateToLoginScreen();
  }

  void deleteAccount() async{
    await FirebaseAuth.instance.currentUser!.delete();
    await FirebaseAuth.instance.signOut();
    navigateToLoginScreen();
  }

  void showDeleteAlert(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Delete Account"),
            content: const Text("Are you sure you want to delete your account. This action can not be undone."),
            actions: [
              ElevatedButton(
                onPressed: (){Navigator.of(context).pop();},
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: (){deleteAccount();},
                child: const Text('Delete'),
              ),
            ],

          );
        }
    );
  }

  Widget body(){
    String email = FirebaseAuth.instance.currentUser!.email!;
    return Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top:20.0),
            child: Icon(
                Icons.account_circle,
                size: 100
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(email),
          ),

          Padding(
            padding: const EdgeInsets.only(top:60.0),
            child: ElevatedButton(
                onPressed: logout,
                child: const Text("Logout")
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: showDeleteAlert,
                child: const Text("Delete Account")
            ),
          ),

        ]
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Center(child: body()),
    );
  }

}