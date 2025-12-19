# Template Evaluation and Action Prompts

**IMPORTANT**: This file contains prompts for YOU to use to trigger specific actions. The AI should **IGNORE** this file when filling out the template - it is only for user reference when they want to trigger these actions.

---

## Quick Reference: List Available Actions

### Prompt Name: `list_template_actions`

### How to Use:
When you want to see what actions are available, use this prompt:

```
@chat_incident_template/ List the available prompts/actions from TEMPLATE_ACTIONS.md
```

Or simply:

```
@chat_incident_template/ What actions can I trigger?
```

Or:

```
@chat_incident_template/ Show me the available prompts
```

### What This Action Does:
When you use this prompt, the AI will:
- Read TEMPLATE_ACTIONS.md
- List all available actions with their names and brief descriptions
- Show you what each action does
- Provide a quick reference of available prompts

**This helps you discover what actions are available.**

---

## Action 2: Evaluate Template Completion Quality

### Prompt Name: `evaluate_template_completion`

### How to Use:
When you have a filled-out incident folder (no longer a template) and want to evaluate how well it was completed, use this prompt:

```
@[filled-out-incident-folder]/ @chat_incident_template/ 

This is a template that you had created that was processed by another conversation. 
How did you do in filling out your template as you intended? I'm looking for feedback 
on how we can improve your template so that it gets better filled out every time. 

This is your original template that we would be improving.

Please:
1. Compare the filled-out incident documentation against the template structure
2. Evaluate what was done well (completeness, specificity, analysis quality)
3. Identify what's missing or could be improved (incomplete dates, missing examples, lack of specificity)
4. Assess how well the template was followed (were all sections filled, were requirements met?)
5. Provide specific recommendations for improving the template based on gaps you find
6. Create or update a TEMPLATE_EVALUATION.md file in the template folder with your findings

Focus on:
- Were all sections filled out (not just placeholders)?
- Were specific examples included (quotes, commands, outputs)?
- Were complete dates extracted (not XX)?
- Were file references specific (with line numbers)?
- Was conversation context captured?
- Were user observations properly documented?
- Was the analysis detailed enough with root causes?

Use this evaluation to improve the template for future incidents.
```

### What This Action Does:
When you use this prompt, the AI will:
- Compare the filled-out incident folder against the template structure
- Evaluate completeness, specificity, and quality of the documentation
- Identify gaps and missing information (incomplete dates, missing examples, etc.)
- Assess how well the template was followed (all sections filled, requirements met)
- Provide specific recommendations for improving the template
- Create or update TEMPLATE_EVALUATION.md in the template folder with findings
- Score the template quality and identify priority improvements

**This evaluation helps improve the template for future incidents.**

---

## Action 3: [Placeholder for Future Action]

### Prompt Name: `[action_name_here]`

### How to Use:
[Description of when/how to use this action]

### Prompt:
```
[The prompt text here]
```

### What This Action Does:
[Description of what this action accomplishes]

---

## How to Add New Actions

When you want to add a new action prompt:

1. Add a new section with "Action N: [Name]"
2. Include:
   - Prompt Name: `[descriptive_name]`
   - How to Use: When/why to use this action
   - Prompt: The exact prompt text
   - What This Action Does: Description of the outcome

3. Update this file with the new action

---

## Notes for AI Processing Template

**When filling out the template**: This file should be **IGNORED**. It is not part of the template structure and should not be processed or filled out.

**When user triggers an action**: Only then should you read and execute the action described in this file.

