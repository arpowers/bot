---
name: social-media
description: Content creation and planning for social media platforms
version: 1.0.0
triggers:
  - social
  - post
  - content
  - twitter
  - linkedin
  - instagram
  - tiktok
  - substack
---

# Social Media Skill

Generate content that sounds human. Heuristics only. No templates. Write something that could only come from a person.

**CRITICAL: Write like you're talking, not writing an essay. Off the cuff. Conversational. The kind of thing you'd text a friend.**

## Length Limits (HARD)

| Platform | Limit | Notes |
|----------|-------|-------|
| X/Twitter | 280 chars | One idea. Done. |
| LinkedIn | 100-150 words MAX | Ceiling, not target |
| Threads | 500 chars | Per post |

If over limit, **CUT**. Don't compress—delete entire sentences. Shorter is always better.

## Voice (Anti-AI)

**The problem:** AI writes too clean. Too structured. Every paragraph balanced. It sounds like LinkedIn optimization, not a person.

**Fix it:**
- Fragments. Incomplete thoughts. Let them hang.
- Punctuation is rhythm. Periods punch. Dashes interrupt— ellipses trail...
- Don't balance everything. Say something sharp and move on.
- Vary line length dramatically. One word. Then longer.
- Cut connective tissue. No "however" "moreover" "that said."
- Start mid-thought sometimes. No setup.
- End abruptly when the point lands.

**Write like texting a friend:**
- Lowercase sometimes
- Real emotion words and slang
- Trail off with ".."
- Stream of consciousness
- Imperfect is fine

## Stance

**Take a position people can disagree with.**

| Weak | Strong |
|------|--------|
| "Automation can help your business." | "Most automation is a waste of time. Here's the only kind worth building." |
| "AI is changing how we work." | "AI will kill 90% of SaaS. The survivors won't look like software." |

## Content Heuristics

- **Actionable > Interesting** — Insight without blueprint is entertainment
- **Specific > Vague** — Numbers, names, tools, dates
- **Earned > Claimed** — Show the work, not the conclusion
- **Short > Long** — Every word earns its place or gets cut
- **One idea > Many ideas**

## The Bookmarkability Test

Would someone save this to reference later? If not, it's forgettable.

## Format Types (Vary These)

Pick randomly. Don't default to same one.

1. **Blueprint** (40%) — How-to with steps (most bookmarkable)
2. **Data contrast** — Before/after with numbers
3. **Earned insight** — Lesson from experience
4. **Hot take** — Contrarian stance with proof
5. **Story** — Personal narrative with takeaway

## Don't

- Don't staccato-only (mix sentence lengths)
- Don't drop frameworks cold (earn context first)
- Don't manufacture urgency ("while you sleep", "teams winning in 2026")
- Don't explain twice
- Don't hedge ("It's worth noting that perhaps...")
- Don't summarize after the point lands
- Don't wrap everything in a bow

## Topic Focus

Stick to 3-5 core topics. Algorithms amplify consistency:
- AI/automation
- GTM engineering, sales, strategy
- n8n, Clay, tools
- Founder journey
- Balancing life and work

## Trend Usage

Current events = human signal. AI struggles to be timely.

Use a trend if:
- Natural connection to niche
- Hot take angle exists
- Everyone's talking about it RIGHT NOW

## Platform Playbooks

### X (Twitter)
**Character:** Direct, witty, slightly provocative

**Format hierarchy:**
1. Single tweet (highest reach)
2. Thread (for depth)
3. Quote tweet (for engagement)

**Best practices:**
- First tweet must stand alone
- No hashtags in main content
- Ask questions to drive replies
- Post 2-5x daily for growth

**Hook examples:**
- "Hot take: [contrarian opinion]"
- "I spent [time] doing [thing]. Here's what I learned:"
- "[Big name] just [action]. This changes everything."

### LinkedIn
**Character:** Professional but human, vulnerability works

**Format hierarchy:**
1. Text post with line breaks
2. Carousel (highest saves)
3. Video (rare, high impact)

**Best practices:**
- Write like a human, not a corp
- Short paragraphs (1-2 sentences)
- "I" stories outperform "you should"
- Post 1x daily max

**Hook examples:**
- "I got rejected from [thing]. Best thing that happened."
- "Nobody talks about this in [industry]:"
- "I used to think [old belief]. I was wrong."

### Instagram
**Character:** Visual-first, aspirational but real

**Format hierarchy:**
1. Reels (algorithm priority)
2. Carousels (highest saves)
3. Stories (engagement, not reach)

**Best practices:**
- Text overlays on video
- First frame is the hook
- Trending audio boosts reach
- 3-5 hashtags max, in caption

### TikTok
**Character:** Raw, fast, trend-aware

**Format hierarchy:**
1. Trending format + your niche
2. Original educational content
3. Duets/stitches

**Best practices:**
- Hook in first 1 second
- Pattern interrupts every 3-5 seconds
- Text on screen always
- Trending sounds = 2x reach

### Substack
**Character:** Long-form, personal, newsletter-native

**Format:**
- Personal opener (1-2 paragraphs)
- Core insight with examples
- Practical takeaway
- Soft CTA

**Best practices:**
- Weekly consistency > daily
- Ask questions to drive comments
- Cross-post to Notes for reach

## Content Workflow

### Phase 1: Ideation
Sources:
- Conversations and DMs
- Industry news and trends
- Personal experiences
- Kindle highlights (use /highlights)
- Competitor content gaps

### Phase 2: Draft
```
Platform: [X/LinkedIn/Instagram/TikTok/Substack]
Topic: [One of your core topics]
Format: [Tweet/Thread/Carousel/Reel/Article]
Hook: [First line - test 3-5 variations]
Body: [Core content]
CTA: [Optional - what should they do?]
```

### Phase 3: Platform Optimize
- Adjust tone for platform
- Add platform-specific formatting
- Check character/length limits
- Add visual elements if needed

### Phase 4: Schedule
Optimal times (US):
- X: 8-10am, 12-1pm, 5-7pm
- LinkedIn: 7-9am, 12pm, 5-6pm (weekdays)
- Instagram: 11am-1pm, 7-9pm
- TikTok: 7-9pm

## Content Types

### Quick Post
Single platform, single format:
```
/social post for X about [topic]
```

### Cross-Platform
Adapt one idea across platforms:
```
/social cross-post about [topic]
```

### Content Calendar
Plan a week of content:
```
/social plan week focusing on [topic]
```

### Repurpose
Turn existing content into social:
```
/social repurpose [url or content]
```

## Images

**Always generate an image.** User decides whether to include.

Use `/images` skill. Match emotional tone, not literal topic.

Style: Editorial illustration (New Yorker, indie game art). Not stock. Not AI gradient slop.

## Integration

Use with other skills:
- `/images` - Generate editorial illustrations (not stock-y)
- `/highlights` - Pull Kindle highlights for content ideas
- `/research` - Research trends before posting
- `/analytics` - Check what's performing

## Examples

### Generate X Thread
```
Create a thread about why cold email still works in 2026.

Hook options to test:
1. "Cold email is dead. Except it made me $X last month."
2. "I sent 1000 cold emails. 47 replied. Here's exactly what worked:"
3. "Everyone's doing LinkedIn DMs. That's why cold email works."

Thread structure:
- Hook with result
- The counterintuitive insight
- 3-5 specific tactics
- Real example with numbers
- CTA to engage
```

### Generate LinkedIn Post
```
Write a LinkedIn post about hiring your first employee.

Format:
- Personal story opening
- The mistake you made
- What you learned
- How others can avoid it
- Question to drive comments
```
