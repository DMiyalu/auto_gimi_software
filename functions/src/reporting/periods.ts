export type ReportKind = "weekly" | "monthly";

export interface DateRange {
  /** Inclusive start (UTC Date representing Kinshasa midnight). */
  start: Date;
  /** Exclusive end. */
  end: Date;
  periodKey: string;
  label: string;
}

const TIME_ZONE = "Africa/Kinshasa";

interface Ymd {
  year: number;
  month: number;
  day: number;
}

/** Calendar Y-M-D in Africa/Kinshasa for an instant. */
export function kinshasaYmd(instant: Date = new Date()): Ymd {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: TIME_ZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(instant);

  const year = Number(parts.find((p) => p.type === "year")?.value);
  const month = Number(parts.find((p) => p.type === "month")?.value);
  const day = Number(parts.find((p) => p.type === "day")?.value);
  return { year, month, day };
}

/**
 * Midnight Africa/Kinshasa for the given calendar day, as a UTC Date.
 * Kinshasa is UTC+1 year-round (no DST).
 */
export function kinshasaMidnight(year: number, month: number, day: number): Date {
  return new Date(Date.UTC(year, month - 1, day, 0, 0, 0) - 60 * 60 * 1000);
}

function addDays(ymd: Ymd, days: number): Ymd {
  const utc = Date.UTC(ymd.year, ymd.month - 1, ymd.day + days);
  const d = new Date(utc);
  return {
    year: d.getUTCFullYear(),
    month: d.getUTCMonth() + 1,
    day: d.getUTCDate(),
  };
}

function weekdayKinshasa(ymd: Ymd): number {
  // 0 = Sunday … 6 = Saturday in UTC calendar arithmetic on YMD
  return new Date(Date.UTC(ymd.year, ymd.month - 1, ymd.day)).getUTCDay();
}

function pad2(n: number): string {
  return String(n).padStart(2, "0");
}

function formatFr(ymd: Ymd): string {
  return `${pad2(ymd.day)}/${pad2(ymd.month)}/${ymd.year}`;
}

/**
 * Weekly report run on Monday 07:00 Kinshasa:
 * period = previous Mon 00:00 → this Mon 00:00 (7 closed calendar days).
 */
export function weeklyReportRange(now: Date = new Date()): DateRange {
  const today = kinshasaYmd(now);
  // Walk back to Monday of current week (Mon=1 … Sun=0 → treat Sun as 7)
  const dow = weekdayKinshasa(today); // 0 Sun
  const daysSinceMonday = dow === 0 ? 6 : dow - 1;
  const thisMonday = addDays(today, -daysSinceMonday);
  const prevMonday = addDays(thisMonday, -7);

  const start = kinshasaMidnight(
    prevMonday.year,
    prevMonday.month,
    prevMonday.day,
  );
  const end = kinshasaMidnight(
    thisMonday.year,
    thisMonday.month,
    thisMonday.day,
  );
  const endInclusive = addDays(thisMonday, -1);

  return {
    start,
    end,
    periodKey: `weekly_${prevMonday.year}-${pad2(prevMonday.month)}-${pad2(prevMonday.day)}`,
    label: `${formatFr(prevMonday)} – ${formatFr(endInclusive)}`,
  };
}

/** Previous calendar month relative to `now` in Kinshasa. */
export function monthlyReportRange(now: Date = new Date()): DateRange {
  const today = kinshasaYmd(now);
  const firstThisMonth = { year: today.year, month: today.month, day: 1 };
  const prevMonth =
    today.month === 1
      ? { year: today.year - 1, month: 12, day: 1 }
      : { year: today.year, month: today.month - 1, day: 1 };

  const start = kinshasaMidnight(
    prevMonth.year,
    prevMonth.month,
    prevMonth.day,
  );
  const end = kinshasaMidnight(
    firstThisMonth.year,
    firstThisMonth.month,
    firstThisMonth.day,
  );
  const lastDayPrev = addDays(firstThisMonth, -1);

  return {
    start,
    end,
    periodKey: `monthly_${prevMonth.year}-${pad2(prevMonth.month)}`,
    label: `${formatFr(prevMonth)} – ${formatFr(lastDayPrev)}`,
  };
}

export function previousRange(range: DateRange): DateRange {
  const durationMs = range.end.getTime() - range.start.getTime();
  const start = new Date(range.start.getTime() - durationMs);
  const end = new Date(range.start.getTime());
  return {
    start,
    end,
    periodKey: `prev_${range.periodKey}`,
    label: "période précédente",
  };
}

export function reportRangeFor(
  kind: ReportKind,
  now: Date = new Date(),
): DateRange {
  return kind === "weekly" ? weeklyReportRange(now) : monthlyReportRange(now);
}
