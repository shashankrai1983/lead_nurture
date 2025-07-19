# Dittofeed API Reference

## Overview

Dittofeed provides a comprehensive REST API for customer engagement, user journey management, and omni-channel messaging. The API is organized into several authentication levels and functional categories.

## Authentication Levels

### 1. Public API (`/api/public/`)
- **Authentication**: Public Write Key required
- **Purpose**: External integrations, user tracking, subscription management

### 2. Authenticated API (`/api/`)
- **Authentication**: Standard workspace authentication
- **Purpose**: Workspace member operations, resource management

### 3. Admin API (`/api/admin/`)
- **Authentication**: Admin-level authentication
- **Purpose**: Administrative operations, advanced configurations

### 4. Internal API (`/internal-api/`)
- **Authentication**: Internal system access
- **Purpose**: System monitoring, debugging, health checks

---

## Public App APIs

**Base Path**: `/api/public/apps/`
**Authentication**: Public Write Key

### User Tracking
- **POST** `/identify` - Record user identification and traits
- **POST** `/track` - Record user events and actions with properties
- **POST** `/page` - Record page views with optional properties
- **POST** `/screen` - Record mobile screen views with properties
- **POST** `/group` - Assign/unassign users to groups with traits
- **POST** `/batch` - Send multiple events in a single request
- **POST** `/alias` - User aliasing (not yet implemented)

---

## User Management APIs

**Base Paths**: `/api/users/`, `/api/admin/users/`

### User Operations
- **POST** `/` - Get paginated list of users with filtering
- **POST** `/count` - Get count of users matching criteria
- **GET** `/subscriptions` - Get user subscription groups
- **DELETE** `/` - Delete users and their data
- **DELETE** `/v2` - Delete users (query string version)

---

## Event APIs

**Base Paths**: `/api/events/`, `/api/admin/events/`

### Event Data
- **GET** `/` - Get list of events with filtering and pagination
- **GET** `/traits` - Get available traits from identify calls
- **GET** `/properties` - Get available properties from track calls

---

## Journey Management APIs

**Base Paths**: `/api/journeys/`, `/api/admin/journeys/`

### Journey Operations
- **GET** `/` - Get all journeys with optional filtering
- **PUT** `/` - Create or update a journey
- **DELETE** `/` - Delete a journey
- **DELETE** `/v2` - Delete a journey (query string version)
- **GET** `/stats` - Get journey performance statistics

---

## Segment APIs

**Base Paths**: `/api/segments/`, `/api/admin/segments/`

### Segment Management
- **GET** `/` - Get all segments with optional filtering
- **PUT** `/` - Create or update a user segment
- **DELETE** `/` - Delete a segment
- **DELETE** `/v2` - Delete a segment (query string version)

### Segment Data Operations
- **GET** `/download` - Download CSV of segment assignments
- **POST** `/upload-csv` - Upload CSV to update manual segment
- **POST** `/manual-segment/update` - Update manual segment users
- **POST** `/manual-segment/clear` - Clear manual segment
- **GET** `/manual-segment/status` - Get manual segment status

---

## Broadcast APIs

**Base Paths**: `/api/broadcasts/`, `/api/admin/broadcasts/`

### Broadcast Management
- **GET** `/` - Get all broadcasts
- **PUT** `/` - Update a broadcast
- **PUT** `/v2` - Upsert a v2 broadcast
- **PUT** `/archive` - Archive a broadcast
- **PUT** `/trigger` - Trigger a broadcast

### Broadcast Control
- **POST** `/start` - Start a broadcast
- **POST** `/pause` - Pause a broadcast
- **POST** `/resume` - Resume a broadcast
- **POST** `/cancel` - Cancel a broadcast
- **POST** `/execute` - Create and trigger a broadcast in one operation
- **PUT** `/recompute-segment` - Recompute broadcast segment

### Gmail Integration
- **GET** `/gmail-authorization` - Check Gmail authorization status

---

## Content & Template APIs

**Base Paths**: `/api/content/`, `/api/admin/content/`

### Template Management
- **GET** `/templates` - Get message templates
- **PUT** `/templates` - Create or update message template
- **PUT** `/templates/reset` - Reset message template to defaults
- **DELETE** `/templates` - Delete a message template
- **DELETE** `/templates/v2` - Delete message template (query string)

### Template Operations
- **POST** `/templates/render` - Render message template with data
- **POST** `/templates/test` - Send test message for template

---

## User Properties APIs

**Base Paths**: `/api/user-properties/`, `/api/admin/user-properties/`

### Property Management
- **GET** `/` - Get all user properties
- **PUT** `/` - Create or update a user property
- **DELETE** `/` - Delete a user property

---

## Subscription Groups APIs

**Base Paths**: `/api/subscription-groups/`, `/api/admin/subscription-groups/`

### Subscription Management
- **GET** `/` - Get subscription groups
- **PUT** `/` - Create or update subscription group
- **DELETE** `/` - Delete subscription group
- **POST** `/upload-csv` - Upload CSV for subscription group management

---

## Settings & Configuration APIs

**Base Paths**: `/api/settings/`, `/api/admin/settings/`

### Data Sources
- **GET** `/data-sources` - Get data source configurations
- **PUT** `/data-sources` - Create/update data source settings
- **DELETE** `/data-sources` - Delete data source settings

### Email Providers
- **PUT** `/email-providers` - Create/update email provider
- **PUT** `/email-providers/default` - Set default email provider

### SMS Providers
- **PUT** `/sms-providers` - Create/update SMS provider
- **PUT** `/sms-providers/default` - Set default SMS provider

### API Keys
- **GET** `/write-keys` - Get write keys
- **PUT** `/write-keys` - Create write key
- **DELETE** `/write-keys` - Delete write key

---

## Delivery APIs

**Base Paths**: `/api/deliveries/`, `/api/admin/deliveries/`

### Message Delivery
- **GET** `/` - Search through message deliveries with filtering

---

## Integration APIs

**Base Paths**: `/api/integrations/`, `/api/admin/integrations/`

### External Integrations
- **PUT** `/` - Create or update an integration

---

## Admin APIs

### Admin API Keys
**Base Path**: `/api/admin-keys/`
- **POST** `/` - Create admin API key
- **DELETE** `/` - Delete admin API key

### Groups Management
**Base Paths**: `/api/groups/`, `/api/admin/groups/`
- **GET** `/` - Get groups
- **PUT** `/` - Create or update group
- **DELETE** `/` - Delete group

### Computed Properties
**Base Paths**: `/api/computed-properties/`, `/api/admin/computed-properties/`
- **GET** `/` - Get computed properties
- **PUT** `/` - Create or update computed property
- **DELETE** `/` - Delete computed property
- **POST** `/trigger-recompute` - Trigger recomputation

### Secrets Management
**Base Path**: `/api/secrets/`
- **GET** `/` - Get secrets
- **PUT** `/` - Create or update secret
- **DELETE** `/` - Delete secret

### Resources
**Base Path**: `/api/resources/`
- **GET** `/` - Get workspace resources

---

## Webhook Endpoints

**Base Paths**: `/api/public/webhooks/`, `/api/webhooks/`

### Email Service Provider Webhooks

#### SendGrid (`/sendgrid`)
- **Purpose**: Handle email delivery events (delivered, opened, clicked, bounced)
- **Authentication**: Signature verification using public key
- **Events**: Delivery status, engagement tracking, bounce handling

#### Amazon SES (`/amazon-ses`)
- **Purpose**: SNS notification handling for delivery events
- **Authentication**: SNS signature verification
- **Events**: Subscription confirmation, delivery notifications

#### Resend (`/resend`)
- **Purpose**: Email delivery event processing
- **Authentication**: SVIX signature verification
- **Events**: Email delivery status tracking

#### Postmark (`/postmark`)
- **Purpose**: Email delivery events with metadata
- **Authentication**: Secret-based authentication
- **Events**: Delivery tracking, bounce processing

#### Mailchimp/Mandrill (`/mailchimp`)
- **Purpose**: Email delivery events from Mandrill
- **Authentication**: HMAC signature verification
- **Events**: Email engagement tracking

### SMS Service Provider Webhooks

#### Twilio (`/twilio`)
- **Purpose**: SMS delivery status events
- **Authentication**: Twilio signature verification
- **Events**: SMS delivery confirmation, failure notifications

### Analytics Integration Webhooks

#### Segment.io (`/segment`)
- **Purpose**: Receive events from Segment.io
- **Authentication**: Digest-based authentication with shared secret
- **Events**: User tracking data, behavioral events

---

## Public Subscription Management

**Base Path**: `/api/public/subscription-management/`

### User Subscription Control
- **PUT** `/user-subscriptions` - Allow users to manage their email/SMS subscriptions
- **Purpose**: Self-service subscription management for end users
- **Authentication**: User-specific tokens

---

## System APIs

### Health Check
**Base Path**: `/api/`
- **GET** `/` - Application health check and version information

### Debug APIs
**Base Path**: `/internal-api/debug/`
- **Purpose**: Internal system monitoring and debugging
- **Access**: Internal system only

---

## Authentication Methods

### 1. Public Write Key
- **Usage**: Public app endpoints (identify, track, page, screen, group, batch)
- **Header**: `Authorization: Bearer {write_key}`

### 2. Admin API Key
- **Usage**: Admin-level operations and configurations
- **Header**: `Authorization: Bearer {admin_api_key}`

### 3. Workspace Authentication
- **Usage**: Standard workspace member operations
- **Method**: Session-based or token-based authentication

### 4. Webhook Signatures
- **SendGrid**: Public key verification
- **Amazon SES**: SNS signature verification
- **Resend**: SVIX signature verification
- **Postmark**: Secret-based authentication
- **Mailchimp**: HMAC signature verification
- **Twilio**: Twilio signature verification
- **Segment**: Digest-based with shared secret

### 5. Single Tenant Mode
- **Purpose**: Special authentication mode for single-tenant deployments
- **Usage**: Simplified authentication for dedicated instances

---

## Rate Limiting & Best Practices

- Use batch endpoints for bulk operations
- Implement proper error handling for webhook retries
- Verify webhook signatures for security
- Use pagination for large data sets
- Cache frequently accessed data where appropriate

---

## OpenAPI Documentation

Complete OpenAPI 3.1.0 specification available at:
- **Location**: `/packages/docs/open-api.json`
- **Features**: Complete schema definitions, security schemes, tagged endpoints, request/response schemas