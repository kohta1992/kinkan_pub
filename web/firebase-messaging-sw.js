importScripts("https://www.gstatic.com/firebasejs/8.0.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.0.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyDuqslB6Z4VqNNRbmpqQFyYgu_B-z6Er1I",
    authDomain: "kintai-generator.firebaseapp.com",
    databaseURL: "https://kintai-generator.firebaseio.com",
    projectId: "kintai-generator",
    storageBucket: "kintai-generator.appspot.com",
    messagingSenderId: "468603114506",
    appId: "1:468603114506:web:3b101242db6b4f08b3fbf3"
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});