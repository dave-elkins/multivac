# STE rules and recipes

An unofficial summary of ASD-STE100 Simplified Technical English ideas, shaped
for AI-assisted writing. The full standard is published by ASD; nothing here is
certified or affiliated. Rule-block structure and the checker idea were
borrowed from [explainx.ai's STE guide](https://explainx.ai/blog/how-to-use-asd-ste100-simplified-technical-english-with-ai-guide-2026)
and the open-source [AminBlg/SimpleEnglish](https://github.com/AminBlg/SimpleEnglish) skill.

## The rule block

Apply to documentation and messages. Do not apply to marketing copy.

- Write sentences of about 20 words or fewer.
- Use active voice.
- Give one instruction per sentence.
- State the condition before the command. Write "If the flag is set, run X",
  not "Run X if the flag is set".
- Do not use -ing verb forms where a plain verb works.
- Do not use "should", "would", "may", or "might". Use "must" for requirements
  and "can" for options.
- Keep articles (a, an, the) and the word "that". Do not write telegraph-style
  fragments.
- Use one word for one meaning. Do not swap "start", "launch", and "kick off"
  for the same action.

## The rules that matter most

| Rule | Weak | Better |
| --- | --- | --- |
| Short sentences | "It is important to note that the service, which runs on port 8080, needs the config file before it starts" | "The service runs on port 8080. It needs the config file before it starts." |
| Active voice | "The file should be saved by the user" | "Save the file." |
| One instruction per sentence | "Open the file and edit the key and restart" | "Open the file. Edit the key. Restart the service." |
| Condition before command | "Restart the service if the config changed" | "If the config changed, restart the service." |
| No hedging | "You should back up the database" | "Back up the database." |
| Consistent terms | "Launch, start, boot, kick off" | "Start" every time |

## Recipes by document type

**Error messages** — order as what happened, why, what to do:

> The upload failed. The file is larger than 25 MB. Choose a smaller file and
> try again.

**Runbooks** — number the steps. One action and one expected result per step:

> 1. Open the dashboard.
> 2. Find the failing job.
> 3. Select Restart. The status changes to Running within 30 seconds.

**Incident reports** — simple past tense, real times, no soft language:

> Between 14:02 and 14:31 UTC, 12% of requests failed. A deploy at 14:00
> caused it. We reverted the deploy at 14:27.

**Release notes** — action first, risk second. Breaking changes read like
warnings:

> Rename `config.yml` to `settings.yml` before you upgrade. The old name no
> longer works.

**Agent rule files (AGENTS.md)** — direct commands, never hedges:

> Keep each function under 40 lines.

## Rewrite workflow

1. Pick the document. Choose one with a clear reader and task.
2. Ask for a rewrite, not a new draft. Add "Do not add facts. Do not remove
   steps."
3. Read the diff. Make sure steps, numbers, and warnings survived.
4. Run `scripts/ste_check.py`. Fix what it flags.
5. Test on a person unfamiliar with the project. Where they hesitate, the
   text is still ambiguous.

## When not to use

Blog posts, landing pages, brand stories, speeches, fiction. And STE does not
make a document *correct* — keep review for anything safety-relevant.
