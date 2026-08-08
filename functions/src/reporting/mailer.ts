import nodemailer from "nodemailer";

export type MailProviderName = "console" | "smtp" | "resend";

export interface MailConfig {
  provider: MailProviderName;
  from: string;
  smtp?: {
    host: string;
    port: number;
    secure: boolean;
    user: string;
    pass: string;
  };
  resendApiKey?: string;
}

export interface OutboundEmail {
  to: string;
  subject: string;
  text: string;
  html: string;
}

export function getMailConfig(): MailConfig {
  const provider = (process.env.MAIL_PROVIDER ?? "console") as MailProviderName;
  const from =
    process.env.REPORT_FROM_EMAIL ??
    process.env.MAIL_FROM ??
    "ZOLANA Rapports <noreply@zolana.app>";

  if (provider === "smtp") {
    return {
      provider,
      from,
      smtp: {
        host: process.env.SMTP_HOST ?? "",
        port: Number(process.env.SMTP_PORT ?? "587"),
        secure: (process.env.SMTP_SECURE ?? "false") === "true",
        user: process.env.SMTP_USER ?? "",
        pass: process.env.SMTP_PASS ?? "",
      },
    };
  }

  if (provider === "resend") {
    return {
      provider,
      from,
      resendApiKey: process.env.RESEND_API_KEY ?? "",
    };
  }

  return { provider: "console", from };
}

export async function sendEmail(
  config: MailConfig,
  email: OutboundEmail,
): Promise<void> {
  if (config.provider === "console") {
    console.log("[mail:console]", {
      from: config.from,
      to: email.to,
      subject: email.subject,
      text: email.text,
    });
    return;
  }

  if (config.provider === "resend") {
    const apiKey = config.resendApiKey;
    if (!apiKey) {
      throw new Error("RESEND_API_KEY manquant.");
    }
    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: config.from,
        to: [email.to],
        subject: email.subject,
        text: email.text,
        html: email.html,
      }),
    });
    if (!response.ok) {
      const body = await response.text();
      throw new Error(`Resend error ${response.status}: ${body}`);
    }
    return;
  }

  const smtp = config.smtp;
  if (!smtp?.host || !smtp.user || !smtp.pass) {
    throw new Error("Configuration SMTP incomplète.");
  }

  const transporter = nodemailer.createTransport({
    host: smtp.host,
    port: smtp.port,
    secure: smtp.secure,
    auth: { user: smtp.user, pass: smtp.pass },
  });

  await transporter.sendMail({
    from: config.from,
    to: email.to,
    subject: email.subject,
    text: email.text,
    html: email.html,
  });
}
