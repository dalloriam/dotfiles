---
name: writing
description: My prose style for anything written for a reader. Covers technical writing (docs, READMEs, specs, design records, commit messages, PR descriptions, issues, code comments, reports) and copywriting (UI text, error messages, release notes, announcements, landing pages, emails). Load before writing, revising, tightening or reviewing any of these. A style the user, the project or the destination asks for overrides it.
---

# Writing

The default register is technical: write the way a Bell Labs or IBM engineer wrote in 1985, in the
Unix manual, a Bell System Technical Journal paper or an IBM reference manual. The reader is
competent and has little time. Every sentence states a fact, a reason or a limit. A sentence that
does none of these is deleted.

Copywriting keeps the same discipline and changes the reader: someone deciding whether to use,
buy, click or keep reading. Its differences are under **Copywriting** below.

**Precedence.** An explicit instruction wins: a style the user asks for, a project's own style
guide or skill, a template the destination imposes (an issue form, a changelog format, a brand
voice document). Follow these rules wherever that instruction says nothing.

## Rules

1. **Lead with the fact.** First what the thing is or does, then how, then why. No preamble: not
   "This commit…", "In this PR we…", "This document describes…", "We're excited to…". Start with
   the subject.
2. **Short declarative sentences.** Subject, verb, object. One idea each. A sentence over about
   30 words is two sentences.
3. **Active voice, present tense** for behavior: "the server writes the file", not "the file will
   be written". Past tense only for history ("The worker stopped at its 8 GB memory limit").
4. **Exact names.** Paths, labels, flags, env vars, commands, table and type names in backticks,
   spelled as in the code. Error text quoted verbatim. Product and feature names spelled as the
   product spells them.
5. **Numbers, not adjectives.** "4 s instead of 30 s", not "much faster". "500 records
   (about 1 MB)", not "a large batch". Give units. Say how a number was measured.
6. **One term per concept.** Define it on first use if a reader could misread it, then never swap
   in a synonym. If the code or the UI calls it a `job`, the prose does not call it a
   "task".
7. **State limits plainly.** What is untested, unverified, unknown or deliberately left out gets
   one flat sentence: "Not run on macOS." "The remote connection is untested." No apology, no hedge.
8. **No filler.** Delete on sight: *simply, just, basically, actually, really, very, quite, easily,
   note that, it should be noted, in order to, leverage, utilize, robust, seamless, powerful,
   comprehensive, elegant, blazing, best-in-class, cutting-edge, game-changing, under the hood,
   unlock, supercharge, delve*. Use *use*, not *utilize*; *to*, not *in order to*.
9. **No hedging without cause.** "Should", "might", "probably" only where uncertainty is real, and
   then say what it depends on.
10. **No restating.** No closing summary of what was just said. No "Overall, this change…", no
    "In conclusion".
11. **Prose for reasoning, lists for parallel items.** A chain of because/therefore is a paragraph.
    A set of independent changes, flags or options is a list. Never a list of one.
12. **Plain typography.** No emoji, no exclamation marks, no bold for emphasis inside sentences
    (bold is for list-item lead terms and definitions). Headings only where the document is long
    enough to navigate.
13. **Concrete before abstract.** An example beats a description of the general case. Show the
    command, the input and the output; the screen, the click and the result.

## Before and after

> This PR introduces a robust new caching layer that should significantly improve performance
> when searching files.

> The search command caches parsed files. On 10,000 files, a repeat search takes 4 s instead of
> 30 s and returns the same results.

> It should be noted that there were some issues when tasks ran at the same time.

> Every task wrote to `/tmp/result.json`. A second task overwrote the first task's output before
> the first task could read it.

> Supercharge your workflow with our powerful new sync engine — it's never been easier to keep
> your files safe!

> Files upload when you save them and download when you open them on another device. If both
> devices edit the same file, the app keeps both copies.

## Copywriting

Rules 1–13 still hold. These adjust them for a reader who is deciding, not studying.

- **Write from the reader's side.** Say what they get or can now do, not what was built: "Search
  finds notes by content", not "We implemented full-text indexing". The mechanism comes second,
  if at all.
- **One claim per unit.** A headline, a button, a notification or a toast says one thing. The
  supporting line backs that claim with a fact or a number.
- **Specific beats impressive.** A number, a named feature or a concrete before/after is the
  persuasion. Superlatives and filler (rule 8) read as noise to this reader too.
- **Second person, plain verbs.** "You", "your". Verbs a reader would say aloud: *open, save,
  find, send*, not *empower, enable, facilitate*.
- **No false urgency or flattery.** No "Don't miss out", "Amazing!", "We'd love to hear from you".
- **Match length to the surface.** A button is one to three words, a verb first ("Save", "Open
  log"). A tooltip or empty state is one sentence. A landing-page section is a headline, one or
  two sentences, and a proof point.

### UI text

Terse, technical, precise. Labels name the thing or the action; they do not explain or chat.

- Buttons and menu items are verbs or verb phrases, in sentence case: "Delete chat", not "Delete
  Chat" or "Yes, delete it!".
- Status and state are nouns or short phrases: "Synced 2 min ago", "Offline", "3 pending".
- Empty states say what is absent and the one action that fills it: "No files. Upload a file to
  get started."
- Confirmations name the object and the consequence: "Delete `notes.md`? This cannot be undone."
- No "please", no "oops", no "Looks like…".

### Error messages

What failed, why, and what to do, in that order, with the exact value involved:
"Could not connect to `db.example.com:5432`: connection refused. Start the database."
Never "Something went wrong". Never blame the reader.

## Per document

**Commit message.** A project's own format and ticket rules come first. The summary line is an
imperative verb phrase, no trailing period, under 72 characters, naming the effect, not the
activity ("assign each worker a unique output path", not "update worker code"). The body says what
was wrong or missing and what is true now, then anything the diff cannot show: the measurement,
the alternative rejected, the risk. Wrap at 72–100 columns, as the repo does. A one-line change
may have no body.

**PR description.** Title and body format are in the `pr-description` skill. State how the change
was verified: the targets tested, what was run by hand, what was not.

**README.** Open with one sentence on what the thing is and one on why someone would use it. Then
install, the shortest real usage example, and configuration. Link out for the rest.

**Reference doc or spec.** Reference style, like a manual page. Describe what the system does now,
in present tense, with the source linked. No motivation (that is the design record), no history,
no plans. Each section answers one question a reader would ask ("What does the server do when the
provider returns 429?"). Tables for enumerations: flags, env vars, statuses, error codes.

**Design record (ADR, RFC).** Context states the forces as facts with evidence: the measurement,
the failure, the constraint. Decision is one paragraph that starts with the choice ("Jobs run in
separate processes."). Each rejected option gets a sentence on what it was and a sentence on
why it lost. Consequences list what becomes easier, harder and required.

**Issue or ticket.** Title names the problem or the outcome, not the activity. Body: what happens,
what should happen, how to reproduce, and the evidence (error text, IDs, versions).

**Code comment.** Says why, or what the code cannot show: an invariant, a constraint, a source.
Never narrates what the next line does.

**Release notes and changelogs.** One line per change, from the user's side, grouped by kind
(added, changed, fixed, removed). Breaking changes first, with what to do about them.

**Announcement or email.** The point in the first sentence, the ask (if any) in the first
paragraph, with its date. Details after, for whoever needs them.

## Checking a draft

Read it once and for each sentence ask: is this a fact, a reason, a limit, or (in copy) a claim
the reader needs? Delete it if not. Then check every term against the code or the UI, every
number against its source, and every adjective for a number that could replace it.
