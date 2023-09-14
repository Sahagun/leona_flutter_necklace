import 'package:flutter/material.dart';
import 'package:leona/accout_page.dart';
import 'package:leona/ai_chat_page.dart';

class HomePage extends StatefulWidget {

  @override
  State createState() => _State();
}

class _State extends State {

  void navigateAccountPage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => AccountPage())
    );
  }

  void navigateAIChatPage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => AIChatPage())
    );
  }

  Widget body(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: Text(
              "Welcome to F.F.",
              style: TextStyle(
                  fontSize: 40
              )
            ),

          ),

          ElevatedButton(
            onPressed: navigateAIChatPage,
            child: Text(
              "AI Chat Helper",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

           Padding(
             padding: const EdgeInsets.only(top: 20.0),
             child: Text("Hope you have a good journey!"),
           ),
        ],
      ),
    );
  }


  void InfoAlert(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("F.F. Info"),
            content: const Text(
              "All the information about the application of college you want to know is available here!!! "

              "\n\nPlease ask the information you want to know !!!."),
            actions: [
              ElevatedButton(
                onPressed: (){Navigator.of(context).pop();},
                child: const Text('Back'),
              ),
            ],
          );
        }
    );
  }



  @override
  Widget build(context){
    return Scaffold(
        appBar: AppBar(
          // title: const Text("Welcome to F.F."),
          actions: [
            IconButton(onPressed: navigateAccountPage, icon: const Icon(Icons.person))
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: InfoAlert,
          child: const Icon(Icons.info),
        ),

        body: body()
    );
  }

}