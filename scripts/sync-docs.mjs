#!/usr/bin/env node

import { existsSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { marked } from "marked";

const root = process.cwd();
const readmePath = path.join(root, "README.md");
const indexPath = path.join(root, "index.html");
const write = process.argv.includes("--write");

const syncStart = "<!-- SYNC:START -->";
const syncEnd = "<!-- SYNC:END -->";

function readFile(filePath) {
  return existsSync(filePath) ? readFileSync(filePath, "utf8") : "";
}

function normaliseMarkdown(markdown) {
  return markdown
    .replace(/^#\s+.*$/m, "")
    .trim();
}

function buildIndexHtml(markdown) {
  const content = marked.parse(normaliseMarkdown(markdown), {
    gfm: true,
    breaks: false
  });

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="DevOps Bootcamp Project documentation">
  <title>DevOps Bootcamp Project</title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

  <style>
    :root {
      --bg: #0b0f14;
      --panel: #131a22;
      --panel-soft: #1c2530;
      --border: #2b3745;
      --text: #dbe5ef;
      --muted: #93a4b7;
      --heading: #ffffff;
      --accent: #4dabf7;
      --accent-soft: rgba(77, 171, 247, 0.12);
      --code: #f3c677;
    }

    * {
      box-sizing: border-box;
    }

    html {
      scroll-behavior: smooth;
    }

    body {
      margin: 0;
      color: var(--text);
      background:
        radial-gradient(circle at top, #172333 0, var(--bg) 38rem),
        var(--bg);
      font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      line-height: 1.7;
    }

    .hero {
      padding: 5rem 1.5rem 3.5rem;
      text-align: center;
      border-bottom: 1px solid var(--border);
    }

    .eyebrow {
      display: inline-block;
      margin-bottom: 0.75rem;
      color: var(--accent);
      font-size: 0.78rem;
      font-weight: 700;
      letter-spacing: 0.14em;
      text-transform: uppercase;
    }

    .hero h1 {
      margin: 0;
      color: var(--heading);
      font-size: clamp(2.1rem, 6vw, 3.4rem);
      line-height: 1.15;
    }

    .hero p {
      max-width: 44rem;
      margin: 1rem auto 0;
      color: var(--muted);
    }

    .badges {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 0.6rem;
      margin-top: 1.5rem;
    }

    .badge {
      padding: 0.35rem 0.75rem;
      color: var(--text);
      background: var(--accent-soft);
      border: 1px solid rgba(77, 171, 247, 0.34);
      border-radius: 999px;
      font-size: 0.82rem;
      font-weight: 600;
      transition: transform 160ms ease, background 160ms ease;
    }

    .badge:hover {
      background: rgba(77, 171, 247, 0.22);
      transform: translateY(-2px);
    }

    main {
      width: min(100% - 2rem, 960px);
      margin: 0 auto;
      padding: 2.5rem 0 4rem;
    }

    #docs > h2 {
      margin: 2rem 0 0;
      padding: 1.25rem 1.5rem 0;
      color: var(--heading);
      background: var(--panel);
      border: 1px solid var(--border);
      border-bottom: 0;
      border-radius: 14px 14px 0 0;
      font-size: 1.35rem;
    }

    #docs > h2::before {
      content: "";
      display: inline-block;
      width: 0.55rem;
      height: 0.55rem;
      margin-right: 0.65rem;
      background: var(--accent);
      border-radius: 0.15rem;
      vertical-align: 0.05rem;
    }

    #docs > h2 + * {
      margin-top: 0;
      padding-top: 1rem;
      border-radius: 0 0 14px 14px;
    }

    #docs > :not(h2) {
      margin: 0;
      padding: 0 1.5rem 1.25rem;
      background: var(--panel);
      border-right: 1px solid var(--border);
      border-left: 1px solid var(--border);
    }

    #docs > :not(h2):last-child {
      border-bottom: 1px solid var(--border);
      border-radius: 0 0 14px 14px;
    }

    #docs h3,
    #docs h4 {
      color: var(--heading);
    }

    #docs h3 {
      margin-top: 1.75rem;
      font-size: 1.08rem;
    }

    #docs p,
    #docs ul,
    #docs ol,
    #docs table,
    #docs pre,
    #docs blockquote {
      margin-top: 0;
      margin-bottom: 1rem;
    }

    #docs ul,
    #docs ol {
      padding-left: 1.4rem;
    }

    #docs li + li {
      margin-top: 0.38rem;
    }

    strong {
      color: var(--heading);
    }

    a {
      color: var(--accent);
      text-decoration: none;
    }

    a:hover {
      text-decoration: underline;
    }

    code {
      padding: 0.14rem 0.35rem;
      color: var(--code);
      background: var(--panel-soft);
      border: 1px solid var(--border);
      border-radius: 0.3rem;
      font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
      font-size: 0.88em;
    }

    pre {
      overflow-x: auto;
      padding: 1rem;
      background: #0d131a;
      border: 1px solid var(--border);
      border-radius: 0.65rem;
    }

    pre code {
      padding: 0;
      color: var(--text);
      background: transparent;
      border: 0;
    }

    table {
      display: block;
      width: 100%;
      overflow-x: auto;
      border-collapse: collapse;
      font-size: 0.92rem;
    }

    th,
    td {
      padding: 0.7rem 0.8rem;
      text-align: left;
      vertical-align: top;
      border: 1px solid var(--border);
    }

    th {
      color: var(--heading);
      background: var(--panel-soft);
    }

    tr:hover td {
      background: rgba(255, 255, 255, 0.025);
    }

    blockquote {
      padding: 0.25rem 1rem;
      color: var(--muted);
      border-left: 3px solid var(--accent);
      background: var(--accent-soft);
    }

    img {
      display: block;
      max-width: 100%;
      height: auto;
      margin: 1rem auto;
      border: 1px solid var(--border);
      border-radius: 0.7rem;
    }

    footer {
      padding: 2rem 1.5rem 3rem;
      color: var(--muted);
      font-size: 0.9rem;
      text-align: center;
    }

    @media (max-width: 600px) {
      .hero {
        padding-top: 3.5rem;
      }

      #docs > h2 {
        padding: 1rem 1rem 0;
      }

      #docs > :not(h2) {
        padding-right: 1rem;
        padding-left: 1rem;
      }

      th,
      td {
        min-width: 10rem;
      }
    }
  </style>
</head>
<body>
  <header class="hero">
    <span class="eyebrow">Project documentation</span>
    <h1>DevOps Bootcamp Project</h1>
    <p>Infrastructure as Code with Terraform, Ansible, Docker, monitoring, and GitHub Actions.</p>

    <div class="badges" aria-label="Project technologies">
      <span class="badge">Terraform</span>
      <span class="badge">Ansible</span>
      <span class="badge">Docker</span>
      <span class="badge">Prometheus</span>
      <span class="badge">GitHub Actions</span>
    </div>
  </header>

  <main>
    <section id="docs">
      ${syncStart}
      ${content}
      ${syncEnd}
    </section>
  </main>

  <footer>
    Generated from <code>README.md</code> by the documentation sync pipeline.
  </footer>
</body>
</html>
`;
}

const readme = readFile(readmePath);

if (!readme) {
  console.error("README.md was not found or is empty.");
  process.exit(1);
}

const nextIndex = buildIndexHtml(readme);
const currentIndex = readFile(indexPath);
const changed = nextIndex !== currentIndex;

console.log("Sync direction: README.md -> index.html");
console.log(`README.md changed: false`);
console.log(`index.html changed: ${changed}`);

if (write && changed) {
  writeFileSync(indexPath, nextIndex);
  console.log("index.html updated.");
}

if (!write && changed) {
  console.log("Run with --write to update index.html.");
}
