// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import {getDatabase} from "firebase/database";
import {getFirestore} from "firebase/firestore";


const firebaseConfig = {
  apiKey: "AIzaSyBaz746KVj_ZArrgq1xjychfv0BSvbbPrs",
  authDomain: "riding-apps.firebaseapp.com",
  databaseURL: "https://riding-apps-default-rtdb.europe-west1.firebasedatabase.app",
  projectId: "riding-apps",
  storageBucket: "riding-apps.appspot.com",
  messagingSenderId: "1089330872285",
  appId: "1:1089330872285:web:b55081232d5df8bdd28034",
  measurementId: "G-69CJXF8L5G"
};

// Initialize Firebase
initializeApp(firebaseConfig);
export const db = getFirestore()
export const rltm = getDatabase()