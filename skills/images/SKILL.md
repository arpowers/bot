---
name: images
description: Generate editorial-style images for social media and content
version: 1.0.0
triggers:
  - image
  - illustration
  - generate image
  - create image
  - visual
---

# Image Generation Skill

Generate editorial-style illustrations for social content. Match emotional tone, not literal topics.

## Default Rule

**Skip the image.** Text-only works better for most posts.

Only generate if:
- Screenshot of actual thing (workflow, UI, results)
- Editorial illustration matching emotional tone
- Meme that lands

## Style Guide

**The vibe:** New Yorker covers, blog headers, indie game art. Not stock photos. Not AI gradient slop.

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

- Bold flat colors, limited palette (2-4 colors)
- Heavy black or dark outlines
- Whimsical/surreal subjects
- Hand-drawn feel, not polished 3D
- Emotional characters when applicable
- Single clear focal point

### Color Palettes That Work

| Mood | Palette |
|------|---------|
| Melancholic | Blue + coral |
| Energetic | Orange + teal |
| Mysterious | Purple + gold |
| Calm | Sage + cream |
| Bold | Red + black + white |
| Playful | Rainbow/70s poster |

## Prompt Template

```
[emotional concept as surreal scene], editorial illustration style, bold flat colors, heavy outlines, [2-3 color palette], whimsical, hand-drawn feel, [mood: playful/melancholic/energetic], no text
```

## Examples

### Good Prompts

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

```
Fox in business suit looking confused at maze of cables, editorial illustration, sage and coral, whimsical, heavy outlines, no text
```

```
Astronaut watering tiny plant on moon, editorial illustration, purple and gold palette, hopeful mood, hand-drawn feel, no text
```

## Don't Use

- AI gradient art (the rainbow swirly stuff)
- Stock aesthetic (handshake, lightbulb, gears)
- Literal metaphors (arrows, targets, puzzle pieces)
- Photorealistic style
- Corporate clip art vibes
- Busy compositions with multiple focal points

## Text Control

**Default:** Say "no text" in prompt

**If text needed:** Specify exactly what text
- "stop sign in frame"
- "text saying 'SOLD OUT' on sign"
- "404 on computer screen"

## Usage

### For Social Post
```
/images for post about [topic]
Mood: [playful/melancholic/energetic/hopeful/frustrated]
```

### Direct Generation
```
/images [emotional scene description]
```

### With Context
```
/images for this LinkedIn post: [paste post]
```

## Integration

Works with:
- Gemini image generation (via MCP)
- Direct image APIs
- Manual prompt for Midjourney/DALL-E

### Using Gemini MCP

```
Generate image with prompt:
"[your editorial illustration prompt]"
```

### Manual (for Midjourney, etc.)

Bot will output the optimized prompt. Copy to your preferred tool.

## Workflow

1. **Assess:** Does this post actually need an image?
2. **Identify emotion:** What's the feeling, not the topic?
3. **Translate:** Surreal scene that captures that emotion
4. **Build prompt:** Use template with specific palette and mood
5. **Generate:** Use available image tool
6. **Evaluate:** Does it feel editorial or stock-y?

## Quick Reference

| Post About | Generate |
|------------|----------|
| Failure/rejection | Wilting flower in spotlight |
| Winning/success | Tiny figure planting flag on peak |
| Complexity | Tangled yarn ball with one loose thread |
| Simplicity | Single origami crane on empty desk |
| Speed | Blur of legs running, stylized |
| Patience | Turtle in garden, sunset colors |
| AI tools | Robot doing something mundane (dishes, filing) |
| Sales | Fox in conversation with rabbit |
| Automation | Assembly line of birds passing notes |
