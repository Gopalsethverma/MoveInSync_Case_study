# Intelligent Floor Plan Management System

A seamless workspace experience application designed to manage floor plans, meeting rooms, and bookings with offline capabilities and intelligent conflict resolution.

## Features & Implementation

### 1. Authentication
**Requirement:** Implement robust user authentication protocols.
- **Implementation:**
    - **Backend:** Uses `bcryptjs` for secure password hashing and `jsonwebtoken` (JWT) for stateless authentication.
    - **Frontend:** Stores JWT in secure local storage (`Hive`) and attaches it to every API request via an interceptor in `ApiService`.
    - **Code Reference:** `floor_manage_backend/src/controllers/authController.js`, `floor_manage_ui/lib/core/services/api_service.dart`.

### 2. Cost Estimation (Time & Space)
**Requirement:** Analyze and optimize time/space complexity.
- **Implementation:**
    - **Database:** Indexed columns on `start_time`, `end_time`, and `room_id` in MySQL ensure O(log N) lookup times for booking conflicts.
    - **Algorithms:** Meeting room recommendation uses sorting (O(N log N)) and linear filtering (O(N)), which is efficient for the expected number of rooms (<100).
    - **Space:** Minimal overhead. Images are stored on disk (or S3 in production), and only metadata is stored in the DB.

### 3. Handling System Failure
**Requirement:** Fault-tolerant mechanisms and data integrity.
- **Implementation:**
    - **Offline Queue:** The frontend `ApiService` detects network failures and saves failed POST requests (like floor plan uploads) to a local queue.
    - **Auto-Sync:** `SyncService` listens for network connectivity restoration and automatically retries pending actions.
    - **Code Reference:** `floor_manage_ui/lib/core/services/sync_service.dart`.

### 4. Object-Oriented Programming (OOPS)
**Requirement:** Use OOPS principles.
- **Implementation:**
    - **Frontend (Dart):** heavily utilizes Classes, Inheritance (e.g., `ApiService`, `SyncService`), and Encapsulation (private fields like `_dio`).
    - **Backend (Node.js):** Uses Sequelize Models (`class MeetingRoom extends Model`) to represent database entities in an object-oriented manner.

### 5. Trade-offs
**Requirement:** Document design decisions.
- **SQL vs NoSQL:** Chosen **MySQL** (SQL) because the relationship between Floor Plans, Rooms, and Bookings is highly structured and relational.
- **Consistency vs Availability:** For offline uploads, we prioritized **Availability** (allowing the admin to work) over immediate Consistency. The system eventually becomes consistent upon reconnection.

### 6. System Monitoring
**Requirement:** Track system performance.
- **Implementation:**
    - Basic request logging is implemented in the backend.
    - **Future Scope:** Integration with Prometheus/Grafana for real-time metrics.

### 7. Caching
**Requirement:** Enhance response times.
- **Implementation:**
    - **Frontend:** Uses `Hive` (NoSQL database) to cache auth tokens and pending offline actions.
    - **Backend:** Sequelize provides first-level caching for database queries.

### 8. Error Handling
**Requirement:** Robust error framework.
- **Implementation:**
    - **Backend:** Centralized `try-catch` blocks in controllers return standardized JSON error responses (500/400/404).
    - **Frontend:** `ApiService` catches exceptions and decides whether to show an error or queue the action for offline sync.

---

## Case Study Specifics

### 1. Admin's Floor Plan Management (Conflict Resolution)
- **Feature:** Prevents overwriting newer floor plans with older versions.
- **Logic:** When uploading, the backend checks the `version` number. If `incoming_version <= current_latest_version`, the upload is rejected with a 409 Conflict error.
- **Code:** `floor_manage_backend/src/controllers/floorPlanController.js`.

### 2. Offline Mechanism for Admins
- **Feature:** Admins can upload floor plans even without internet.
- **Logic:**
    1. `ApiService` detects failure.
    2. Request data (image path, version) is saved to `LocalStorageService`.
    3. `SyncService` detects internet -> Iterates queue -> Uploads to server.

### 3. Meeting Room Optimization
- **Feature:** Suggests best room based on capacity and user preference.
- **Logic:**
    1. **Filter:** Find rooms where `capacity >= required`.
    2. **Availability:** Exclude rooms booked during the requested slot.
    3. **Weightage:** Sort remaining rooms based on the user's past booking history (frequently booked rooms appear first).
- **Code:** `floor_manage_backend/src/controllers/meetingRoomController.js`.

---

## Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Node.js, Express
- **Database:** MySQL
- **Containerization:** Docker, Docker Compose
- **Orchestration:** Kubernetes (EKS)

## How to Run
1. **Docker:** `docker-compose up --build`
2. **Kubernetes:** `kubectl apply -f k8s/`
