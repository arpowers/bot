#!/usr/bin/env node
/**
 * Midjourney image generation via Discord API
 *
 * Usage: node midjourney.js "your prompt here" [--ar 16:9]
 *
 * Requires env vars: SALAI_TOKEN, MJ_SERVER_ID, MJ_CHANNEL_ID
 */

import { Midjourney } from "midjourney";

const prompt = process.argv[2];
if (!prompt) {
  console.error("Usage: node midjourney.js \"prompt\" [--ar 16:9]");
  process.exit(1);
}

const { SALAI_TOKEN, MJ_SERVER_ID, MJ_CHANNEL_ID } = process.env;
if (!SALAI_TOKEN || !MJ_SERVER_ID || !MJ_CHANNEL_ID) {
  console.error("Missing env vars: SALAI_TOKEN, MJ_SERVER_ID, MJ_CHANNEL_ID");
  process.exit(1);
}

const client = new Midjourney({
  ServerId: MJ_SERVER_ID,
  ChannelId: MJ_CHANNEL_ID,
  SalaiToken: SALAI_TOKEN,
  Debug: false,
  Ws: true,
});

async function generate() {
  await client.init();

  console.error(`Generating: ${prompt}`);

  const msg = await client.Imagine(prompt, (uri, progress) => {
    console.error(`Progress: ${progress}`);
  });

  if (!msg) {
    console.error("No response from Midjourney");
    process.exit(1);
  }

  // Output JSON with image URL
  console.log(JSON.stringify({
    id: msg.id,
    hash: msg.hash,
    uri: msg.uri,
    proxy_url: msg.proxy_url,
    progress: msg.progress,
    content: msg.content,
  }, null, 2));

  client.Close();
}

generate().catch(err => {
  console.error("Error:", err.message);
  process.exit(1);
});
