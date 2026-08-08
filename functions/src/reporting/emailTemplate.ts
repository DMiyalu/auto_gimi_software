import type { ReportKind } from "./periods";
import type { ReportKpis, TopProduct } from "./aggregator";

/** Couleurs alignées sur `ReportColors` (app Rapports). */
const colors = {
  accent: "#E53935",
  accentSoft: "#FFEBEE",
  trendUp: "#2E7D32",
  trendDown: "#C62828",
  kpiRevenue: "#43A047",
  kpiOrders: "#1E88E5",
  kpiBasket: "#FB8C00",
  kpiClients: "#8E24AA",
  pageBackground: "#F5F6FA",
  cardBackground: "#FFFFFF",
  textPrimary: "#101529",
  textMuted: "#7B819B",
  border: "#E8EAF0",
  barTrack: "#F0F1F5",
};

function formatCdf(amount: number): string {
  const rounded = Math.round(amount);
  return `${rounded.toLocaleString("fr-FR")} CDF`;
}

function formatTrend(
  value: number | null,
  comparisonLabel: string,
): { text: string; color: string } {
  if (value === null) {
    return { text: `— ${comparisonLabel}`, color: colors.textMuted };
  }
  const arrow = value >= 0 ? "↑" : "↓";
  const abs = Math.abs(value).toFixed(1).replace(".", ",");
  return {
    text: `${arrow} ${abs}% ${comparisonLabel}`,
    color: value >= 0 ? colors.trendUp : colors.trendDown,
  };
}

export interface ReportEmailInput {
  establishmentName: string;
  kind: ReportKind;
  periodLabel: string;
  kpis: ReportKpis;
  topProducts: TopProduct[];
}

interface KpiCardModel {
  label: string;
  value: string;
  iconBg: string;
  iconGlyph: string;
  trend: { text: string; color: string };
}

function kpiCardHtml(card: KpiCardModel): string {
  return `
<td width="50%" valign="top" style="padding:6px;">
  <table width="100%" cellpadding="0" cellspacing="0" role="presentation"
    style="background:${colors.cardBackground};border:1px solid ${colors.border};border-radius:16px;">
    <tr><td style="padding:14px;">
      <table cellpadding="0" cellspacing="0" role="presentation"><tr>
        <td width="36" height="36" align="center" valign="middle"
          style="background:${card.iconBg};border-radius:18px;color:#ffffff;font-size:16px;line-height:36px;">
          ${card.iconGlyph}
        </td>
      </tr></table>
      <p style="margin:12px 0 0;font-size:18px;font-weight:800;color:${colors.textPrimary};line-height:1.15;">
        ${escapeHtml(card.value)}
      </p>
      <p style="margin:4px 0 0;font-size:12px;color:${colors.textMuted};">
        ${escapeHtml(card.label)}
      </p>
      <p style="margin:8px 0 0;font-size:11px;font-weight:600;color:${card.trend.color};">
        ${escapeHtml(card.trend.text)}
      </p>
    </td></tr>
  </table>
</td>`;
}

function productRowsHtml(products: TopProduct[]): string {
  if (products.length === 0) {
    return `<p style="margin:0;color:${colors.textMuted};font-size:14px;">Aucun produit vendu sur la période.</p>`;
  }

  const maxQty = products.reduce((m, p) => Math.max(m, p.quantite), 0);

  return products
    .map((p, index) => {
      const pct = maxQty === 0 ? 0 : Math.round((p.quantite / maxQty) * 100);
      const rank = index + 1;
      return `
<table width="100%" cellpadding="0" cellspacing="0" role="presentation" style="margin-bottom:14px;">
  <tr>
    <td width="22" valign="middle" style="font-size:13px;font-weight:700;color:${colors.textMuted};">
      ${rank}
    </td>
    <td width="40" valign="middle">
      <table cellpadding="0" cellspacing="0" role="presentation"><tr>
        <td width="40" height="40" align="center" valign="middle"
          style="background:${colors.accentSoft};border-radius:10px;color:${colors.accent};font-size:18px;line-height:40px;">
          ✦
        </td>
      </tr></table>
    </td>
    <td style="padding-left:10px;" valign="middle">
      <p style="margin:0;font-size:14px;font-weight:700;color:${colors.textPrimary};">
        ${escapeHtml(p.libelle)}
      </p>
      <table width="100%" cellpadding="0" cellspacing="0" role="presentation" style="margin-top:6px;">
        <tr>
          <td style="background:${colors.barTrack};border-radius:4px;height:6px;">
            <table width="${Math.max(pct, 2)}%" cellpadding="0" cellspacing="0" role="presentation">
              <tr><td style="background:${colors.accent};height:6px;border-radius:4px;font-size:0;line-height:0;">&nbsp;</td></tr>
            </table>
          </td>
          <td width="48" align="right" style="padding-left:8px;font-size:12px;font-weight:700;color:${colors.textPrimary};white-space:nowrap;">
            ${p.quantite.toLocaleString("fr-FR")}
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>`;
    })
    .join("");
}

function kindMeta(kind: ReportKind): {
  label: string;
  short: string;
  comparisonLabel: string;
} {
  switch (kind) {
    case "weekly":
      return {
        label: "hebdo — semaine précédente",
        short: "hebdo préc.",
        comparisonLabel: "vs 7 j. préc.",
      };
    case "weekly_current":
      return {
        label: "hebdo — semaine en cours",
        short: "hebdo en cours",
        comparisonLabel: "vs 7 j. préc.",
      };
    case "monthly":
      return {
        label: "mensuel — mois précédent",
        short: "mensuel",
        comparisonLabel: "vs mois préc.",
      };
    case "daily":
      return {
        label: "du jour — aujourd’hui",
        short: "du jour",
        comparisonLabel: "vs hier",
      };
  }
}

export function buildReportEmail(input: ReportEmailInput): {
  subject: string;
  text: string;
  html: string;
} {
  const meta = kindMeta(input.kind);
  const kindLabel = meta.label;
  const comparisonLabel = meta.comparisonLabel;
  const subject = `[${input.establishmentName}] Rapport ${meta.short} — ${input.periodLabel}`;

  const cards: KpiCardModel[] = [
    {
      label: "Chiffre d'affaires",
      value: formatCdf(input.kpis.revenue),
      iconBg: colors.kpiRevenue,
      iconGlyph: "↗",
      trend: formatTrend(input.kpis.revenueChangePercent, comparisonLabel),
    },
    {
      label: "Commandes",
      value: String(input.kpis.ordersCount),
      iconBg: colors.kpiOrders,
      iconGlyph: "▣",
      trend: formatTrend(input.kpis.ordersChangePercent, comparisonLabel),
    },
    {
      label: "Panier moyen",
      value: formatCdf(input.kpis.averageBasket),
      iconBg: colors.kpiBasket,
      iconGlyph: "◉",
      trend: formatTrend(
        input.kpis.averageBasketChangePercent,
        comparisonLabel,
      ),
    },
    {
      label: "Clients servis",
      value: String(input.kpis.clientsServed),
      iconBg: colors.kpiClients,
      iconGlyph: "☺",
      trend: formatTrend(
        input.kpis.clientsServedChangePercent,
        comparisonLabel,
      ),
    },
  ];

  const topText =
    input.topProducts.length === 0
      ? "Aucun produit vendu sur la période."
      : input.topProducts
          .map((p, i) => `${i + 1}. ${p.libelle} — ${p.quantite}`)
          .join("\n");

  const text = [
    `Rapports — ${input.establishmentName}`,
    `Rapport ${kindLabel}`,
    `Période : ${input.periodLabel}`,
    "",
    ...cards.map(
      (c) => `${c.label} : ${c.value} (${c.trend.text})`,
    ),
    "",
    "Répartition des ventes",
    topText,
    "",
    "Voir le détail dans l’application Zuri Business.",
  ].join("\n");

  const html = `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Rapports</title>
</head>
<body style="margin:0;padding:0;background:${colors.pageBackground};font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Arial,sans-serif;color:${colors.textPrimary};">
  <table width="100%" cellpadding="0" cellspacing="0" role="presentation" style="background:${colors.pageBackground};padding:24px 12px;">
    <tr><td align="center">
      <table width="100%" cellpadding="0" cellspacing="0" role="presentation" style="max-width:560px;">

        <!-- Header type app -->
        <tr><td style="padding:0 4px 16px;">
          <h1 style="margin:0;font-size:28px;font-weight:800;color:${colors.textPrimary};line-height:1.15;">
            Rapports
          </h1>
          <p style="margin:6px 0 0;font-size:14px;font-weight:700;color:${colors.textPrimary};">
            ${escapeHtml(input.establishmentName)}
          </p>
          <p style="margin:4px 0 0;font-size:13px;color:${colors.textMuted};">
            Rapport ${kindLabel}
          </p>
          <table cellpadding="0" cellspacing="0" role="presentation" style="margin-top:12px;">
            <tr>
              <td style="background:${colors.accentSoft};color:${colors.accent};font-size:12px;font-weight:700;padding:6px 12px;border-radius:20px;">
                ${escapeHtml(input.periodLabel)}
              </td>
            </tr>
          </table>
        </td></tr>

        <!-- KPI grid 2×2 -->
        <tr><td>
          <table width="100%" cellpadding="0" cellspacing="0" role="presentation">
            <tr>
              ${kpiCardHtml(cards[0])}
              ${kpiCardHtml(cards[1])}
            </tr>
            <tr>
              ${kpiCardHtml(cards[2])}
              ${kpiCardHtml(cards[3])}
            </tr>
          </table>
        </td></tr>

        <!-- Produits -->
        <tr><td style="padding:12px 6px 0;">
          <table width="100%" cellpadding="0" cellspacing="0" role="presentation"
            style="background:${colors.cardBackground};border:1px solid ${colors.border};border-radius:16px;">
            <tr><td style="padding:16px 14px 12px;">
              <p style="margin:0;font-size:16px;font-weight:800;color:${colors.textPrimary};">
                Répartition des ventes
              </p>
              <p style="margin:2px 0 14px;font-size:13px;color:${colors.textMuted};">
                Consommations par produit
              </p>
              ${productRowsHtml(input.topProducts)}
            </td></tr>
          </table>
        </td></tr>

        <tr><td style="padding:20px 6px 0;">
          <p style="margin:0;font-size:13px;color:${colors.textMuted};text-align:center;">
            Voir le détail dans l’application Zuri Business.
          </p>
        </td></tr>

      </table>
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
