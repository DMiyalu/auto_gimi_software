import type { ReportKind } from "./periods";
import type { ReportKpis, TopProduct } from "./aggregator";

function formatCdf(amount: number): string {
  const rounded = Math.round(amount);
  return `${rounded.toLocaleString("fr-FR")} CDF`;
}

function formatPercent(value: number | null): string {
  if (value === null) return "—";
  const sign = value > 0 ? "+" : "";
  return `${sign}${value.toFixed(1)} %`;
}

export interface ReportEmailInput {
  establishmentName: string;
  kind: ReportKind;
  periodLabel: string;
  kpis: ReportKpis;
  topProducts: TopProduct[];
}

export function buildReportEmail(input: ReportEmailInput): {
  subject: string;
  text: string;
  html: string;
} {
  const kindLabel = input.kind === "weekly" ? "hebdo" : "mensuel";
  const subject = `[${input.establishmentName}] Rapport ${kindLabel} — ${input.periodLabel}`;

  const rows = [
    ["Chiffre d’affaires", formatCdf(input.kpis.revenue), formatPercent(input.kpis.revenueChangePercent)],
    ["Commandes", String(input.kpis.ordersCount), formatPercent(input.kpis.ordersChangePercent)],
    ["Panier moyen", formatCdf(input.kpis.averageBasket), formatPercent(input.kpis.averageBasketChangePercent)],
    ["Clients servis", String(input.kpis.clientsServed), formatPercent(input.kpis.clientsServedChangePercent)],
  ] as const;

  const topText =
    input.topProducts.length === 0
      ? "Aucun produit vendu sur la période."
      : input.topProducts
          .map((p, i) => `${i + 1}. ${p.libelle} — ${p.quantite}`)
          .join("\n");

  const text = [
    `Rapport ${kindLabel} — ${input.establishmentName}`,
    `Période : ${input.periodLabel}`,
    "",
    ...rows.map(([label, value, change]) => `${label} : ${value} (${change} vs période précédente)`),
    "",
    "Top produits :",
    topText,
    "",
    "Voir le détail dans l’app ZOLANA.",
  ].join("\n");

  const kpiHtml = rows
    .map(
      ([label, value, change]) => `
      <tr>
        <td style="padding:10px 12px;border-bottom:1px solid #eceef5;">${label}</td>
        <td style="padding:10px 12px;border-bottom:1px solid #eceef5;font-weight:700;">${value}</td>
        <td style="padding:10px 12px;border-bottom:1px solid #eceef5;color:#6b7280;">${change}</td>
      </tr>`,
    )
    .join("");

  const topHtml =
    input.topProducts.length === 0
      ? "<p style=\"color:#6b7280;\">Aucun produit vendu sur la période.</p>"
      : `<ol>${input.topProducts
          .map((p) => `<li><strong>${escapeHtml(p.libelle)}</strong> — ${p.quantite}</li>`)
          .join("")}</ol>`;

  const html = `<!DOCTYPE html>
<html>
<body style="font-family:Arial,sans-serif;color:#101529;background:#f6f7fb;padding:24px;">
  <table width="100%" cellpadding="0" cellspacing="0" style="max-width:560px;margin:0 auto;background:#fff;border-radius:12px;overflow:hidden;">
    <tr><td style="padding:24px 24px 8px;">
      <h1 style="margin:0 0 8px;font-size:22px;">Rapport ${kindLabel}</h1>
      <p style="margin:0;color:#6b7280;">${escapeHtml(input.establishmentName)}</p>
      <p style="margin:8px 0 0;color:#6b7280;">Période : ${escapeHtml(input.periodLabel)}</p>
    </td></tr>
    <tr><td style="padding:8px 24px 16px;">
      <table width="100%" cellpadding="0" cellspacing="0" style="border:1px solid #eceef5;border-radius:8px;">
        <tr style="background:#f8f9fc;color:#6b7280;font-size:12px;">
          <th align="left" style="padding:10px 12px;">Indicateur</th>
          <th align="left" style="padding:10px 12px;">Valeur</th>
          <th align="left" style="padding:10px 12px;">vs préc.</th>
        </tr>
        ${kpiHtml}
      </table>
    </td></tr>
    <tr><td style="padding:8px 24px 24px;">
      <h2 style="font-size:16px;margin:0 0 8px;">Top produits</h2>
      ${topHtml}
      <p style="margin:20px 0 0;color:#6b7280;font-size:13px;">Voir le détail dans l’app ZOLANA.</p>
    </td></tr>
  </table>
</body>
</html>`;

  return { subject, text, html };
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}
