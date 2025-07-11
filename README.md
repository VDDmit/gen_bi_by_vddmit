# Gen BI – Conversational BI Assistant (PoC)

**Conversational AI Assistant for AI-powered accounting analytics**

This proof-of-concept lets analysts inspect AI mistakes and human corrections using plain language. Natural-language questions are translated into SQL queries and simple charts using Anthropic Claude and Wren AI OSS.

---

## One-liner start

If this is your **first** time running the project, or you’ve made changes to the code or dependencies, run:
```bash
docker compose up --build
```
For **regular** use (after the initial setup), you can simply run:
```bash
docker compose up
```
This will start the application using existing Docker images without rebuilding them.

---

## Environment Variables for Gemini

Create `.env` file in the project root:

```dotenv
# --- General Docker ---
COMPOSE_PROJECT_NAME=wrenai
PLATFORM=linux/amd64
PROJECT_DIR=.

# --- Ports ---
WREN_ENGINE_PORT=8080
WREN_ENGINE_SQL_PORT=7432
WREN_AI_SERVICE_PORT=5555
IBIS_SERVER_PORT=8000
WREN_UI_PORT=3000
HOST_PORT=3000
AI_SERVICE_FORWARD_PORT=5555
WREN_UI_ENDPOINT=http://wren-ui:${WREN_UI_PORT}

# --- Gemini ---
LLM_PROVIDER=gemini
GEMINI_API_KEY=<your-gemini-api-key>  # Replace with your actual Gemini API key
GENERATION_MODEL=gemini/gemini-2.0-flash

# --- ClickHouse ---
IMAGE_VERSION=25.5.6.14
CLICKHOUSE_HTTP_PORT=8123
CLICKHOUSE_TCP_PORT=9000
CLICKHOUSE_USER_READONLY=gen_bi_usr
CLICKHOUSE_PASSWORD_READONLY=gen_bi_pass
CLICKHOUSE_DB=gen_bi_db

# ClickHouse connection string
CLICKHOUSE_DSN=clickhouse://gen_bi_usr:gen_bi_pass@clickhouse:9000/gen_bi_db

# --- Optional Analytics / Telemetry ---
POSTHOG_API_KEY=<your-posthog-key>
POSTHOG_HOST=https://app.posthog.com
TELEMETRY_ENABLED=true

# --- Wren Versions ---
WREN_PRODUCT_VERSION=0.25.0
WREN_ENGINE_VERSION=0.17.1
WREN_AI_SERVICE_VERSION=0.24.3
WREN_UI_VERSION=0.30.0
IBIS_SERVER_VERSION=0.17.1
WREN_BOOTSTRAP_VERSION=0.1.5

# --- Optional Tracking ---
LANGFUSE_PUBLIC_KEY=
LANGFUSE_SECRET_KEY=

# --- Flags ---
SHOULD_FORCE_DEPLOY=1
EXPERIMENTAL_ENGINE_RUST_VERSION=false
LOG_LEVEL=debug
```

---

## Tech Stack

| Layer       | Tech                                      | Purpose                                           |
|-------------|-------------------------------------------|---------------------------------------------------|
| UI          | Wren AI OSS Web UI                        | Built-in chat & chart UI, no extra frontend work  |
| NL→SQL/Chart| Gen BI agent (Wren pipeline)              | Text-to-SQL, Text-to-Chart, insights              |
| LLM         | Gemini 2 Flash (via LiteLLM)              | Natural language understanding, SQL/chart generation |
| Embedder    | Gemini text-embedding-004 (via LiteLLM)   | Semantic search on DB structure & question memory |
| DB          | ClickHouse                                | Append-only audit logs for analysis               |
| Document DB | Qdrant vector store                       | Vector storage for semantic retrieval             |
| Scripting   | Python 3.12                               | Configuration, orchestration                      |
| Glue Engine | Wren UI / Ibis HTTP Engines               | SQL exec and type inference                       |
---

## Demo Prompt Example

```
top 5 fields changed for sales transactions last quarter and, for each field, most active user
```

---

## Acceptance Criteria

- F-1 to F-5 functional requirements met via Wren UI
- `docker compose up` works on clean machine with `.env` setup
- Demo query returns both table and chart in ≤ 5 seconds
- Only SELECT queries allowed (write protection)

### Example of query execution
#### View basic answer
![](image/image-1.jpg)
#### View sql
![](image/image-2.jpg)
#### View chart
![](image/image-3.jpg)