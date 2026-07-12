import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2/options";

import {
  sendPhoneVerificationCode,
  verifyPhoneCode,
} from "./phoneVerification";

initializeApp();
setGlobalOptions({ region: "europe-west1" });

const db = getFirestore();

export const sendVerificationCode = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentification requise.");
  }

  const phone = request.data?.phone;
  if (typeof phone !== "string" || phone.trim().length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "Le numero de telephone est requis.",
    );
  }

  return sendPhoneVerificationCode({
    db,
    uid: request.auth.uid,
    phone,
  });
});

export const verifyVerificationCode = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentification requise.");
  }

  const code = request.data?.code;
  if (typeof code !== "string" || code.trim().length === 0) {
    throw new HttpsError("invalid-argument", "Le code est requis.");
  }

  return verifyPhoneCode({
    db,
    uid: request.auth.uid,
    code,
  });
});
