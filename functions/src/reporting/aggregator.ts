import type { DateRange } from "./periods";
import { previousRange } from "./periods";

export interface OrderDoc {
  id: string;
  clientId?: string | null;
  statut?: string;
  montantTotal?: number;
  createdAt?: Date | null;
  isDeleted?: boolean;
}

export interface LineDoc {
  commandeId?: string;
  libelle?: string;
  quantite?: number;
  isDeleted?: boolean;
}

export interface ReportKpis {
  revenue: number;
  revenueChangePercent: number | null;
  ordersCount: number;
  ordersChangePercent: number | null;
  averageBasket: number;
  averageBasketChangePercent: number | null;
  clientsServed: number;
  clientsServedChangePercent: number | null;
}

export interface TopProduct {
  libelle: string;
  quantite: number;
}

interface PeriodMetrics {
  revenue: number;
  ordersCount: number;
  closedCount: number;
  clientsServed: number;
  averageBasket: number;
}

function inRange(createdAt: Date | null | undefined, range: DateRange): boolean {
  if (!createdAt) return false;
  const t = createdAt.getTime();
  return t >= range.start.getTime() && t < range.end.getTime();
}

function metricsFor(orders: OrderDoc[], range: DateRange): PeriodMetrics {
  let revenue = 0;
  let ordersCount = 0;
  let closedCount = 0;
  const clientIds = new Set<string>();

  for (const order of orders) {
    if (order.isDeleted) continue;
    if (order.statut === "annulees") continue;
    if (!inRange(order.createdAt ?? null, range)) continue;

    ordersCount++;
    const clientId = order.clientId?.trim();
    if (clientId) clientIds.add(clientId);

    if (order.statut === "cloturee") {
      closedCount++;
      revenue += Number(order.montantTotal ?? 0);
    }
  }

  return {
    revenue,
    ordersCount,
    closedCount,
    clientsServed: clientIds.size,
    averageBasket: closedCount === 0 ? 0 : revenue / closedCount,
  };
}

function percentChange(current: number, previous: number): number | null {
  if (previous === 0) {
    if (current === 0) return 0;
    return null;
  }
  return ((current - previous) / previous) * 100;
}

export function computeKpis(
  orders: OrderDoc[],
  range: DateRange,
): ReportKpis {
  const prior = previousRange(range);
  const current = metricsFor(orders, range);
  const previous = metricsFor(orders, prior);

  return {
    revenue: current.revenue,
    revenueChangePercent: percentChange(current.revenue, previous.revenue),
    ordersCount: current.ordersCount,
    ordersChangePercent: percentChange(
      current.ordersCount,
      previous.ordersCount,
    ),
    averageBasket: current.averageBasket,
    averageBasketChangePercent: percentChange(
      current.averageBasket,
      previous.averageBasket,
    ),
    clientsServed: current.clientsServed,
    clientsServedChangePercent: percentChange(
      current.clientsServed,
      previous.clientsServed,
    ),
  };
}

export function computeTopProducts(
  orders: OrderDoc[],
  lines: LineDoc[],
  range: DateRange,
  limit = 5,
): TopProduct[] {
  const closedIds = new Set<string>();
  for (const order of orders) {
    if (order.isDeleted) continue;
    if (order.statut !== "cloturee") continue;
    if (!inRange(order.createdAt ?? null, range)) continue;
    closedIds.add(order.id);
  }

  const totals = new Map<string, number>();
  for (const line of lines) {
    if (line.isDeleted) continue;
    const commandeId = line.commandeId ?? "";
    if (!closedIds.has(commandeId)) continue;
    const libelle = (line.libelle ?? "Produit").trim() || "Produit";
    const qty = Number(line.quantite ?? 0);
    totals.set(libelle, (totals.get(libelle) ?? 0) + qty);
  }

  return [...totals.entries()]
    .map(([libelle, quantite]) => ({ libelle, quantite }))
    .sort((a, b) => b.quantite - a.quantite)
    .slice(0, limit);
}
