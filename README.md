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

## Setup and Run Instructions

Follow these steps to set up the environment, restore the necessary data, and launch the project.

### 1. Restore the ClickHouse Database

First, you need to unpack the ClickHouse database and log backups. This is a test database that is required for proper indexing and for Wren AI to utilize pre-existing states.

#### 1.1. Unpack Data
This command will extract all files from `clickhouse_data_backup.zip` and place them directly into the `clickhouse_data/` directory.

```bash
unzip backup/clickhouse_data_backup.zip -d clickhouse_data/
```

#### 1.2. Unpack Logs
Similarly, unpack the logs into the `clickhouse_logs/` directory.

```bash
unzip backup/clickhouse_logs_backup.zip -d clickhouse_logs/
```

### 2. Configure the Application

Adjust the ` .env` and `config.yaml` files to match the AI model you intend to use. You can find configuration examples in the official Wren AI repository:
*   **Wren AI GitHub:** [https://github.com/Canner/WrenAI](https://github.com/Canner/WrenAI)

### 3. Restore Data Volume and Launch the Project

To ensure data persistence correctly with Docker, the recommended approach is to copy the data from `backup/data_backup` into a Docker named volume. The script below automates this process.

#### Using the Restoration Script

This script reads your `.env` file to determine the project name, creates a dedicated Docker volume, copies the backup data into it, and then starts the project with `docker-compose`.

Save the following code as `restore_and_run.sh`, make it executable (`chmod +x restore_and_run.sh`), and then run it (`./restore_and_run.sh`).

```bash
#!/bin/bash
# Script to restore data to a Docker named volume and launch the project

# Exit immediately if a command exits with a non-zero status
set -e

# --- Step 1: Preparation ---
echo "--- Reading configuration from .env file ---"
# Check if the .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found!"
    exit 1
fi

# Get the project name to name the volume correctly
PROJECT_NAME=$(grep COMPOSE_PROJECT_NAME .env | cut -d '=' -f2)
DATA_VOLUME_NAME="${PROJECT_NAME}_data"
BACKUP_SOURCE_DIR="$(pwd)/backup/data_backup"

echo "Project name: ${PROJECT_NAME}"
echo "Target volume name: ${DATA_VOLUME_NAME}"
echo "Backup source: ${BACKUP_SOURCE_DIR}"

# Check if the backup source directory exists
if [ ! -d "$BACKUP_SOURCE_DIR" ]; then
    echo "Error: Backup directory ${BACKUP_SOURCE_DIR} not found!"
    exit 1
fi

# --- Step 2: Restore Data to the Volume ---
echo "--- Creating volume '${DATA_VOLUME_NAME}' (if it does not exist) ---"
docker volume inspect ${DATA_VOLUME_NAME} >/dev/null 2>&1 || docker volume create ${DATA_VOLUME_NAME}

echo "--- Copying data from backup to volume ${DATA_VOLUME_NAME} ---"
# Use a temporary container to copy files into the named volume
docker run --rm \
  -v "${DATA_VOLUME_NAME}:/data_volume" \
  -v "${BACKUP_SOURCE_DIR}:/backup_source:ro" \
  alpine \
  sh -c "echo 'Clearing target volume...'; rm -rf /data_volume/*; echo 'Copying...'; cp -a /backup_source/. /data_volume/"

echo "--- Data successfully restored to volume ${DATA_VOLUME_NAME}. ---"

# --- Step 3: Launch the Project ---
echo "--- Starting the project using docker-compose ---"
docker compose up -d

echo ""
echo "--- Done! The project has been launched with the restored data. ---"

```

**Note:** If your `docker-compose.yml` is configured to use a local bind mount (e.g., `./data:/app/data`) instead of a named volume, you can use the simpler, but less robust, method of renaming the `backup/data_backup` directory to `data` in the project root before running `docker compose up -d`. However, the script above is the recommended approach for managing persistent data in Docker.
