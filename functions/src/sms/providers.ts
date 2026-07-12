import twilio from "twilio";

import { getSmsConfig } from "../config";

export interface SendSmsInput {
  to: string;
  message: string;
}

export interface SmsProvider {
  sendSms(input: SendSmsInput): Promise<void>;
}

export class ConsoleSmsProvider implements SmsProvider {
  async sendSms(input: SendSmsInput): Promise<void> {
    console.log(`[SMS:console] to=${input.to} message=${input.message}`);
  }
}

export class AfricasTalkingSmsProvider implements SmsProvider {
  constructor(
    private readonly apiKey: string,
    private readonly username: string,
    private readonly senderId?: string,
  ) {}

  async sendSms(input: SendSmsInput): Promise<void> {
    const body = new URLSearchParams({
      username: this.username,
      to: input.to,
      message: input.message,
    });

    if (this.senderId) {
      body.set("from", this.senderId);
    }

    const response = await fetch(
      "https://api.africastalking.com/version1/messaging",
      {
        method: "POST",
        headers: {
          Accept: "application/json",
          apiKey: this.apiKey,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body.toString(),
      },
    );

    if (!response.ok) {
      const errorBody = await response.text();
      throw new Error(`Africa's Talking SMS failed: ${errorBody}`);
    }
  }
}

export class TwilioSmsProvider implements SmsProvider {
  private readonly client: ReturnType<typeof twilio>;

  constructor(
    accountSid: string,
    authToken: string,
    private readonly fromNumber: string,
  ) {
    this.client = twilio(accountSid, authToken);
  }

  async sendSms(input: SendSmsInput): Promise<void> {
    await this.client.messages.create({
      to: input.to,
      from: this.fromNumber,
      body: input.message,
    });
  }
}

export function createSmsProvider(): SmsProvider {
  const { provider } = getSmsConfig();

  if (provider === "africas_talking") {
    const apiKey = process.env.AFRICAS_TALKING_API_KEY;
    const username = process.env.AFRICAS_TALKING_USERNAME;
    if (!apiKey || !username) {
      throw new Error(
        "Africa's Talking requires AFRICAS_TALKING_API_KEY and AFRICAS_TALKING_USERNAME.",
      );
    }
    return new AfricasTalkingSmsProvider(
      apiKey,
      username,
      process.env.AFRICAS_TALKING_SENDER_ID,
    );
  }

  if (provider === "twilio") {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    const fromNumber = process.env.TWILIO_FROM_NUMBER;
    if (!accountSid || !authToken || !fromNumber) {
      throw new Error(
        "Twilio requires TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN and TWILIO_FROM_NUMBER.",
      );
    }
    return new TwilioSmsProvider(accountSid, authToken, fromNumber);
  }

  return new ConsoleSmsProvider();
}
