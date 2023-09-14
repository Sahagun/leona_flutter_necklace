import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:leona/classes/chat_bubble.dart';

class AIChatPage extends StatefulWidget {

  @override
  State createState() => _State();
}

class _State extends State {

  final TextEditingController textController = TextEditingController();

  bool waitingOnGPT = false;

  ListView messagesListView(Map<dynamic,dynamic> userMessages){
    List<String> keys = userMessages.keys.toList().map((item) => item as String).toList();
    keys.sort();
    keys = keys.reversed.toList();

    ListView lv =  ListView.builder(
        reverse: true,
        shrinkWrap: true,
        itemCount: userMessages.length,
        itemBuilder: (context, index){
          print(userMessages[keys[index]]);
          bool isCurrentUser = userMessages[keys[index]]['user'];
          String text = userMessages[keys[index]]['text'];

          return ChatBubble(text: text, isCurrentUser: isCurrentUser);
        }
    );

    return lv;
  }

  StreamBuilder messageStream() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(uid);

    return StreamBuilder(
      stream: ref.onValue,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot)
      {

        if(snapshot.hasData){
          if(snapshot.data!.snapshot.value == null){
            print('null');
            firstMessage();
            return Container();
          }
          else{


            Map<dynamic,dynamic> userData = snapshot.data!.snapshot.value as Map<dynamic,dynamic>;
            print(userData);


            ListView messages = messagesListView(userData);


            return messages;


            return Center(child: Text("Snapshot Data?"));
          }
        }
        else if(snapshot.hasError){
          print(snapshot.error);
          return const Text("Error in Stream");
        }
        print('loading...');
        return const CircularProgressIndicator();



      },
    );
  }


  void firstMessage() async{
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(uid);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    var data = {
      "${timestamp}": {
        "user": false,
        "text": "Hello Welcome to FF. How can I help you."
      }
    };
    await ref.update(data);
  }


  void send() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref(uid);
    int timestamp = DateTime
        .now()
        .millisecondsSinceEpoch;

    var data = {
      "${timestamp}": {
        "user": true,
        "text": textController.text
      }
    };

    String userInput = textController.text;

    textController.text = "";
    print('uploading user text');
    await ref.update(data);

    String message = "";

    setState(() {
      waitingOnGPT = true;
    });


    try {
      print('Open AI call');
      OpenAIChatCompletionModel completion = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: userInput,
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );
      timestamp = DateTime
          .now()
          .millisecondsSinceEpoch;

      print(completion);

      message = completion.choices[0].message.content;
    }
    catch (e){
      showSnackBar("An error has occurred with the AI. Try again later.");
    }

    setState(() {
      waitingOnGPT = false;
    });



    print('Open AI text update');

    try{
      data = {
        "${timestamp}": {
          "user": false,
          "text": message
        }
      };

      print('Open AI text update');
      await ref.update(data);
    }
    catch (e){
      showSnackBar("An error has occurred. Try again later.");
    }

  }

  void showSnackBar(String message){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.yellow,
            onPressed: (){ ScaffoldMessenger.of(context).hideCurrentSnackBar(); } ,
          ),
        )
    );
  }

  Widget body(){
    return Column(
      children: [
        Expanded(
            child: messageStream(),
        ),


        // Text Area
        Container(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    // color: Theme.of(context).canvasColor,
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0, right: 8.0),
                      child: TextFormField(
                        controller: textController,
                        // decoration: const InputDecoration(
                        //   labelText: 'Email',
                        //   hintText: 'user@example.com',
                        //   prefixIcon: Icon(Icons.email),
                        // ),
                      ),
                    ),
                  ),
                ),



                ElevatedButton(
                  onPressed: waitingOnGPT ? null : send,
                  child: Icon(Icons.send, color: Theme.of(context).primaryColor),
                ),

              ],
            ),
          ),
        )

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Chat"),
      ),
      body: Center(child: body()),
    );
  }


}
