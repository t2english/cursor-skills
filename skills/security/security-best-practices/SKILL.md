---
name: security-best-practices
description: Perform language and framework specific security best-practice reviews and suggest improvements. Use when the user requests security guidance, a security review, a security report, or secure-by-default coding help. Also use when the user mentions vulnerabilities, authentication issues, authorization flaws, injection risks, secrets management, OWASP, or any security concern in their code. Supports Python, JavaScript/TypeScript, and Go. Triggers on "security review", "is this secure", "check for vulnerabilities", "harden this", "security audit". Do NOT use for general code review, debugging, threat modeling, or non-security tasks.
metadata:
  author: github.com/openai/skills
  version: '1.1.0'
---

# Security Best Practices

## Overview

This skill provides a description of how to identify the language and frameworks used by the current context, and then to load information from this skill's references directory about the security best practices for this language and or frameworks.

This information, if present, can be used to write new secure by default code, or to passively detect major issues within existing code, or (if requested by the user) provide a vulnerability report and suggest fixes.

## Workflow

The initial step for this skill is to identify ALL languages and ALL frameworks which you are being asked to use or already exist in the scope of the project you are working in. Focus on the primary core frameworks. Often you will want to identify both frontend and backend languages and frameworks.

Then check this skill's references directory to see if there are any relevant documentation for the language and or frameworks. Make sure you read ALL reference files which relate to the specific framework or language. The format of the filenames is `<language>-<framework>-<stack>-security.md`. You should also check if there is a `<language>-general-<stack>-security.md` which is agnostic to the framework you may be using.

If working on a web application which includes a frontend and a backend, make sure you have checked for reference documents for BOTH the frontend and backend!

If you are asked to make a web app which will include both a frontend and backend, but the frontend framework is not specified, also check out `javascript-general-web-frontend-security.md`. It is important that you understand how to secure both the frontend and backend.

If no relevant information is available in the skill's references directory, think a little bit about what you know about the language, the framework, and all well known security best practices for it. If you are unsure you can try to search online for documentation on security best practices.

From there it can operate in a few ways.

1. The primary mode is to just use the information to write secure by default code from this point forward. This is useful for starting a new project or when writing new code.

2. The secondary mode is to passively detect vulnerabilities while working in the project and writing code for the user. Critical or very important vulnerabilities or major issues going against security guidance can be flagged and the user can be told about them. This passive mode should focus on the largest impact vulnerabilities and secure defaults.

3. The user can ask for a security report or to improve the security of the codebase. In this case a full report should be produced describe anyways the project fails to follow security best practices guidance. The report should be prioritized and have clear sections of severity and urgency. Then offer to start working on fixes for these issues. See #fixes below.

## Workflow Decision Tree

- If the language/framework is unclear, inspect the repo to determine it and list your evidence.
- If matching guidance exists in `references/`, load only the relevant files and follow their instructions.
- If no matching guidance exists, consider if you know any well known security best practices for the chosen language and or frameworks, but if asked to generate a report, let the user know that concrete guidance is not available (you can still generate the report or detect for sure critical vulnerabilities)

## Proactive Security Mode

When working alongside other skills (especially code-navi during EXECUTE), proactively flag critical security issues without being asked:

**Always flag (stop and warn):**
- Hardcoded secrets: API keys, passwords, tokens, connection strings in source code
- SQL/NoSQL injection: string concatenation in queries
- Unvalidated user input used in file paths, commands, or redirects
- Disabled security features (CSRF disabled, auth bypassed, CORS set to *)
- Dependencies with known critical CVEs (invoke `dependency-guardian` if available)

**Flag if relevant (note but don't block):**
- Missing rate limiting on public endpoints
- Overly permissive file permissions
- Logging of sensitive data (passwords, tokens, PII)
- Missing input validation on API endpoints

## OWASP Top 10 Checklist

When performing a full security review, check against OWASP Top 10 (2021):

1. **Broken Access Control**: Verify authorization on every endpoint, not just authentication
2. **Cryptographic Failures**: No hardcoded secrets, proper encryption for sensitive data at rest
3. **Injection**: Parameterized queries, input sanitization, no eval/exec with user input
4. **Insecure Design**: Business logic flaws, missing rate limits, no abuse scenarios considered
5. **Security Misconfiguration**: Default credentials, unnecessary features enabled, verbose errors in production
6. **Vulnerable Components**: Dependencies with known CVEs (invoke dependency-guardian)
7. **Authentication Failures**: Weak password policies, missing MFA options, session fixation
8. **Data Integrity Failures**: Verify signatures, check for deserialization vulnerabilities
9. **Logging Failures**: Security events not logged, logs missing context for forensics
10. **SSRF**: Server-side requests to user-supplied URLs without validation

## Secrets Detection

Scan for common secret patterns:

```
Patterns to flag:
- API keys: strings matching [A-Za-z0-9]{20,} near "key", "api_key", "apiKey"
- AWS: AKIA[0-9A-Z]{16}
- JWT: eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+
- Generic: "password" = "...", "secret" = "...", "token" = "..."
- Connection strings: postgres://, mysql://, mongodb:// with credentials
- Private keys: -----BEGIN (RSA |EC |DSA )?PRIVATE KEY-----
```

If secrets are found in committed code, recommend:
1. Rotate the compromised secret immediately
2. Remove from code and use environment variables
3. Add pattern to .gitignore or use git-secrets/gitleaks
4. Check git history for the secret (may need `git filter-repo`)

## Sentry Integration

If Sentry MCP (`user-sentry`) is available:
- Query for security-related errors (auth failures, permission denied, injection attempts)
- Check for error patterns that might indicate attacks
- Verify that security events are being properly logged and tracked

# Overrides

While these references contain the security best practices for languages and frameworks, customers may have cases where they need to bypass or override these practices. Pay attention to specific rules and instructions in the project's documentation and prompt files which may require you to override certain best practices. When overriding a best practice, you MAY report it to the user, but do not fight with them. If a security best practice needs to be bypassed / ignored for some project specific reason, you can also suggest to add documentation about this to the project so it is clear why the best practice is not being followed and to follow that bypass in the future.

# Report Format

When producing a report, you should write the report as a markdown file in `security_best_practices_report.md` or some other location if provided by the user. You can ask the user where they would like the report to be written to.

The report should have a short executive summary at the top.

The report should be clearly delineated into multiple sections based on severity of the vulnerability. The report should focus on the most critical findings as these have the highest impact for the user. All findings should be noted with an numeric ID to make them easier to reference.

For critical findings include a one sentence impact statement.

Once the report is written, also report it to the user directly, although you may be less verbose. You can offer to explain any of the findings or the reasons behind the security best practices guidance if the user wants more info on any findings.

Important: When referencing code in the report, make sure to find and include line numbers for the code you are referencing.

After you write the report file, summarize the findings to the user.

Also tell the user where the final report was written to

# Fixes

If you produced a report, let the user read the report and ask to begin performing fixes.

If you passively found a critical finding, notify the user and ask if they would like you to fix this finding.

When producing fixes, focus on fixing a single finding at a time. The fixes should have concise clear comments explaining that the new code is based on the specific security best practice, and perhaps a very short reason why it would be dangerous to not do it in this way.

Always consider if the changes you want to make will impact the functionality of the user's code. Consider if the changes may cause regressions with how the project works currently. It is often the case that insecure code is relied on for other reasons (and this is why insecure code lives on for so long). Avoid breaking the user's project as this may make them not want to apply security fixes in the future. It is better to write a well thought out, well informed by the rest of the project, fix, then a quick slapdash change.

Always follow any normal change or commit flow the user has configured. If making git commits, provide clear commit messages explaining this is to align with security best practices. Try to avoid bunching a number of unrelated findings into a single commit.

Always follow any normal testing flows the user has configured (if any) to confirm that your changes are not introducing regressions. Consider the second order impacts the changes may have and inform the user before making them if there are any.

# General Security Advice

Below is a few bits of secure coding advice that applies to almost any language or framework.

### Avoid Using Incrementing IDs for Public IDs of Resources

When assigning an ID for some resource, which will then be used by exposed to the internet, avoid using small auto-incrementing IDs. Use longer, random UUID4 or random hex string instead. This will prevent users from learning the quantity of a resource and being able to guess resource IDs.

### A note on TLS

While TLS is important for production deployments, most development work will be with TLS disabled or provided by some out-of-scope TLS proxy. Due to this, be very careful about not reporting lack of TLS as a security issue. Also be very careful around use of "secure" cookies. They should only be set if the application will actually be over TLS. If they are set on non-TLS applications (such as when deployed for local dev or testing), it will break the application. You can provide a env or other flag to override setting secure as a way to keep it off until on a TLS production deployment. Additionally avoid recommending HSTS. It is dangerous to use without full understanding of the lasting impacts (can cause major outages and user lockout) and it is not generally recommended for most projects in review.
