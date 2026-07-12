export type SmsProviderName = "africas_talking" | "twilio" | "console";

export interface SmsConfig {
  provider: SmsProviderName;
  appName: string;
  codeTtlMinutes: number;
  resendCooldownSeconds: number;
  maxAttempts: number;
}

export function getSmsConfig(): SmsConfig {
  const provider = (process.env.SMS_PROVIDER ?? "twilio") as SmsProviderName;

  return {
    provider,
    appName: process.env.APP_NAME ?? "Konnect One",
    codeTtlMinutes: Number(process.env.OTP_TTL_MINUTES ?? "10"),
    resendCooldownSeconds: Number(
      process.env.OTP_RESEND_COOLDOWN_SECONDS ?? "60",
    ),
    maxAttempts: Number(process.env.OTP_MAX_ATTEMPTS ?? "5"),
  };
}
