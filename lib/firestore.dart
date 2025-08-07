// // Import the functions you need from the SDKs you need
// import { initializeApp } from "firebase/app";
// import { getAnalytics } from "firebase/analytics";
// // TODO: Add SDKs for Firebase products that you want to use
// // https://firebase.google.com/docs/web/setup#available-libraries

// // Your web app's Firebase configuration
// // For Firebase JS SDK v7.20.0 and later, measurementId is optional
// const firebaseConfig = {
//   apiKey: "AIzaSyBKlp7fFKv1XZyyERdj8dbh_TFgtnt9aBM",
//   authDomain: "oneyearaniversarry-23b42.firebaseapp.com",
//   projectId: "oneyearaniversarry-23b42",
//   storageBucket: "oneyearaniversarry-23b42.firebasestorage.app",
//   messagingSenderId: "297500254594",
//   appId: "1:297500254594:web:aa2270c71f84c7666f2f9b",
//   measurementId: "G-FJB1LMSZ5T"
// };

// // Initialize Firebase
// const app = initializeApp(firebaseConfig);
// const analytics = getAnalytics(app);

import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;

fff() {
  // firestore.collection('chat').doc('mTMEnsVosUos3jD4AfMz').collection('messages').get().then((querySnapshot) {
  //   for (var doc in querySnapshot.docs) {
  //     print(doc.data());
  //   }
  // });

  firestore.collection('chat').doc('mTMEnsVosUos3jD4AfMz').collection('messages').snapshots().listen((querySnapshot) {
    for (var doc in querySnapshot.docs) {
      print(doc.data());
    }
  });

  firestore.collection('allow').get().then((querySnapshot) {
    for (var doc in querySnapshot.docs) {
      print(doc.data());
    }
  });
}
