const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onWorkoutCreated = functions.firestore
  .document("users/{uid}/workouts/{hash}")
  .onCreate(async (snap, context) => {
    const { uid, hash } = context.params;
    const userRef = admin.firestore().doc(`users/${uid}`);

    return userRef.update({
      workoutHashes: admin.firestore.FieldValue.arrayUnion(hash)
    });
  });

exports.onWorkoutDeleted = functions.firestore
  .document("users/{uid}/workouts/{hash}")
  .onDelete(async (snap, context) => {
    const { uid, hash } = context.params;
    const userRef = admin.firestore().doc(`users/${uid}`);

    return userRef.update({
      workoutHashes: admin.firestore.FieldValue.arrayRemove(hash)
    });
  });
