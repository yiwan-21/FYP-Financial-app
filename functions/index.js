/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

const firestore = admin.firestore();
const messaging = admin.messaging();

export const sendToDevice = functions.firestore
  .document("messages/{messageId}")
  .onCreate(async snapshot => {
    const message = snapshot.data();

    // admin.messaging.MessagingPayload
    const payload = {
      notification: {
        title: message.title,
        body: message.body,
        icon: message.icon,
        click_action: FLUTTER_NOTIFICATION_CLICK
      }
    };

    return messaging.sendToDevice(message.token, payload);
  });