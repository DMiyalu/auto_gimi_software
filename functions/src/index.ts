import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { setGlobalOptions } from "firebase-functions/v2/options";

import {
  sendPhoneVerificationCode,
  verifyPhoneCode,
} from "./phoneVerification";
import { sendRestaurantReports } from "./reporting/sendReports";
import type { ReportKind } from "./reporting/periods";

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

export const sendWeeklyRestaurantReports = onSchedule(
  {
    schedule: "0 7 * * 1",
    timeZone: "Africa/Kinshasa",
  },
  async () => {
    const result = await sendRestaurantReports({ db, kind: "weekly" });
    console.log("weekly restaurant reports", result);
    if (result.errors.length > 0) {
      console.error("weekly report errors", result.errors);
    }
  },
);

export const sendMonthlyRestaurantReports = onSchedule(
  {
    schedule: "0 7 1 * *",
    timeZone: "Africa/Kinshasa",
  },
  async () => {
    const result = await sendRestaurantReports({ db, kind: "monthly" });
    console.log("monthly restaurant reports", result);
    if (result.errors.length > 0) {
      console.error("monthly report errors", result.errors);
    }
  },
);

/** Envoi de test (owner) pour un établissement restaurant. */
export const sendTestRestaurantReport = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentification requise.");
  }

  const establishmentId = request.data?.establishmentId;
  const kindRaw = request.data?.kind;
  if (typeof establishmentId !== "string" || establishmentId.trim().length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "establishmentId est requis.",
    );
  }

  const kind: ReportKind =
    kindRaw === "monthly" ? "monthly" : "weekly";

  const estSnap = await db.collection("establishments").doc(establishmentId).get();
  if (!estSnap.exists) {
    throw new HttpsError("not-found", "Établissement introuvable.");
  }
  if (estSnap.get("ownerId") !== request.auth.uid) {
    throw new HttpsError(
      "permission-denied",
      "Seul le propriétaire peut déclencher un envoi de test.",
    );
  }

  const result = await sendRestaurantReports({
    db,
    kind,
    establishmentId,
    force: true,
  });

  if (result.errors.length > 0) {
    throw new HttpsError("internal", result.errors.join(" | "));
  }
  if (result.sent === 0) {
    throw new HttpsError(
      "failed-precondition",
      "Aucun e-mail envoyé. Vérifiez que l’e-mail du propriétaire est renseigné.",
    );
  }

  return result;
});
