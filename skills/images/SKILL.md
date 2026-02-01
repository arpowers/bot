---
name: images
description: Generate images for social media, blogs, and data communication
version: 1.0.0
triggers:
  - image
  - illustration
  - generate image
  - create image
  - visual
  - chart
  - diagram
  - workflow
---

# Image Generation Skill

Two modes: **Editorial illustrations** for social/blog content, **Data graphics** for charts/workflows.

**Always generate an image.** User decides whether to include.

---

## Mode 1: Editorial Illustrations

For: Social posts, blog headers, featured images, emotional content.

**Style:** New Yorker covers, indie game art, blog headers. Not stock. Not AI gradient slop.

### Don't Illustrate Literally

Match the _emotional tone_, not the topic:

| Topic | Bad (Literal) | Good (Emotional) |
|-------|---------------|------------------|
| Burnout | Tired person at desk | Sad creature at computer |
| Distributed systems | Server diagram | Owls passing papers in a tree |
| Growth | Upward arrow | Psychedelic landscape with path |
| Automation | Flowchart | Robots doing mundane tasks with personality |
| Overwhelm | Stressed face | Tiny figure under giant paper stack |
| Connection | Handshake | Birds on telephone wires at sunset |

### Style Characteristics

- Bold flat colors, limited palette (2-4 colors dominating)
- Heavy black or dark outlines
- Whimsical/surreal subjects (creatures, unexpected combinations)
- Hand-drawn feel, not polished 3D
- Emotional characters when applicable
- Single clear focal point

### Color Palettes

| Mood | Palette |
|------|---------|
| Melancholic | Blue + coral |
| Energetic | Orange + teal |
| Mysterious | Purple + gold |
| Calm | Sage + cream |
| Bold | Red + black + white |
| Playful | Rainbow/70s poster |

### Prompt Template

```
[emotional concept as surreal scene], editorial illustration style, bold flat colors, heavy outlines, [2-3 color palette], whimsical, hand-drawn feel, [mood: playful/melancholic/energetic], no text
```

### Examples

```
Owl reading documents in purple tree at night, editorial illustration, flat colors, purple and coral palette, whimsical, hand-drawn, no text
```

```
Bird crying at computer screen, editorial illustration, bold outlines, blue and coral, melancholic mood, no text
```

```
Psychedelic mountain landscape with winding path, 70s poster style, rainbow colors, bold outlines, optimistic, no text
```

```
Tiny robot overwhelmed by giant stack of papers, editorial illustration, teal and orange palette, playful, hand-drawn feel, no text
```

### Don't Use (Editorial)

- AI gradient art (rainbow swirly stuff)
- Stock aesthetic (handshake, lightbulb, gears)
- Literal metaphors (arrows, targets, puzzle pieces)
- Photorealistic style
- Corporate clip art
- Busy compositions with multiple focal points

### Text Control

**Default:** Say "no text" in prompt

**If text needed:** Specify exactly:
- "stop sign in frame"
- "text saying 'SOLD OUT' on sign"
- "404 on computer screen"

### Quick Reference

| Post About | Generate |
|------------|----------|
| Failure/rejection | Wilting flower in spotlight |
| Winning/success | Tiny figure planting flag on peak |
| Complexity | Tangled yarn ball with one loose thread |
| Simplicity | Single origami crane on empty desk |
| Speed | Blur of legs running, stylized |
| Patience | Turtle in garden, sunset colors |
| AI tools | Robot doing mundane task (dishes, filing) |
| Sales | Fox in conversation with rabbit |
| Automation | Assembly line of birds passing notes |

---

## Mode 2: Data Graphics

For: Charts, workflows, diagrams, process visualizations, architecture docs.

**Style:** Tufte principles, Swiss design, Apple aesthetics. High data-ink ratio. Every pixel earns its place.

### Core Principles

1. **Data-ink ratio** — Maximize data, minimize decoration
2. **Editorial minimalism** — If it doesn't inform, remove it
3. **Swiss precision** — Grid-based, typographically clean
4. **Apple clarity** — Generous whitespace, subtle hierarchy

### Style Characteristics

- Monochromatic or 2-color palette max
- No gradients, no shadows, no 3D effects
- Thin lines, consistent stroke weights
- San-serif typography (SF Pro, Inter, Helvetica)
- Generous negative space
- Left-aligned text, clear hierarchy
- No chartjunk (grid lines only if essential)

### Prompt Template (Data)

```
[type of visualization] showing [what data/process], minimalist Swiss design style, clean lines, [single accent color] on white background, high data-ink ratio, no decorative elements, professional, Apple-style clarity, no text unless essential
```

### Examples

```
Flowchart showing user authentication process, minimalist Swiss design, thin black lines on white, single blue accent for decisions, high data-ink ratio, clean sans-serif labels only, no decorative elements
```

```
Comparison chart of three pricing tiers, Apple website aesthetic, generous whitespace, subtle gray lines, single accent color for emphasis, minimal text, no chartjunk
```

```
System architecture diagram with microservices, Swiss design grid layout, monochromatic with teal accents, thin consistent lines, clear hierarchy, maximum clarity
```

```
Workflow diagram for content pipeline, editorial minimalism, black and white with coral highlights, clean geometric shapes, no shadows or gradients, Tufte-inspired
```

### Don't Use (Data)

- Gradients or 3D effects
- Decorative icons or illustrations
- Multiple competing colors
- Drop shadows
- Rounded bubbly shapes
- Infographic clip art style
- Excessive grid lines
- Borders around everything

### Data Graphics Checklist

Before generating, ask:
- [ ] Can I remove any lines?
- [ ] Can I remove any colors?
- [ ] Is every element showing data?
- [ ] Would Tufte approve?
- [ ] Does it look like it belongs on apple.com?

---

## When to Use Which Mode

| Content Type | Mode | Why |
|--------------|------|-----|
| Social post | Editorial | Emotional engagement |
| Blog header | Editorial | Visual interest |
| Featured image | Editorial | Personality |
| Process workflow | Data | Clarity |
| Architecture diagram | Data | Technical accuracy |
| Comparison chart | Data | Information density |
| Pricing table | Data | Quick scanning |
| Onboarding flow | Data | User guidance |
| Concept explanation | Either | Depends on audience |

**Rule of thumb:**
- Trying to make someone *feel* something? → Editorial
- Trying to make someone *understand* something? → Data

---

## Image Generation Tools

### Primary: Gemini (MCP)

Use `mcp__gemini__gemini-generate-image` for most generations.

**Parameters:**
| Param | Options | Default |
|-------|---------|---------|
| prompt | Your image prompt | required |
| aspectRatio | 1:1, 16:9, 9:16, 4:3, 3:4, 2:3, 3:2 | 1:1 |
| imageSize | 1K (fast), 2K (balanced), 4K (best) | 2K |
| style | "editorial illustration", "watercolor", etc. | none |

**Example call:**
```json
{
  "prompt": "Owl reading documents in purple tree at night, editorial illustration, flat colors, purple and coral palette, whimsical, hand-drawn, no text",
  "aspectRatio": "1:1",
  "imageSize": "2K"
}
```

**Aspect ratios by use:**
| Use Case | Ratio |
|----------|-------|
| Instagram/social square | 1:1 |
| Twitter/X header | 16:9 |
| LinkedIn post | 1:1 or 4:3 |
| Instagram story/Reels | 9:16 |
| Blog header | 16:9 or 3:2 |
| Pinterest | 2:3 |

### Secondary: OpenAI DALL-E

If Gemini unavailable, use OpenAI API:

```bash
curl -s "https://api.openai.com/v1/images/generations" \
  -H "Authorization: Bearer ${OPENAI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "dall-e-3",
    "prompt": "[your prompt]",
    "size": "1024x1024",
    "quality": "hd"
  }'
```

### Alternative: Midjourney

For Midjourney, output the optimized prompt for manual use:

**Midjourney prompt format:**
```
[scene description] --ar 1:1 --style raw --v 6.1
```

Add these Midjourney params as needed:
- `--ar 16:9` (aspect ratio)
- `--style raw` (less stylized)
- `--v 6.1` (version)
- `--no text, words, letters` (avoid text)

---

## Usage

### Generate for social post
```
/images for post about [topic]
```

### Specify mode
```
/images editorial: anxiety about AI replacing jobs
/images data: user onboarding flow diagram
```

### With aspect ratio
```
/images for LinkedIn (1:1): post about cold outreach
/images for blog header (16:9): article about automation
```

Bot determines mode from context if not specified. Always generates—user decides to include.
