import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/my_drawer.dart';
import 'package:social_media_app/components/my_list_tile.dart';
import 'package:social_media_app/components/my_post_button.dart';
import 'package:social_media_app/components/my_textfield.dart';
import 'package:social_media_app/database/firestore.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  // text controller
  final TextEditingController newPostController = TextEditingController();

  // firestore access
  final FirestoreDatabase database = FirestoreDatabase();

  // post message
  void postMessage() {
    // only post message if there is something in the textfield
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      database.addPost(message);
    }

    // clear controller
    newPostController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text("W A L L"),
          centerTitle: true,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        drawer: MyDrawer(),
        body: Column(
          children: [
            // textfeild box for user to type
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextfield(
                        hintText: "Say something...",
                        controller: newPostController,
                        obscureText: false),
                  ),

                  // post button
                  MyPostButton(onTap: postMessage)
                ],
              ),
            ),

            SizedBox(height: 25),

            // post
            StreamBuilder(
              stream: database.getPostsStream(),
              builder: (context, snapshot) {
                // show loading circle
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // get all post
                final posts = snapshot.data!.docs;

                // no data
                if (snapshot.data == null || posts.isEmpty) {
                  return Center(child: Text('There is no post'));
                }

                // return a list
                return Expanded(
                    child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    // get each individual post
                    final post = posts[index];

                    // get data from each post
                    String message = post['PostMessage'];
                    String userEmail = post['UserEmail'];
                    Timestamp timestamp = post['TimeStamp'];

                    // return a list tile
                    return MyListTile(title: message, subtitle: userEmail);
                  },
                ));
              },
            )
          ],
        ));
  }
}
