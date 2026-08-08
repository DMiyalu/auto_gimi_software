import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { buildReportEmail } from "./emailTemplate";

describe("buildReportEmail", () => {
  it("renders app-like KPI grid and product section", () => {
    const { html, subject, text } = buildReportEmail({
      establishmentName: "Chez Zuri",
      kind: "weekly",
      periodLabel: "03/08/2026 – 09/08/2026",
      kpis: {
        revenue: 1500000,
        revenueChangePercent: 12.5,
        ordersCount: 42,
        ordersChangePercent: -3,
        averageBasket: 35714,
        averageBasketChangePercent: null,
        clientsServed: 30,
        clientsServedChangePercent: 5,
      },
      topProducts: [
        { libelle: "Burger", quantite: 20 },
        { libelle: "Jus", quantite: 10 },
      ],
    });

    assert.match(subject, /Chez Zuri/);
    assert.match(html, /Rapports/);
    assert.match(html, /Chiffre d'affaires/);
    assert.match(html, /Commandes/);
    assert.match(html, /Panier moyen/);
    assert.match(html, /Clients servis/);
    assert.match(html, /Répartition des ventes/);
    assert.match(html, /Burger/);
    assert.match(html, /#43A047/); // kpi revenue color
    assert.match(html, /#E53935/); // accent
    assert.match(text, /vs 7 j\. préc\./);
    assert.match(html, /Zuri Business/);
    assert.doesNotMatch(html, /ZOLANA/);
  });
});
