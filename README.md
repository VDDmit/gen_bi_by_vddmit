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

## Environment Variables

Create `.env` file in the project root:

```dotenv
# --- Gemini ---
LLM_PROVIDER=gemini

GEMINI_API_KEY=<yours gemini api key>

# ClickHouse connection string
CLICKHOUSE_DSN=clickhouse://<username>:<password>@<host>:<port>/<database>
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

You can also append “as chart” to see the result visualized:

```
top 5 fields changed for sales transactions last quarter and, for each field, most active user as chart
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