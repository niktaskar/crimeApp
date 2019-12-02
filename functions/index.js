// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.onDataAdded = functions.database.ref("/{Complaint}").onWrite( (snapshot, context) =>{        
        var message = snapshot.after;

        console.log(message);
        console.log(context.params)
        
        var topic = "crimes";
        var payload = {
            "data" :{
                "Complaint": "Test",
                "DateOccur": "Test",
                "Description": "Test",
                "ILEADSAddress": "Test",
                "ILEADSStreet": "Test",
                "Type": "Test",
                "XCoord": "Test",
                "YCoord": "Test"
            }
        };

        return admin.messaging().sendToTopic(topic, payload).then((response) => {
            console.log("Notification sent out " + response);
            return;
        })
    });

