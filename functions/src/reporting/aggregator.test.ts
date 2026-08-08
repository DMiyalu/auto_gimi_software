import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { computeKpis, computeTopProducts, type OrderDoc } from "./aggregator";
import { isValidReportEmail } from "./emailValidation";
import {
  dailyReportRange,
  kinshasaMidnight,
  monthlyReportRange,
  weeklyCurrentReportRange,
  weeklyReportRange,
} from "./periods";

describe("isValidReportEmail", () => {
  it("accepts a normal address", () => {
    assert.equal(isValidReportEmail("owner@example.com"), true);
  });

  it("rejects empty or malformed", () => {
    assert.equal(isValidReportEmail(""), false);
    assert.equal(isValidReportEmail("nope"), false);
    assert.equal(isValidReportEmail(null), false);
  });
});

describe("periods", () => {
  it("weekly range is previous Mon→Mon (complete week before this Monday)", () => {
    // 2026-08-12 Wednesday Kinshasa → this Monday 10/08, period 03/08→10/08
    const now = kinshasaMidnight(2026, 8, 12);
    const range = weeklyReportRange(now);
    assert.equal(range.periodKey, "weekly_2026-08-03");
    assert.equal(range.start.getTime(), kinshasaMidnight(2026, 8, 3).getTime());
    assert.equal(range.end.getTime(), kinshasaMidnight(2026, 8, 10).getTime());
  });

  it("monthly range is previous calendar month", () => {
    const now = kinshasaMidnight(2026, 8, 1);
    const range = monthlyReportRange(now);
    assert.equal(range.periodKey, "monthly_2026-07");
    assert.equal(range.start.getTime(), kinshasaMidnight(2026, 7, 1).getTime());
    assert.equal(range.end.getTime(), kinshasaMidnight(2026, 8, 1).getTime());
  });

  it("weekly current is Monday through today", () => {
    const now = kinshasaMidnight(2026, 8, 12); // Wednesday
    const range = weeklyCurrentReportRange(now);
    assert.equal(range.periodKey, "weekly_current_2026-08-12");
    assert.equal(range.start.getTime(), kinshasaMidnight(2026, 8, 10).getTime());
    assert.equal(range.end.getTime(), kinshasaMidnight(2026, 8, 13).getTime());
  });

  it("daily is today only", () => {
    const now = kinshasaMidnight(2026, 8, 12);
    const range = dailyReportRange(now);
    assert.equal(range.periodKey, "daily_2026-08-12");
    assert.equal(range.start.getTime(), kinshasaMidnight(2026, 8, 12).getTime());
    assert.equal(range.end.getTime(), kinshasaMidnight(2026, 8, 13).getTime());
  });
});

describe("computeKpis", () => {
  const range = {
    start: kinshasaMidnight(2026, 8, 10),
    end: kinshasaMidnight(2026, 8, 17),
    periodKey: "weekly_2026-08-10",
    label: "10/08/2026 – 16/08/2026",
  };

  const orders: OrderDoc[] = [
    {
      id: "1",
      statut: "cloturee",
      montantTotal: 1000,
      clientId: "c1",
      createdAt: kinshasaMidnight(2026, 8, 11),
    },
    {
      id: "2",
      statut: "cloturee",
      montantTotal: 500,
      clientId: "c2",
      createdAt: kinshasaMidnight(2026, 8, 12),
    },
    {
      id: "3",
      statut: "annulees",
      montantTotal: 999,
      clientId: "c3",
      createdAt: kinshasaMidnight(2026, 8, 12),
    },
    {
      id: "4",
      statut: "en_cours",
      montantTotal: 200,
      clientId: "c1",
      createdAt: kinshasaMidnight(2026, 8, 13),
    },
    // previous week — for % comparison
    {
      id: "5",
      statut: "cloturee",
      montantTotal: 1000,
      clientId: "c9",
      createdAt: kinshasaMidnight(2026, 8, 4),
    },
  ];

  it("aggregates CA, orders, basket and clients", () => {
    const kpis = computeKpis(orders, range);
    assert.equal(kpis.revenue, 1500);
    assert.equal(kpis.ordersCount, 3); // excludes annulees
    assert.equal(kpis.averageBasket, 750);
    assert.equal(kpis.clientsServed, 2);
    assert.equal(kpis.revenueChangePercent, 50);
  });

  it("ranks top products on closed orders only", () => {
    const top = computeTopProducts(
      orders,
      [
        { commandeId: "1", libelle: "Burger", quantite: 2 },
        { commandeId: "2", libelle: "Burger", quantite: 1 },
        { commandeId: "3", libelle: "Pizza", quantite: 9 }, // canceled order
        { commandeId: "4", libelle: "Jus", quantite: 4 }, // not closed
      ],
      range,
      5,
    );
    assert.deepEqual(top, [{ libelle: "Burger", quantite: 3 }]);
  });
});
