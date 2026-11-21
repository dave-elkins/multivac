# Render recipes

The four-rung ladder for turning model output into something a human can
verify fast. Adapted from Andrej Karpathy's ranking of output formats, as
covered by [explainx.ai](https://explainx.ai/blog/karpathy-understand-llm-outputs-ste100-diagrams-html-video-2026),
with the artifact-is-the-specification framing from
[Thariq's thin-prompts stack](https://explainx.ai/blog/thin-prompts-thick-artifacts-thin-skills-thariq-july-2026).

## Rung 1 — STE-style text

Use when the content is a procedure or explanation the user will re-read.
Hand off to the ste-writing skill. Ask for "80% of the way" when full
strength would read stilted for a software topic.

## Rung 2 — Diagram

Use when the answer has structure: components and flows, states and
transitions, timelines, hierarchies. Not for nuanced arguments — a
box-and-arrow picture of "it depends" tells you nothing.

**SVG architecture diagram:**

```text
Draw this architecture as an SVG diagram. Show the data flow with
numbered arrows. Label every box with the real component name.
```

**Mermaid sequence diagram:**

```text
Make a Mermaid sequence diagram of the auth flow in this repo,
then list the three places the diagram is least certain.
```

The second half of that prompt is mandatory. A diagram looks authoritative
even when a label is wrong, so the model must flag its own weak spots.

## Rung 3 — HTML page

The best return for effort. One prompt change turns a wall of Markdown into
tabs, collapsible sections, sliders, and a color-coded status board. A
single `.html` file opens in any browser and can be shared as a file.

**Paper or long-doc explorer:**

```text
Read this 40-page paper and create a single self-contained HTML file
that explains it. Add: a one-paragraph summary at the top, a section
per major claim, one interactive figure I can drag, and a "what would
change my mind" box at the end. No external dependencies.
```

**PR diff review page:**

```text
Turn this PR diff into an HTML review page: group changes by intent,
color risky hunks, and add a checklist of things I must test by hand.
```

Rules: self-contained, no external dependencies, one interactive element
minimum, and a "what would change my mind" or "weakest claims" box so the
reader knows where to push back.

## Rung 4 — Explainer video

Only on request — it needs a TTS source (paid API key or local alternative)
and a render step. The pipeline is *code, not diffusion*: the agent writes a
program (HTML/canvas or Manim-style scenes) that draws each frame, so labels
and graphs come out exact and editable.

Before trusting one:

1. Spot-check the three most surprising statements against a primary source.
2. Read the narration script as text, separately. Mistakes are easier to see.
3. Keep it discardable. If it will be published, it needs published-piece
  review.

## Verification checklist (every rung)

- The artifact lists its three weakest points.
- Steps, numbers, and warnings match the source material.
- The artifact is not committed to a project repo unless the user asks.
