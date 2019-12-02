// const firebase = require("firebase");
const fs = require("fs");
//
// require("firebase/firestore");
//
// var apiKey = "AIzaSyCTmEvXBRecAYmRCe89ZbZdwm4yvprd2m0";
// var appId = "1:770451968079:ios:39d705574f2379ea189a3a";
//
// // firebase.initializeApp({
// //     apiKey: apiKey,
// //     projectId: appId
// // });
//
// var db = firebase.firestore();
//
// console.log(db.collection("/stl_crimes_6_months").limit(1));
//
var data = fs.readFileSync("./SafetyBuddy/data.json");

var contents = JSON.parse(data);
//
// contents.forEach((crime) => {
//     // console.log(crime.Description);
//     db.collection("/stl_crimes_6_months/").add({
//         compaint: crime.Complaint,
//         inputMonth: crime.CodedMonth,
//         dateOccur: crime.DateOccur,
//         flagCrime: crime.FlagCrime,
//         count: crime.Count,
//         crime: crime.Crime,
//         district: crime.District,
//         description: crime.Description,
//         ileadsAddress: crime.ILEADSAddress,
//         ileadsStreet: crime.ILEADSStreet,
//         neighborhood: crime.Neighborhood,
//         locationName: crime.LocationName,
//         locationComment: crime.LocationComment,
//         cadAdress: crime.CADAddress,
//         cadStreet: crime.CADStreet,
//         xCoord: crime.XCoord,
//         yCoord: crime.YCoord
//     }).then((crime) => {
//         console.log(crime.Description);
//     }).catch((err) => {
//         console.log(err);
//     })
// });


var admin = require("firebase-admin");

var serviceAccount = require("./SafetyBuddy/serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://safetybuddy-30378.firebaseio.com"
});

const firestore = admin.firestore();

contents.forEach((docKey) => {
  firestore
      .collection("stl_crimes_6_months")
      .doc(docKey.Complaint)
      .set(docKey)
      .then((res) => {
        console.log("in");
      });
});

