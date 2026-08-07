import { createHash, randomInt } from "node:crypto";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";

import { getSmsConfig } from "./config";
import { createSmsProvider } from "./sms/providers";

const E164_PATTERN = /^\+[1-9]\d{6,14}$/;

export function normalizePhone(phone: string): string {
  let value = phone.replace(/[\s\-()]/g, "");
  if (!value.startsWith("+")) {
    value = `+${value}`;
  }
  return value;
}

export function assertValidPhone(phone: string): string {
  const normalized = normalizePhone(phone);
  if (!E164_PATTERN.test(normalized)) {
    throw new HttpsError("invalid-argument", "Numéro de téléphone invalide.");
  }
  return normalized;
}

function hashCode(code: string): string {
  return createHash("sha256").update(code).digest("hex");
}

function generateCode(): string {
  return randomInt(0, 1_000_000).toString().padStart(6, "0");
}

export async function sendPhoneVerificationCode(params: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  phone: string;
}): Promise<{ expiresInSeconds: number; debugCode?: string }> {
  const config = getSmsConfig();
  const phone = assertValidPhone(params.phone);
  const verificationRef = params.db.collection("phone_verifications").doc(params.uid);
  const existing = await verificationRef.get();
  const now = Date.now();

  if (existing.exists) {
    const lastSentAt = existing.get("lastSentAt") as Timestamp | undefined;
    if (lastSentAt) {
      const elapsedSeconds = (now - lastSentAt.toMillis()) / 1000;
      if (elapsedSeconds < config.resendCooldownSeconds) {
        const retryAfter = Math.ceil(config.resendCooldownSeconds - elapsedSeconds);
        throw new HttpsError(
          "resource-exhausted",
          `Veuillez patienter ${retryAfter}s avant de renvoyer un code.`,
        );
      }
    }
  }

  const code = generateCode();
  const expiresAt = Timestamp.fromMillis(now + config.codeTtlMinutes * 60 * 1000);
  const message =
    `${config.appName}: votre code de verification est ${code}. ` +
    `Il expire dans ${config.codeTtlMinutes} minutes.`;

  const smsProvider = createSmsProvider();
  await smsProvider.sendSms({ to: phone, message });

  await verificationRef.set({
    phone,
    codeHash: hashCode(code),
    expiresAt,
    attempts: 0,
    lastSentAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  return {
    expiresInSeconds: config.codeTtlMinutes * 60,
    debugCode: config.provider === "console" ? code : undefined,
  };
}

export async function verifyPhoneCode(params: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  code: string;
}): Promise<{ phone: string }> {
  const config = getSmsConfig();
  const verificationRef = params.db.collection("phone_verifications").doc(params.uid);
  const snapshot = await verificationRef.get();

  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Aucun code de verification en cours.");
  }

  const data = snapshot.data()!;
  const attempts = (data.attempts as number | undefined) ?? 0;
  if (attempts >= config.maxAttempts) {
    throw new HttpsError(
      "resource-exhausted",
      "Nombre maximal de tentatives atteint. Renvoyez un nouveau code.",
    );
  }

  const expiresAt = data.expiresAt as Timestamp;
  if (expiresAt.toMillis() < Date.now()) {
    throw new HttpsError("deadline-exceeded", "Le code a expire. Renvoyez un nouveau code.");
  }

  const submittedHash = hashCode(params.code.trim());
  if (submittedHash !== data.codeHash) {
    await verificationRef.update({
      attempts: attempts + 1,
      updatedAt: FieldValue.serverTimestamp(),
    });
    throw new HttpsError("invalid-argument", "Code incorrect.");
  }

  const phone = data.phone as string;
  const userRef = params.db.collection("users").doc(params.uid);
  const userSnapshot = await userRef.get();

  if (!userSnapshot.exists) {
    throw new HttpsError("failed-precondition", "Profil utilisateur introuvable.");
  }

  const establishmentId = userSnapshot.get("establishmentId") as string | undefined;
  const establishments =
    (userSnapshot.get("establishments") as string[] | undefined) ??
    (userSnapshot.get("establishmentIds") as string[] | undefined) ??
    [];
  const batch = params.db.batch();

  batch.update(userRef, {
    phoneVerified: true,
    phone,
    updatedAt: FieldValue.serverTimestamp(),
  });

  // Index téléphone → uid pour résoudre les invitations.
  const digitsPhone = phone.replace(/\D/g, "");
  batch.set(
    params.db.collection("phoneIndex").doc(digitsPhone),
    {
      uid: params.uid,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  const targetEstablishmentIds = new Set<string>(
    [...establishments, establishmentId].filter(
      (id): id is string => typeof id === "string" && id.length > 0,
    ),
  );

  for (const id of targetEstablishmentIds) {
    const establishmentRef = params.db.collection("establishments").doc(id);
    batch.update(establishmentRef, {
      phoneVerified: true,
      phone,
      updatedAt: FieldValue.serverTimestamp(),
    });
    const teamPayload = {
      phoneVerified: true,
      phone,
      updatedAt: FieldValue.serverTimestamp(),
    };
    batch.set(establishmentRef.collection("team").doc(params.uid), teamPayload, {
      merge: true,
    });
    batch.set(
      establishmentRef.collection("members").doc(params.uid),
      teamPayload,
      { merge: true },
    );
  }

  batch.delete(verificationRef);
  await batch.commit();

  return { phone };
}
