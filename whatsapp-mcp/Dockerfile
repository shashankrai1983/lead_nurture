# WhatsApp MCP Server Dockerfile

# Stage 1: Go WhatsApp Bridge
FROM golang:1.21-alpine AS go-builder

# Install dependencies
RUN apk add --no-cache git

# Clone WhatsApp MCP repository
RUN git clone https://github.com/lharries/whatsapp-mcp.git /whatsapp-mcp

# Build Go WhatsApp bridge
WORKDIR /whatsapp-mcp/go-whatsapp-bridge
RUN go mod download
RUN go build -o whatsapp-bridge

# Stage 2: Python MCP Server
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Copy Go bridge from builder
COPY --from=go-builder /whatsapp-mcp/go-whatsapp-bridge/whatsapp-bridge /app/whatsapp-bridge

# Clone WhatsApp MCP repository for Python code
RUN git clone https://github.com/lharries/whatsapp-mcp.git /tmp/whatsapp-mcp

# Copy Python MCP server code
RUN cp -r /tmp/whatsapp-mcp/python-mcp-server /app/python-mcp-server && \
    rm -rf /tmp/whatsapp-mcp

# Copy custom requirements
COPY requirements.txt /app/python-mcp-server/requirements.txt

# Install Python dependencies
WORKDIR /app/python-mcp-server
RUN pip install --no-cache-dir -r requirements.txt

# Create data directory for SQLite database
RUN mkdir -p /data

# Copy wrapper script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Environment variables
ENV WHATSAPP_DB_PATH=/data/whatsapp.db
ENV MCP_PORT=3000

# Expose MCP server port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start both services
CMD ["/app/start.sh"]