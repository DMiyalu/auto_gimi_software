import { FieldValue, Firestore, Timestamp } from "firebase-admin/firestore";

import { computeKpis, computeTopProducts, type OrderDoc, type LineDoc } from "./aggregator";
import { buildReportEmail } from "./emailTemplate";
import { isValidReportEmail, normalizeEmail } from "./emailValidation";
import { getMailConfig, sendEmail } from "./mailer";
import {
  previousRange,
  reportRangeFor,
  type ReportKind,
} from "./periods";

export interface SendReportsResult {
  scanned: number;
  sent: number;
  skipped: number;
  errors: string[];
}

function asDate(value: unknown): Date | null {
  if (value instanceof Timestamp) return value.toDate();
  if (value instanceof Date) return value;
  if (typeof value === "string" || typeof value === "number") {
    const d = new Date(value);
    return Number.isNaN(d.getTime()) ? null : d;
  }
  return null;
}

async function loadOrders(
  db: Firestore,
  establishmentId: string,
  range: { start: Date; end: Date },
): Promise<OrderDoc[]> {
  // Load current + previous period window for KPI deltas.
  const prior = previousRange({
    start: range.start,
    end: range.end,
    periodKey: "",
    label: "",
  });
  const snap = await db
    .collection("establishments")
    .doc(establishmentId)
    .collection("commandes")
    .where("createdAt", ">=", Timestamp.fromDate(prior.start))
    .where("createdAt", "<", Timestamp.fromDate(range.end))
    .get();

  return snap.docs.map((doc) => {
    const data = doc.data();
    return {
      id: doc.id,
      clientId: (data.clientId as string | null | undefined) ?? null,
      statut: data.statut as string | undefined,
      montantTotal: (data.montantTotal as number | undefined) ?? 0,
      createdAt: asDate(data.createdAt),
      isDeleted: Boolean(data.isDeleted),
    };
  });
}

async function loadLines(
  db: Firestore,
  establishmentId: string,
): Promise<LineDoc[]> {
  const snap = await db
    .collection("establishments")
    .doc(establishmentId)
    .collection("ligne_commandes")
    .get();

  return snap.docs.map((doc) => {
    const data = doc.data();
    return {
      commandeId: data.commandeId as string | undefined,
      libelle: data.libelle as string | undefined,
      quantite: (data.quantite as number | undefined) ?? 0,
      isDeleted: Boolean(data.isDeleted),
    };
  });
}

async function alreadyDelivered(
  db: Firestore,
  establishmentId: string,
  periodKey: string,
): Promise<boolean> {
  const ref = db
    .collection("establishments")
    .doc(establishmentId)
    .collection("reportDeliveries")
    .doc(periodKey);
  const snap = await ref.get();
  return snap.exists;
}

async function markDelivered(
  db: Firestore,
  establishmentId: string,
  periodKey: string,
  meta: { kind: ReportKind; to: string },
): Promise<void> {
  await db
    .collection("establishments")
    .doc(establishmentId)
    .collection("reportDeliveries")
    .doc(periodKey)
    .set({
      kind: meta.kind,
      to: meta.to,
      sentAt: FieldValue.serverTimestamp(),
    });
}

export async function sendRestaurantReports(params: {
  db: Firestore;
  kind: ReportKind;
  now?: Date;
  /** When set, only this establishment is processed (test callable). */
  establishmentId?: string;
  /** Force re-send even if delivery doc exists. */
  force?: boolean;
}): Promise<SendReportsResult> {
  const now = params.now ?? new Date();
  const range = reportRangeFor(params.kind, now);
  const mailConfig = getMailConfig();
  const result: SendReportsResult = {
    scanned: 0,
    sent: 0,
    skipped: 0,
    errors: [],
  };

  if (params.establishmentId) {
    const doc = await params.db
      .collection("establishments")
      .doc(params.establishmentId)
      .get();
    if (!doc.exists) {
      result.errors.push(`Établissement introuvable: ${params.establishmentId}`);
      return result;
    }
    const data = doc.data()!;
    if (data.category !== "restaurant") {
      result.errors.push("L’établissement n’est pas un restaurant.");
      return result;
    }
    await processOne({
      db: params.db,
      establishmentId: doc.id,
      name: (data.name as string) ?? "Restaurant",
      ownerId: data.ownerId as string | undefined,
      kind: params.kind,
      range,
      mailConfig,
      force: params.force ?? false,
      result,
    });
    return result;
  }

  const snap = await params.db
    .collection("establishments")
    .where("category", "==", "restaurant")
    .get();
  for (const doc of snap.docs) {
    const data = doc.data();
    await processOne({
      db: params.db,
      establishmentId: doc.id,
      name: (data.name as string) ?? "Restaurant",
      ownerId: data.ownerId as string | undefined,
      kind: params.kind,
      range,
      mailConfig,
      force: false,
      result,
    });
  }

  return result;
}

async function processOne(args: {
  db: Firestore;
  establishmentId: string;
  name: string;
  ownerId: string | undefined;
  kind: ReportKind;
  range: ReturnType<typeof reportRangeFor>;
  mailConfig: ReturnType<typeof getMailConfig>;
  force: boolean;
  result: SendReportsResult;
}): Promise<void> {
  args.result.scanned++;

  try {
    if (!args.ownerId) {
      args.result.skipped++;
      return;
    }

    const ownerSnap = await args.db.collection("users").doc(args.ownerId).get();
    const emailRaw = ownerSnap.get("email");
    if (!isValidReportEmail(emailRaw)) {
      args.result.skipped++;
      return;
    }
    const to = normalizeEmail(emailRaw);

    if (!args.force && (await alreadyDelivered(args.db, args.establishmentId, args.range.periodKey))) {
      args.result.skipped++;
      return;
    }

    const orders = await loadOrders(args.db, args.establishmentId, args.range);
    const lines = await loadLines(args.db, args.establishmentId);
    const kpis = computeKpis(orders, args.range);
    const topProducts = computeTopProducts(orders, lines, args.range, 5);
    const email = buildReportEmail({
      establishmentName: args.name,
      kind: args.kind,
      periodLabel: args.range.label,
      kpis,
      topProducts,
    });

    await sendEmail(args.mailConfig, { to, ...email });
    await markDelivered(args.db, args.establishmentId, args.range.periodKey, {
      kind: args.kind,
      to,
    });
    args.result.sent++;
  } catch (error) {
    const message =
      error instanceof Error ? error.message : String(error);
    args.result.errors.push(`${args.establishmentId}: ${message}`);
  }
}
