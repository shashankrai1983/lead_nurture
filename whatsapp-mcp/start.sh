#!/bin/bash
set -e

# Start Go WhatsApp bridge in background
echo "Starting WhatsApp Bridge..."
cd /app
./whatsapp-bridge &
BRIDGE_PID=$!

# Wait for bridge to initialize
sleep 5

# Start Python MCP server
echo "Starting MCP Server..."
cd /app/python-mcp-server

# Create a simple MCP server wrapper that exposes HTTP endpoints
cat > mcp_http_server.py << 'EOF'
from flask import Flask, request, jsonify
import subprocess
import json
import sqlite3
import os
from datetime import datetime
import uuid

app = Flask(__name__)

# Database path
DB_PATH = os.environ.get('WHATSAPP_DB_PATH', '/data/whatsapp.db')

# Initialize database
def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Create messages table if not exists
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS messages (
            id TEXT PRIMARY KEY,
            workspace_id TEXT,
            user_id TEXT,
            to_number TEXT,
            message TEXT,
            media_url TEXT,
            media_type TEXT,
            status TEXT,
            created_at TIMESTAMP,
            delivered_at TIMESTAMP,
            read_at TIMESTAMP
        )
    ''')
    
    conn.commit()
    conn.close()

init_db()

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/api/messages/send', methods=['POST'])
def send_message():
    try:
        data = request.json
        
        # Extract parameters
        to = data.get('to')
        message = data.get('message')
        message_id = data.get('messageId', str(uuid.uuid4()))
        user_id = data.get('userId')
        workspace_id = data.get('workspaceId')
        media_url = data.get('mediaUrl')
        media_type = data.get('mediaType')
        
        # Store message in database
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO messages (id, workspace_id, user_id, to_number, message, 
                                media_url, media_type, status, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (message_id, workspace_id, user_id, to, message, 
              media_url, media_type, 'sent', datetime.now()))
        
        conn.commit()
        conn.close()
        
        # Call MCP tool to send message
        # Note: In production, integrate with actual WhatsApp MCP tools
        # For now, return success
        
        return jsonify({
            'success': True,
            'messageId': message_id
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/webhooks/status', methods=['POST'])
def webhook_status():
    """Handle WhatsApp status webhooks"""
    try:
        data = request.json
        message_id = data.get('messageId')
        status = data.get('status')
        
        # Update message status in database
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        if status == 'delivered':
            cursor.execute('''
                UPDATE messages 
                SET status = ?, delivered_at = ?
                WHERE id = ?
            ''', ('delivered', datetime.now(), message_id))
        elif status == 'read':
            cursor.execute('''
                UPDATE messages 
                SET status = ?, read_at = ?
                WHERE id = ?
            ''', ('read', datetime.now(), message_id))
        elif status == 'failed':
            cursor.execute('''
                UPDATE messages 
                SET status = ?
                WHERE id = ?
            ''', ('failed', message_id))
        
        conn.commit()
        conn.close()
        
        # Forward to Dittofeed webhook endpoint
        # This would be configured to call back to Dittofeed
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    port = int(os.environ.get('MCP_PORT', 3000))
    app.run(host='0.0.0.0', port=port)
EOF

# Start the HTTP server
python mcp_http_server.py &
MCP_PID=$!

# Function to handle shutdown
shutdown() {
    echo "Shutting down..."
    kill $BRIDGE_PID $MCP_PID 2>/dev/null
    exit 0
}

# Set up signal handlers
trap shutdown SIGINT SIGTERM

# Wait for both processes
wait $BRIDGE_PID $MCP_PID