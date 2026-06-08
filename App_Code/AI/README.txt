Election AI Module (isolated)
=============================

This folder is self-contained. Safe to delete entire App_Code/AI folder + AI/AskTest.aspx* if not needed.

Files:
  ElectionAIConfig.cs           - limits, allowed views
  ElectionAIModels.cs           - JSON response
  ElectionAIPrompt.cs           - LLM prompt + schema injection
  ElectionAISchemaRegistry.cs   - exact ai_* column lists (Stage 2)
  ElectionAIIntentRouter.cs     - intent + view routing (Stage 1, no LLM)
  ElectionAIQueryTemplates.cs   - safe SQL templates for common questions
  ElectionAISqlValidator.cs     - SELECT-only, ai_* views only
  ElectionAIExecutor.cs         - runs SQL with @app_id
  ElectionAIClient.cs           - Azure OpenAI HTTP
  ElectionAIService.cs          - template first, then LLM fallback

Pipeline:
  1) Route question (keywords) -> intent + views
  2) If known intent -> use safe SQL template (no wrong columns)
  3) Else -> Azure LLM with injected schema for selected views only
  4) Validate + execute SQL
  5) On SQL error -> one Azure fix retry

WebService:
  NEW method only: AskElectionAI(user_question, app_id)
  Does NOT modify GetAIElectionData or AIQueryEngine.

Test page:
  /AI/AskTest.aspx

Database:
  Requires ai_* views from Database/AI/View.sql
  Guide: Database/AI/AI_Schema_Guide.txt

Azure config (Web.config appSettings):
  AzureOpenAIEndpoint  = https://YOUR-RESOURCE.openai.azure.com/
  AzureOpenAIKey       = from Azure Portal -> Keys and Endpoint
  AzureDeployment      = your deployment name (e.g. gpt-4o-mini)

If error "remote name could not be resolved":
  - Endpoint hostname is INVALID (resource deleted or wrong URL).
  - Fix in Azure Portal, NOT in C# code.
  - Open /AI/AzureCheck.ashx in browser to test DNS for the hostname in Web.config.

Steps to fix Azure DNS error:
  1. Azure Portal -> Azure OpenAI resource -> Keys and Endpoint
  2. Copy Endpoint (https://xxxx.openai.azure.com/) and Key
  3. Copy Deployment name (Model deployments)
  4. Update Web.config: AzureOpenAIEndpoint, AzureOpenAIKey, AzureDeployment
  5. Restart IIS / app pool
  6. Test: /AI/AzureCheck.ashx should show "DNS OK"
