# WhatsApp Integration Design for Dittofeed

## Overview
This document outlines the design for integrating WhatsApp as a new messaging channel in Dittofeed using the WhatsApp MCP (Model Context Protocol) server.

## Architecture Components

### 1. New Channel Type
Add WhatsApp as a new channel type alongside existing Email, SMS, MobilePush, and Webhook channels.

**Location**: `packages/isomorphic-lib/src/types.ts`
```typescript
export const ChannelType = {
  Email: "Email",
  MobilePush: "MobilePush",
  Sms: "Sms",
  Webhook: "Webhook",
  WhatsApp: "WhatsApp", // NEW
} as const;
```

### 2. WhatsApp Provider Type
Define WhatsApp provider types for the channel.

**Location**: `packages/isomorphic-lib/src/types.ts`
```typescript
export enum WhatsAppProviderType {
  WhatsAppMCP = "WhatsAppMCP",
  Test = "Test",
}
```

### 3. WhatsApp MCP Service Integration

#### Docker Service
Add WhatsApp MCP as a new service in the Docker Compose configuration:
- Go WhatsApp Bridge: Handles WhatsApp Web API connection
- Python MCP Server: Provides standardized interaction tools
- SQLite database for message storage

#### Service Communication
- Dittofeed Worker → WhatsApp MCP Server (via HTTP/REST API)
- WhatsApp MCP → WhatsApp Web API (via Go bridge)

### 4. Database Schema

#### New Tables
1. `whatsappProvider` - Store WhatsApp provider configurations
   - id
   - workspaceId
   - type (WhatsAppMCP)
   - config (JSON - MCP server URL, auth details)
   - createdAt
   - updatedAt

2. `defaultWhatsappProvider` - Store default WhatsApp provider per workspace
   - workspaceId
   - whatsappProviderId

### 5. Backend Implementation

#### WhatsApp Destination (`packages/backend-lib/src/destinations/whatsapp-mcp.ts`)
```typescript
// Core functions:
- sendWhatsAppMessage() - Send message via MCP server
- sendWhatsAppFile() - Send media files
- submitWhatsAppEvents() - Process delivery/read receipts
```

#### Message Template Types
- Text messages
- Media messages (images, videos, documents)
- Template messages (future enhancement)

### 6. Journey Builder Integration

#### WhatsApp Step Type
Add WhatsApp as a new step type in journeys:
- Message configuration (text/media)
- Contact selection (phone number from user properties)
- Provider selection

#### Template Editor
- Simple text editor for WhatsApp messages
- Media upload support
- Variable interpolation ({{firstName}}, etc.)

### 7. API Endpoints

#### Settings API
- `PUT /api/settings/whatsapp-providers` - Create/update WhatsApp provider
- `PUT /api/settings/whatsapp-providers/default` - Set default provider
- `DELETE /api/settings/whatsapp-providers` - Delete provider

#### Message API
- `POST /api/content/templates/whatsapp/test` - Send test WhatsApp message
- `POST /api/content/templates/whatsapp/render` - Preview rendered message

### 8. WhatsApp MCP Server Setup

#### Environment Variables
```
WHATSAPP_MCP_URL=http://whatsapp-mcp:3000
WHATSAPP_MCP_AUTH_TOKEN=<token>
```

#### Docker Service Configuration
```yaml
whatsapp-mcp:
  image: whatsapp-mcp:latest
  ports:
    - "3000:3000"
  volumes:
    - whatsapp-data:/data
  environment:
    - DB_PATH=/data/whatsapp.db
```

## Implementation Plan

### Phase 1: Core Backend
1. Add WhatsApp channel type to isomorphic-lib
2. Create database schema and migrations
3. Implement WhatsApp MCP destination in backend-lib
4. Add WhatsApp provider API endpoints

### Phase 2: Docker Integration
1. Create Dockerfile for WhatsApp MCP
2. Add service to docker-compose
3. Configure networking and volumes
4. Test service communication

### Phase 3: Journey Builder UI
1. Add WhatsApp step to journey builder
2. Create WhatsApp template editor
3. Add provider configuration UI
4. Implement test message functionality

### Phase 4: Testing & Polish
1. End-to-end journey testing
2. Error handling and retries
3. Delivery status tracking
4. Documentation

## Security Considerations

1. **Authentication**: Secure communication between Dittofeed and WhatsApp MCP
2. **Data Privacy**: WhatsApp messages stored locally in MCP SQLite database
3. **Rate Limiting**: Implement rate limits to prevent WhatsApp API abuse
4. **Encryption**: Ensure sensitive data is encrypted in transit and at rest

## Limitations

1. **Personal WhatsApp**: Uses WhatsApp Web API (not Business API)
2. **Single Device**: One WhatsApp account per MCP instance
3. **Media Storage**: Files stored locally in MCP server
4. **No Templates**: Initial version won't support WhatsApp Business templates

## Future Enhancements

1. WhatsApp Business API integration
2. Message templates support
3. Rich media messages (buttons, lists)
4. Group messaging support
5. Multi-device support