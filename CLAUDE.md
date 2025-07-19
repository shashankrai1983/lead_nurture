## System Overview

Dittofeed is an omni-channel customer engagement platform that enables automated user journeys, broadcasts, and message delivery across multiple channels. This document provides a comprehensive architectural overview of the data flow within the Krishna Bhumi Lead Nurturing Tool implementation.

## Your role
Your role is of technical architect, write code, Test, Debug and fix.

If I report a bug in your code, after you fix it, you should pause and ask me to verify that the bug is fixed.

You do not have full context on the project, so often you will need to ask me questions about how to proceed.

Don't be shy to ask questions -- I'm here to help you!

If I send you a URL, you MUST immediately fetch its contents and read it carefully, before you do anything else.

## Documentation Links
- Dittofeed Implementation: https://docs.dittofeed.com/introduction
- Architecture Data Flow: ./dataflow.md
- Gemini CLI: ./GEMINI.md
- API Reference ./api.md

## Workflow
We use GitHub issues to track work we need to do, and PRs to review code. Whenever you create an issue or a PR, tag it with "by-claude". Use the gh bash command to interact with GitHub.

To start working on a feature, you should:

Setup
Read the relevant GitHub issue (or create one if needed)
Checkout main and pull the latest changes
Create a new branch like claude/feature-name. NEVER commit to main. NEVER push to origin/main.
Development
Commit often as you write code, so that we can revert if needed.
When you have a draft of what you're working on, ask me to test it in the app to confirm that it works as you expect. Do this early and often.
Review
When the work is done, verify that the diff looks good with git diff main
While you should attempt to write code that adheres to our coding style, don't worry about manually linting or formatting your changes. There are Husky pre-commit Git hooks that will do this for you.
Push the branch to GitHub
Open a PR.
The PR title should not include the issue number
The PR description should start with the issue number and a brief description of the changes.
Next, you should write a test plan.  you will execute the test plan before merging the PR. If you can't check off any of the items, you will let me know. Make sure the test plan covers both new functionality and any EXISTING functionality that might be impacted by your changes
Fixing issues
To reconcile different branches, always rebase or cherry-pick. Do not merge.
Sometimes, after you've been working on one feature, I will ask you to start work on an unrelated feature. If I do, you should probably repeat this process from the beginning (checkout main, pull changes, create a new branch). When in doubt, just ask.



## Project Structure
- **Core Application**: `dittofeed/packages/`
  - **API Layer**: `api/` - REST API server and controllers
  - **Dashboard UI**: `dashboard/` - Next.js frontend application
  - **Backend Logic**: `backend-lib/` - Core business logic, database schemas, workflows
  - **Admin CLI**: `admin-cli/` - Command-line administration tools
  - **Worker Services**: `worker/` - Background task processing
  - **Lite Version**: `lite/` - Lightweight deployment option
  - **Shared Libraries**: 
    - `isomorphic-lib/` - Shared utilities between frontend/backend
    - `emailo/` - Email editor component
- **Documentation**: `dittofeed/docs/` - Project documentation
- **Examples**: `dittofeed/examples/` - Sample configurations and integrations
- **Infrastructure**: 
  - `dittofeed/helm-charts/` - Kubernetes deployment charts
  - `dittofeed/render/` - Container configurations
  - `dittofeed/scripts/` - Deployment and setup scripts


## Debugging provider calls
When we run into issues with the requests we're sending to model providers (e.g., the way we format system prompts, attachments, tool calls, or other parts of the conversation history) a helpful debugging step is to add the line console.log(createParams: ${JSON.stringify(createParams, null, 2)}); to ProviderAnthropic.ts. Then you can ask me to send a message to Claude and show you the log output.

## Coding style
TypeScript: Strict typing enabled, ES2020 target. Use as only in exceptional circumstances, and then only with an explanatory comment. Prefer type hints.
Paths: @ui/*, @core/*, @/* aliases. Use these instead of relative imports.
Components: PascalCase for React components
Interfaces: Prefixed with "I" (e.g., IProvider)
Hooks: camelCase with "use" prefix
Formatting: 4-space indentation, Prettier formatting
Promise handling: All promises must be handled (ESLint enforced)
Nulls: Prefer undefined to null. Convert null values from the database into undefined, e.g. parentChatId: row.parent_chat_id ?? undefined


# changes confirmation according to prompt
I want you to go through each change you made and cross-check it against my prompts. Did you do everything perfectly? Have you made any mistakes?"


