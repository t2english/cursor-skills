# Skill Evaluation Template

Use this template after creating or modifying a skill to validate it works as intended.

## 1. Test Prompts

Draft 2-3 realistic prompts a real user would type. Include detail, context, and natural language — not abstract requests.

| # | Test Prompt | Expected Behavior | Result |
|---|-------------|-------------------|--------|
| 1 | _"..."_ | Skill triggers, does X | _pass / fail / partial_ |
| 2 | _"..."_ | Skill triggers, does Y | _pass / fail / partial_ |
| 3 | _"..."_ | Skill triggers, handles edge case Z | _pass / fail / partial_ |

### Writing good test prompts

- Use realistic detail: file paths, column names, personal context, backstory
- Mix formal and casual language
- Include at least one edge case or uncommon use case
- Avoid generic prompts like "help me with X" — be specific

## 2. Trigger Accuracy

### Should Trigger (5 queries)

Queries where this skill SHOULD activate. Include different phrasings, implicit needs (user doesn't name the skill), and competing-skill scenarios.

| # | Query | Triggers? | Notes |
|---|-------|-----------|-------|
| 1 | _"..."_ | _yes / no_ | |
| 2 | _"..."_ | _yes / no_ | |
| 3 | _"..."_ | _yes / no_ | |
| 4 | _"..."_ | _yes / no_ | |
| 5 | _"..."_ | _yes / no_ | |

### Should NOT Trigger (5 queries)

Queries where this skill should NOT activate. Focus on near-misses — queries that share keywords but actually need something different. Avoid obviously irrelevant queries.

| # | Query | Triggers? | Notes |
|---|-------|-----------|-------|
| 1 | _"..."_ | _yes / no_ | |
| 2 | _"..."_ | _yes / no_ | |
| 3 | _"..."_ | _yes / no_ | |
| 4 | _"..."_ | _yes / no_ | |
| 5 | _"..."_ | _yes / no_ | |

## 3. Qualitative Review

After running test prompts, evaluate:

- [ ] Output matches expected format/structure
- [ ] Skill instructions were followed (not ignored or partially applied)
- [ ] No unnecessary steps or wasted effort
- [ ] Edge cases handled gracefully
- [ ] Description accurately represents what the skill does

## 4. Iteration Notes

| Iteration | Changes Made | Impact |
|-----------|-------------|--------|
| v1 | Initial draft | _baseline_ |
| v2 | _"..."_ | _improved X, still failing Y_ |
| v3 | _"..."_ | _all tests passing_ |

## Tips

- **Generalize from feedback**: avoid overfitting to your specific test prompts. Changes should improve the skill for all users, not just your examples.
- **Bundle repeated work**: if every test run generates the same helper script or takes the same multi-step approach, bundle that into the skill's `scripts/` directory.
- **Keep the skill lean**: remove instructions that aren't pulling their weight. Read transcripts, not just outputs — if the skill makes the agent waste time on unproductive steps, trim those instructions.
