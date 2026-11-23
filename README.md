# UPSC Peer Review: Vercel + Supabase
Static front end (no build step) + Supabase (login, database, file storage). Only admins can post questions.

## 1. Supabase (free)
1. supabase.com > New project (region: Mumbai or Singapore).
2. SQL Editor > paste `supabase/schema.sql` > Run.
3. Authentication > URL Configuration: set Site URL to your Vercel URL (after step 3); add it to Redirect URLs.
4. Project Settings > API: copy Project URL and the anon public key.

## 2. Configure
Edit `config.js` with that URL and anon key (never the service_role key).

## 3. Deploy to Vercel
Option A (GitHub): push this folder to a GitHub repo > vercel.com > Add New Project > import it >
Framework Preset "Other", leave Build Command empty, Output Directory "." > Deploy.
Option B (CLI): `npm i -g vercel` then run `vercel --prod` inside this folder.

## 4. Become the owner
Open your site, click Create account with your email, confirm the email, then in the Supabase SQL Editor run:
`insert into admins select id from auth.users where email='you@example.com';`
Reload the site: "+ Post question" appears for you only.

## Notes
- Students register themselves; every signed-in user can read all questions and answers.
- Uploaded files are in a public bucket under unguessable paths (anyone with a link can open one). Switch to private + signed URLs if that matters.
- Free Supabase tier: 1 GB storage; Auth email limit is low, so set up custom SMTP before a big launch.
- The list refreshes every 20 seconds and after each action.
