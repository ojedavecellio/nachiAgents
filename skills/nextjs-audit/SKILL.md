---
name: nextjs-audit
description: >
  Full-stack audit for local Next.js + Supabase + Vercel projects. Covers security
  (RLS, route protection, admin access, email headers, auth), database design
  (schema quality, indexes, relationships), performance (pagination, N+1 queries,
  bundle size, caching), and scalability strategy (SaaS readiness, infra growth,
  data retention). Runs entirely on local code — never hits production. Use when
  user says "audit", "revisar proyecto", "security check", "performance review",
  "is my app ready", or invokes /nextjs-audit.
---

# Next.js + Supabase + Vercel — Full Stack Audit

Comprehensive local-only audit for projects built on the Next.js + Supabase + Vercel stack. Analyzes code, migrations, RLS policies, route protection, performance patterns, and produces actionable findings with fixes.

## Invocation

```
/nextjs-audit [path]
```

- `path` is optional. If omitted, use the current working directory.
- The project MUST be a local Next.js project with Supabase. Verify by checking for `next.config.*` and `supabase/` directory (or `.env*` with Supabase keys).

## Scope

**Always local.** This skill reads source code, migration files, environment config, and route definitions. It never makes network requests to production, never connects to a live Supabase instance, never deploys anything.

## Architecture

The audit runs in 5 phases. The orchestrator coordinates and compiles the final report.

```
Phase 1: Discovery        (project structure, tech stack, dependencies)
     │
Phase 2: Security         (RLS, auth, routes, admin, email, headers)
     │
Phase 3: Database         (schema design, indexes, relationships, migrations)
     │
Phase 4: Performance      (queries, pagination, bundle, caching, fetching)
     │
Phase 5: Scalability      (infra strategy, SaaS readiness, data retention, growth plan)
     │
Final: Compile report + prioritized fix list
```

## Phase Details

### Phase 1: Discovery

Understand the project before auditing. Gather:

1. **Project structure:**
   - `app/` vs `pages/` router
   - API routes location (`app/api/` or `pages/api/`)
   - Middleware file (`middleware.ts`)
   - Supabase client initialization (where/how)
   - Auth provider (Supabase Auth, NextAuth, custom)

2. **Dependencies:**
   - Read `package.json` — note versions of next, @supabase/supabase-js, @supabase/ssr, @supabase/auth-helpers-nextjs
   - Check for deprecated packages (auth-helpers is deprecated in favor of @supabase/ssr)

3. **Supabase setup:**
   - `supabase/` directory presence
   - Migration files in `supabase/migrations/`
   - `supabase/config.toml` settings
   - Seed files
   - Edge functions in `supabase/functions/`

4. **Environment variables:**
   - `.env.local`, `.env`, `.env.example` — check what's declared
   - Verify `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` exist
   - Check for `SUPABASE_SERVICE_ROLE_KEY` usage (should NEVER be in client code)

5. **Vercel config:**
   - `vercel.json` — headers, redirects, rewrites, cron
   - Environment variable naming conventions

**Output:** Project profile summary used by all subsequent phases.

### Phase 2: Security

#### 2.1 RLS (Row Level Security)

Read ALL migration files and check:

- [ ] Every table has `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`
- [ ] Every table has at least one policy (tables with RLS enabled but no policies = locked out completely OR accessible to service_role only — flag which)
- [ ] Policies use `auth.uid()` correctly (not trusting client-supplied user_id)
- [ ] SELECT policies don't leak data cross-tenant
- [ ] INSERT policies validate ownership (e.g., `auth.uid() = user_id`)
- [ ] UPDATE policies prevent privilege escalation (can't change own role)
- [ ] DELETE policies are restrictive (or absent = good)
- [ ] No policy uses `TO public` with permissive access on sensitive tables
- [ ] `service_role` bypass is only used in server-side code, never exposed to client

**Common RLS failures to flag:**
- Table with no RLS at all (CRITICAL)
- Policy that uses `true` as check (allows everything)
- Policy that checks `user_id` from the request body instead of `auth.uid()`
- Missing policy for UPDATE/DELETE (defaults to deny — might be intentional, flag for review)

#### 2.2 Route Protection

- [ ] `middleware.ts` exists and protects authenticated routes
- [ ] Check middleware matcher patterns — are admin routes covered?
- [ ] API routes (`app/api/`) validate session/token before processing
- [ ] Server actions verify auth before mutations
- [ ] No client-only auth checks (hiding UI is not security)

**404 / Route Exposure:**
- [ ] Dynamic routes validate params (e.g., `/users/[id]` — does it return 404 for non-existent IDs or leak data?)
- [ ] Catch-all routes don't expose internal paths
- [ ] API routes return proper 404 vs 401 vs 403 (don't leak existence via different status codes)

#### 2.3 Admin Protection

- [ ] Admin routes are in a separate route group or have explicit middleware protection
- [ ] Admin API endpoints check role/permission, not just "is authenticated"
- [ ] Admin client pages don't just hide UI — server validates role
- [ ] Supabase admin operations use `service_role` only from server-side (API routes, server actions, edge functions)

#### 2.4 Email Security

If the project sends emails (check for Resend, SendGrid, nodemailer, Supabase Auth emails):

- [ ] SPF record consideration (note: can't verify locally, flag for manual check)
- [ ] DKIM setup (check if custom domain is configured in email provider)
- [ ] Email templates don't include unsanitized user input (XSS in emails)
- [ ] Password reset links are time-limited and single-use
- [ ] Email verification is required before granting access

#### 2.5 Auth & Session

- [ ] Supabase client is created correctly (separate browser/server clients)
- [ ] Tokens are not stored in localStorage (should use Supabase's built-in cookie handling with @supabase/ssr)
- [ ] `SUPABASE_SERVICE_ROLE_KEY` never appears in client-side code or `NEXT_PUBLIC_*` vars
- [ ] Middleware refreshes session on each request (prevents stale auth)
- [ ] Sign-out properly clears session

#### 2.6 Rate Limiting

Check if rate limiting is implemented on abuse-prone endpoints:

- [ ] Login/auth endpoints have rate limiting (prevent brute force)
- [ ] Signup/register endpoint has rate limiting (prevent mass account creation)
- [ ] Password reset endpoint has rate limiting (prevent email bombing)
- [ ] API routes that send emails have rate limiting
- [ ] API routes that cost money (AI calls, SMS, etc.) have rate limiting
- [ ] Rate limiting is server-side (not just client debounce)

**What to look for in code:**
- Packages: `@upstash/ratelimit`, `rate-limiter-flexible`, `express-rate-limit`, custom Redis-based
- Vercel's built-in: `vercel.json` with `"rateLimit"` config
- Supabase Edge Functions: check if they use rate limiting
- Next.js middleware-based rate limiting (IP + route based)

**Common failures:**
- No rate limiting anywhere (CRITICAL on auth endpoints)
- Rate limiting only on client side (useless — attacker bypasses)
- Rate limiting by user ID only (unauthenticated endpoints unprotected)
- No rate limiting on expensive operations (AI/LLM calls, file processing)

#### 2.7 CAPTCHA / Bot Protection

Check if CAPTCHA or bot protection exists on public-facing forms:

- [ ] Login form has CAPTCHA after N failed attempts (or always)
- [ ] Signup/register form has CAPTCHA
- [ ] Contact/public forms have CAPTCHA
- [ ] Password reset request has CAPTCHA
- [ ] Any form that triggers an email has bot protection

**What to look for in code:**
- Packages: `@hcaptcha/react`, `react-google-recaptcha`, `@turnstile/react` (Cloudflare), `react-turnstile`
- Server-side verification of CAPTCHA token (not just client-side widget)
- Honeypot fields as lightweight alternative
- Supabase Auth CAPTCHA integration (supports hCaptcha/Turnstile natively)

**Common failures:**
- CAPTCHA widget present but token never verified server-side (CRITICAL — decoration only)
- No bot protection on signup (mass account creation possible)
- No bot protection on any form that sends emails (spam vector)
- CAPTCHA secret key in client-side code (defeats the purpose)

#### 2.8 Environment Variables & Secret Exposure

- [ ] No secrets in `NEXT_PUBLIC_*` variables (these are bundled into client JS)
- [ ] `.env.local` is in `.gitignore`
- [ ] No hardcoded API keys, passwords, or tokens in source code
- [ ] `SUPABASE_SERVICE_ROLE_KEY` only used in server-side code (API routes, server actions, edge functions)
- [ ] Third-party API keys (OpenAI, Stripe, Resend, etc.) are NOT prefixed with `NEXT_PUBLIC_`
- [ ] No secrets logged to console (even in dev mode — these leak in Vercel logs)
- [ ] `.env.example` exists with placeholder values (not real keys)

**How to detect:**
- Grep all files for `NEXT_PUBLIC_` and verify each one is safe to expose (only Supabase URL and anon key should be public)
- Grep for hardcoded patterns: API key formats (`sk-`, `pk_live_`, `re_`, `whsec_`), base64 tokens, JWTs
- Check if any `process.env.SECRET_*` is referenced in files under `app/` without `"use server"` or in `page.tsx`/`layout.tsx` client components
- Check git history for accidentally committed `.env` files (flag for manual review)

**Common failures:**
- OpenAI/Anthropic key in `NEXT_PUBLIC_OPENAI_API_KEY` (CRITICAL — anyone can steal it from browser DevTools)
- Stripe secret key exposed client-side
- Service role key used in a client component (leaks full DB access)
- `.env` committed to git at some point (even if later removed — it's in history)

#### 2.9 Server-Side Boundary Enforcement

Verify that operations requiring server-side execution are actually server-side:

- [ ] Database mutations happen in server actions (`"use server"`) or API routes — never in client components
- [ ] Supabase `service_role` client only created in server context
- [ ] Third-party API calls with secret keys happen server-side only
- [ ] File uploads validated server-side (type, size, content) — not just client checks
- [ ] Payment/billing logic is server-side (Stripe webhooks, not client-side confirmation)
- [ ] Email sending is server-side only

**What to look for:**
- `"use client"` files importing sensitive env vars
- `createBrowserClient()` used where `createServerClient()` should be
- API calls to external services directly from client (instead of proxying through API route)
- Form validation only in client (no server re-validation)

**Common failures:**
- Calling OpenAI directly from a client component (exposes API key)
- Stripe checkout created client-side with secret key
- File upload goes directly to external service without server validation
- Business logic in client that should be a server action (price calculation, discount application)

#### 2.10 AI/LLM Usage Controls

If the project uses AI services (OpenAI, Anthropic, Replicate, Vercel AI SDK, etc.):

- [ ] AI calls are server-side only (API route or server action)
- [ ] Per-user rate limiting on AI endpoints (prevent one user draining budget)
- [ ] Per-user daily/monthly token or request cap
- [ ] Input validation before sending to AI (max length, sanitization)
- [ ] Output sanitization before rendering (prevent prompt injection → XSS)
- [ ] Cost monitoring or alerts configured (or at minimum, provider spending limits set)
- [ ] Streaming responses handled correctly (no full response buffered in memory)
- [ ] AI API key is NOT in `NEXT_PUBLIC_*`

**What to look for:**
- Packages: `openai`, `@anthropic-ai/sdk`, `ai` (Vercel AI SDK), `replicate`, `@google/generative-ai`
- Usage tracking: is there a `tokens_used` or `ai_requests` counter per user?
- Limits: is there a check before calling AI? (`if (user.aiRequestsToday >= limit) return 429`)
- Spending limits: provider dashboard config (can't verify locally — flag for manual check)

**Common failures:**
- No per-user limit on AI calls (one user can burn $1000 in API costs overnight) — CRITICAL
- AI endpoint accessible without authentication (anyone can use your API key)
- No input length validation (user sends 100k tokens, you pay for it)
- AI response rendered with `dangerouslySetInnerHTML` (XSS via prompt injection)
- No timeout on AI calls (user hangs indefinitely on slow response)

#### 2.11 Security Headers (Vercel/Next.js)

Check `next.config.js` or `vercel.json` for security headers:
- [ ] `X-Frame-Options: DENY`
- [ ] `X-Content-Type-Options: nosniff`
- [ ] `Strict-Transport-Security` (HSTS)
- [ ] `Content-Security-Policy`
- [ ] `Referrer-Policy`
- [ ] `Permissions-Policy`

### Phase 3: Database Design

Read all migration files (in order) and reconstruct the schema. Analyze:

#### 3.1 Schema Quality

- [ ] Tables have proper primary keys (prefer UUID over serial for multi-tenant)
- [ ] Foreign keys are defined with appropriate ON DELETE behavior
- [ ] Timestamps (`created_at`, `updated_at`) exist on mutable tables
- [ ] `updated_at` has a trigger to auto-update
- [ ] Column types are appropriate (don't use `text` for everything)
- [ ] Nullable columns make semantic sense (is NULL a valid state?)
- [ ] No redundant data stored (normalization appropriate to use case)

#### 3.2 Indexes

- [ ] Foreign key columns have indexes
- [ ] Columns used in WHERE clauses frequently have indexes
- [ ] Composite indexes for common query patterns
- [ ] No over-indexing on rarely-queried columns
- [ ] Unique constraints where business logic requires uniqueness

#### 3.3 Relationships

- [ ] Junction tables for many-to-many relationships (not JSON arrays)
- [ ] Cascade behavior is intentional (ON DELETE CASCADE vs RESTRICT vs SET NULL)
- [ ] Self-referential relationships are clean (e.g., parent_id in categories)
- [ ] No circular dependencies that could cause issues

#### 3.4 Multi-tenancy

- [ ] If multi-tenant: every user-facing table has a `user_id` or `org_id` column
- [ ] Tenant isolation is enforced at DB level (RLS), not just app level
- [ ] Shared/lookup tables are clearly separated from tenant data

#### 3.5 Audit & Logging Tables

- [ ] If audit tables exist: do they have a retention/cleanup strategy?
- [ ] Are audit tables growing unboundedly? Flag if no cleanup mechanism exists
- [ ] Recommend partitioning or archival for high-volume audit data

### Phase 4: Performance

#### 4.1 Data Fetching Patterns

- [ ] No "fetch all then filter client-side" patterns (check for `.select('*')` without `.limit()` or pagination)
- [ ] Pagination implemented for list endpoints (offset/limit or cursor-based)
- [ ] Count queries use `.count()` not fetching all rows
- [ ] No N+1 query patterns (fetching related data in a loop)
- [ ] Supabase queries select only needed columns (not `select('*')` when 3 columns are used)
- [ ] Server components fetch data server-side (not useEffect + client fetch for initial data)

#### 4.2 Caching

- [ ] `revalidate` or `cache` directives on data-fetching routes
- [ ] Static pages where possible (ISR for semi-dynamic content)
- [ ] Expensive computations memoized (React cache, unstable_cache)
- [ ] API responses have appropriate Cache-Control headers

#### 4.3 Bundle & Loading

- [ ] Dynamic imports for heavy components (`next/dynamic`)
- [ ] Images use `next/image` with appropriate sizes
- [ ] No massive client-side libraries imported in server components
- [ ] `"use client"` boundary is as low as possible in the tree
- [ ] Fonts loaded via `next/font` (not external CSS)

#### 4.4 Database Performance

- [ ] Queries that could be slow at scale (full table scans, LIKE '%...%')
- [ ] Missing indexes for common query patterns (identified in Phase 3)
- [ ] Realtime subscriptions on appropriate tables only (not everything)
- [ ] Connection pooling configured (Supabase uses PgBouncer — check if `?pgbouncer=true` is used where needed)

### Phase 5: Scalability & Strategy

#### 5.1 Current Architecture Assessment

- What's the current deployment model? (Vercel serverless + Supabase hosted)
- What are the scaling bottlenecks? (DB connections, serverless cold starts, edge function limits)
- Is the app stateless? (Can it scale horizontally?)

#### 5.2 SaaS Readiness (if applicable)

If the app has multi-user/org patterns, assess:

- [ ] Tenant isolation is complete (data, storage, billing)
- [ ] Billing/subscription integration exists or is planned
- [ ] Feature flags or tiered access control
- [ ] Onboarding flow for new tenants
- [ ] Admin dashboard for managing tenants

#### 5.3 Growth Strategy Recommendations

Based on the audit findings, provide recommendations on:

- **Stay on Vercel + Supabase** — when current usage fits free/pro tier limits
- **Upgrade tiers** — when approaching limits but architecture is fine
- **Move to VPS + Docker** — when:
  - Supabase costs exceed self-hosted PostgreSQL
  - Need persistent background workers
  - Need more control over DB (extensions, custom configs)
  - Volume of data makes Supabase pricing prohibitive
- **Hybrid approach** — Vercel for frontend, VPS for API/workers/DB

For VPS recommendations, include:
- Suggested architecture (Docker Compose, volumes, backup strategy)
- Migration path from Supabase (pg_dump, storage migration)
- Cost comparison at projected scale
- Monitoring & alerting needs

#### 5.4 Data Retention & Cleanup

- [ ] Identify tables that grow unboundedly (logs, events, notifications, audit trails)
- [ ] Recommend retention policies (30d, 90d, 1yr based on data type)
- [ ] Suggest archival strategy (cold storage, separate table, S3 export)
- [ ] Identify soft-delete patterns that never hard-delete (data bloat)
- [ ] Storage bucket cleanup (orphaned files, temp uploads never cleaned)

#### 5.5 High Availability Considerations

- Vercel: already multi-region by default (note limitations)
- Supabase: single-region by default — recommend read replicas if needed
- Point-in-time recovery configured?
- Backup strategy for user-uploaded files (Supabase Storage)
- Graceful degradation if Supabase is down (queue writes, show cached data)

## Output Format

The final report is saved to `{project_root}/AUDIT-REPORT.md` with this structure:

```markdown
# Audit Report: {project_name}

**Date:** {date}
**Stack:** Next.js {version} + Supabase + Vercel
**Router:** App Router / Pages Router
**Score:** {X}/100

## Executive Summary

{3-5 sentences: overall health, critical issues, top priorities}

## Scores by Category

| Category | Score | Critical | Major | Minor |
|----------|-------|----------|-------|-------|
| Security | X/25 | N | N | N |
| Database | X/25 | N | N | N |
| Performance | X/25 | N | N | N |
| Scalability | X/25 | N | N | N |

## Critical Findings (fix immediately)

{Findings that represent security vulnerabilities or data loss risk}

## Major Findings (fix soon)

{Findings that impact reliability, performance, or maintainability}

## Minor Findings (nice to have)

{Improvements that would enhance quality but aren't urgent}

## Scalability Strategy

{Growth recommendations based on Phase 5 analysis}

## Fix Checklist

- [ ] {Prioritized list of fixes, ordered by impact}
- [ ] ...

## Detailed Findings

### Security
{Full details per finding with code references and fix examples}

### Database
{Full details per finding with migration examples}

### Performance
{Full details per finding with before/after code}

### Scalability
{Full details per recommendation}
```

## Scoring Rubric

Each category is 25 points. Deductions:

- **Critical finding:** -5 points each
- **Major finding:** -3 points each
- **Minor finding:** -1 point each
- **Minimum score per category:** 0 (no negatives)

A project scoring 80+ is in good shape. Below 60 needs significant work. Below 40 has critical issues.

## What This Skill Does NOT Do

- Does NOT connect to live Supabase instances
- Does NOT run the project or make HTTP requests
- Does NOT modify any code (audit only — fixes are separate)
- Does NOT check deployed Vercel configuration (only local vercel.json)
- Does NOT run tests or build the project

If the user wants fixes applied after the audit, that's a separate ASDLC cycle using the audit report as input.
