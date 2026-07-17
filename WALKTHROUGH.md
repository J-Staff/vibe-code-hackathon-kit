# Walkthrough: from idea to a working feature

A complete example you can follow on day one. The feature is a simple waitlist page
where a visitor enters an email and it gets saved. It shows every phase of the
workflow and which skill to reach for.

## 0. Start Vibe in plan mode

```bash
vibe
```

Press Shift+Tab until the mode reads `plan`. The agent proposes, it does not change
files yet.

## 1. Gather requirements (brainstorming)

Prompt:

> Use brainstorming to gather requirements for a waitlist page. People enter an
> email, we store it, and we show a thank you message.

The skill interviews you. Where is the email stored, do you need validation, what
should the thank you say. Answer until the requirements are clear.

## 2. Make a plan (writing-plans)

Prompt:

> Now use writing-plans to turn those requirements into a step by step plan.

Read the plan. This is the cheapest place to catch a wrong direction.

## 3. Build it (implement, test driven)

Switch to accept-edits mode with Shift+Tab. Prompt:

> Use implement with a test driven approach. Write a failing test for the email
> validation first, then the code that makes it pass.

## 4. Test end to end (test)

Prompt:

> Use the test skill to run the whole flow. Submit an email, confirm it is stored,
> confirm the thank you message appears.

## 5. Prove it works (verification-before-completion)

Prompt:

> Use verification-before-completion. Do not claim this works until you have run it
> and shown the output.

## 6. Ship it (git)

Prompt:

> Use git to commit this with a clear message and push it.

## What you just learned

Each phase had its own skill, and you stayed in control by starting in plan mode.
That is the whole loop. Repeat it per feature and you will have a working prototype
by the end of day two.
