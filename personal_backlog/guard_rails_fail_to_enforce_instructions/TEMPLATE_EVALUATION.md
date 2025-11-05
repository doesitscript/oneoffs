# Template Evaluation and Improvement Recommendations

Based on analysis of the filled-out incident documentation (`guard_rails_fail_to_enforce_instructions/`), here's feedback on how well the template was filled out and how to improve it.

## What Was Done Well ✅

### 1. Comprehensive Coverage
- ✅ All template documents were filled out (not just placeholders)
- ✅ USER_OBSERVATIONS_AND_QUESTIONS.md was well populated with actual user observations
- ✅ Root causes were identified with clear detection/compliance indicators
- ✅ Specific examples were included (actual commit messages, git commands)

### 2. Strong Analysis
- ✅ ANALYSIS.md had detailed "What Should Have Happened" vs "What Actually Happened" sections
- ✅ Root causes included both technical reasons and nuanced considerations
- ✅ NUANCED_FACTORS.md captured philosophical balance questions effectively
- ✅ Recommendations included balance considerations ("But", "Consider", "Maintain")

### 3. Good Structure
- ✅ User observations were properly categorized and preserved
- ✅ Questions were clearly documented with user expectations vs. actual behavior
- ✅ Related files were identified with descriptions

## What Could Be Improved ❌

### 1. Missing Specific Details

**Issue**: Date is incomplete (`2025-01-XX`)
- **Impact**: Reduces traceability and makes it harder to correlate with logs
- **Fix**: Template should require complete date or prompt AI to extract from conversation

**Issue**: Missing line numbers in file references
- **Example**: "Workflow template with git instructions" - should include specific line numbers
- **Fix**: Template should prompt for line numbers when referencing code/instructions

**Issue**: No timeline of events
- **Impact**: Hard to understand sequence of what happened when
- **Fix**: Add optional "Timeline of Events" section to INCIDENT_SUMMARY.md

### 2. Missing Evidence/Examples

**Issue**: Could use more direct quotes from conversation
- **Current**: Paraphrases what happened
- **Better**: Include actual quotes/excerpts from conversation showing the problem
- **Fix**: Template should prompt for including conversation excerpts

**Issue**: Missing before/after comparisons
- **Current**: Shows what should have happened vs. what happened
- **Better**: Show actual commands/inputs/outputs side-by-side
- **Fix**: Template should encourage concrete examples

### 3. Template Structure Issues

**Issue**: "Conversation Export" section mentioned but not actionable
- **Current**: "The full conversation about this incident should be exported separately"
- **Better**: Include instructions on how/where to export, or prompt AI to reference conversation
- **Fix**: Add actionable guidance or make it a checklist item

**Issue**: No section for capturing conversation context
- **Impact**: When reviewing later, hard to understand what conversation was happening
- **Fix**: Add "Conversation Context" section to capture key context points

### 4. AI Instructions Could Be More Specific

**Issue**: Instructions don't emphasize extracting specific examples
- **Current**: "Identify what went wrong"
- **Better**: "Include actual quotes, commands, error messages, or code snippets"
- **Fix**: Update AI_INSTRUCTIONS.md to emphasize concrete examples

**Issue**: No guidance on how detailed to be
- **Current**: Vague on depth of analysis
- **Better**: Specify minimum requirements (e.g., "Include at least 2-3 specific examples")
- **Fix**: Add specificity requirements to instructions

## Recommended Template Improvements

### 1. Add "Timeline of Events" Section to INCIDENT_SUMMARY.md

```markdown
## Timeline of Events

1. **[Timestamp/Sequence]**: [What happened first]
2. **[Timestamp/Sequence]**: [What happened next]
3. **[Timestamp/Sequence]**: [When problem was detected]
4. **[Timestamp/Sequence]**: [Attempts to fix/resolve]
```

### 2. Add "Conversation Context" Section to INCIDENT_SUMMARY.md

```markdown
## Conversation Context

**What was being worked on**: [Main task or goal]
**Key background**: [Important context that led to incident]
**Related conversations/tasks**: [Any related work]
**User's goal**: [What user was trying to accomplish]
```

### 3. Enhance "What Actually Happened" with Evidence Requirements

Update ANALYSIS.md template to require:
- Actual commands executed
- Actual output/error messages
- Conversation excerpts showing the problem
- Before/after comparisons

### 4. Add "Evidence/Examples" Section to README.md

```markdown
## Evidence Included

- [ ] Conversation excerpts/quotes
- [ ] Actual commands executed
- [ ] Error messages or unexpected outputs
- [ ] Before/after comparisons
- [ ] Screenshots or logs (if applicable)
```

### 5. Improve Date Handling in INCIDENT_SUMMARY.md

Change from:
```markdown
**Date**: [DATE]
```

To:
```markdown
**Date**: [DATE - Extract from conversation if not provided, use format YYYY-MM-DD]
**Time**: [If available from conversation]
```

### 6. Add "Specific Examples" Section to ANALYSIS.md

```markdown
## Specific Examples

### Example 1: [What this example shows]

**Conversation excerpt**:
```
[Actual quote from conversation]
```

**What this demonstrates**: [Why this example matters]
```

### 7. Enhance File References with Line Numbers

Update template to require:
```markdown
- `[FILE_PATH]` - [Description] (see lines X-Y for relevant code/instructions)
```

### 8. Make "Conversation Export" Actionable

Change from:
```markdown
The full conversation about this incident should be exported separately and added to this folder.
```

To:
```markdown
## Conversation Export

- [ ] Conversation exported to `conversation_export.md` or similar
- [ ] Or: Conversation reference: [Link or identifier if available]
- [ ] Or: Key conversation excerpts included in ANALYSIS.md
```

### 9. Add Specificity Requirements to AI_INSTRUCTIONS.md

Add section:
```markdown
## Specificity Requirements

When filling out the template, ensure:
- ✅ Include at least 2-3 specific examples (quotes, commands, outputs)
- ✅ Include actual file paths with line numbers when referencing code
- ✅ Include complete dates (extract from conversation if needed)
- ✅ Include conversation excerpts showing the problem
- ✅ Include before/after comparisons when applicable
- ✅ Include error messages or unexpected outputs
```

### 10. Add "Evidence Checklist" to Template Processing

Update PROMPT_TEMPLATE.md to include:
```markdown
**Evidence to Include** (if available):
- [ ] Conversation excerpts showing the problem
- [ ] Actual commands/outputs
- [ ] Error messages
- [ ] File paths with line numbers
- [ ] Screenshots or logs
```

## Priority Improvements

### High Priority (Do First)
1. ✅ Add date extraction requirement (complete date, not XX)
2. ✅ Add specificity requirements to AI_INSTRUCTIONS.md
3. ✅ Add "Evidence/Examples" section guidance
4. ✅ Enhance file references to include line numbers

### Medium Priority
5. ⚠️ Add Timeline of Events section
6. ⚠️ Add Conversation Context section
7. ⚠️ Make Conversation Export actionable
8. ⚠️ Add specific examples section to ANALYSIS.md

### Low Priority (Nice to Have)
9. 📝 Add evidence checklist to prompt
10. 📝 Add before/after comparison template

## Template Quality Score

Based on the filled-out documentation:

- **Completeness**: 8/10 (all sections filled, but some details missing)
- **Specificity**: 7/10 (good examples, but could use more quotes/excerpts)
- **Traceability**: 6/10 (missing dates, line numbers, timeline)
- **Usability**: 9/10 (well organized, easy to follow)
- **Actionability**: 8/10 (good recommendations, but could be more specific)

**Overall**: 7.6/10 - Good foundation, but needs more emphasis on concrete evidence and specifics

## Next Steps

1. Update template files with priority improvements
2. Update AI_INSTRUCTIONS.md with specificity requirements
3. Test updated template with another incident
4. Iterate based on feedback

