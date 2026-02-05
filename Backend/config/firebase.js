// Import the functions you need from the SDKs you need
const  { initializeApp } =  require( "firebase/app");
const  {getDatabase}  = require( 'firebase/database');
const   {getFirestore}  = require( 'firebase/firestore');



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

const app = initializeApp(firebaseConfig)
const rtdb = getDatabase(app)
const db = getFirestore(app)

module.exports = {db,rtdb}