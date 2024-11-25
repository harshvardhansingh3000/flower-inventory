# Project Requirements #
## Overview ##
You are developing a Flower Inventory Management System comprising:

Backend API: A Node.js application providing RESTful API endpoints.
Database: A PostgreSQL database hosted on Heroku.
Frontend Application: An Android mobile app interacting with the backend.
## Functional Requirements ##
1. User Management 

User Registration: Users can sign up with a username, password, and role.
User Authentication: Users can log in and receive a JWT for authenticated requests.
Roles:
Admin: Full access to all functionalities.
Manager: Access to inventory management.
Staff: Can view inventory and make reservations.
2. Flower Inventory Management 

CRUD Operations:
Create: Add new flowers to the inventory.
Read: View all flowers and their details.
Update: Modify existing flower details.
Delete: Remove flowers from the inventory.
Inventory Tracking:
Monitor flower quantities.
Set thresholds for low stock alerts.
3. Reservation System

Create Reservations:
Staff can reserve flowers for sale to parties.
Include details like flower type, quantity, sell date, and party name.
Manage Reservations:
Admins and Managers can approve or reject reservations.
Reservations have statuses: pending, approved, or rejected.
Reservations have statuses: pending, approved, or rejected.
4. Security

Authentication:
Use JWTs to secure API endpoints.
Passwords hashed using bcrypt.
Authorization:
Implement role-based access control.
5. API Documentation

Provide clear documentation for all endpoints.
## Non-Functional Requirements ##
Scalability: Design to handle up to 500 users.
Maintainability: Write clean, modular code.
Security: Secure handling of sensitive data.
Performance: Ensure efficient database queries and response times.

# Detailed Feature Description #
1. User Management
User Registration
Sign Up: Users can create an account by providing a username, password, and selecting a role (Admin, Manager, Staff).
Input Validation: Ensure all user input is validated on both the client and server sides to prevent invalid or malicious data entry.
Secure Password Storage: Passwords are hashed using bcrypt before being stored in the database for enhanced security.
User Authentication
Login: Implement a secure login system where users authenticate with their credentials.
JWT Issuance: Upon successful authentication, users receive a JSON Web Token (JWT) to access protected API endpoints.
Session Management: Manage user sessions securely to prevent unauthorized access.
Role-Based Access Control
Admin
Full access to all system functionalities.
Can manage users, inventory, reservations, and system settings.
Manager
Can manage inventory and reservations.
Access to add, update, and view flowers and reservations.
Staff
Can view inventory details.
Can create and manage their own reservations.
2. Flower Inventory Management
View All Flowers
Flower List Retrieval: Users can access a list of all available flowers in the inventory.
Flower Details: Each flower entry includes name, type, description, quantity, and images.
CRUD Operations
Create
Admins and Managers can add new flowers to the inventory.
Input includes flower details and optional images.
Read
View detailed information about individual flowers.
Update
Admins and Managers can modify flower details such as quantity, description, and images.
Delete
Admins can remove flowers from the inventory when they are no longer available.
Inventory Tracking
Real-Time Monitoring: Keep track of the quantities of each flower type in real-time.
Threshold Alerts: Set minimum stock level thresholds to trigger low stock alerts.
3. Reservation System
Create Reservations
Reservation Creation: Staff can create reservations for customers, specifying:
Flower type and quantity
Sell date
Customer or party name
Status Assignment: New reservations are assigned a pending status by default.
Manage Reservations
View Reservations
Admins and Managers can view all reservations with details and current status.
Staff can view their own reservations.
Update Reservation Status
Admins and Managers can approve or reject reservations.
Status updates are recorded, and notifications are sent to the relevant staff member.
Reservation History
Maintain a history of all reservations, including changes made and by whom, for audit purposes.
4. Security Measures
Password Handling
Secure Storage: Use bcrypt to hash passwords before storing them in the database.
Password Policies: Enforce strong password requirements to enhance security.
Authentication and Authorization
JWT Authentication: Protect API endpoints using JWTs to ensure that only authenticated users can access them.
Role-Based Access Control: Implement fine-grained access control based on user roles to restrict access to certain functionalities.
Input Validation
Server-Side Validation: Validate all inputs on the server to prevent SQL injection and cross-site scripting attacks.
Error Handling: Provide meaningful error messages without revealing sensitive system information.
5. User Profile Management
Profile Editing
Update Personal Information: Users can edit their personal details such as email, phone number, and address.
Change Password: Users can update their password after re-authenticating.
Password Recovery
Forgot Password: Implement a secure password recovery process using email verification.
Email Verification: Send a secure link or code to the user's registered email for password reset.
6. Search and Filtering
Advanced Search
Flowers Search: Users can search for flowers by name, type, or other attributes.
Reservations Search: Search reservations using criteria like customer name, date range, or status.
Filtering Options
Inventory Filters: Filter flowers by availability, type, or low stock.
Reservations Filters: Filter reservations by status (pending, approved, rejected) or date.
7. Image Support
Flower Images
Upload Images: Admins and Managers can upload images when adding or updating flowers.
Image Display: Show flower images in the inventory list and detail views.
Storage Optimization: Optimize images for web use to ensure fast loading times.
8. Inventory Notifications
Low Stock Alerts
Automatic Notifications: The system automatically notifies Admins and Managers when stock levels fall below the set threshold.
Notification Methods: Support for notifications via email and SMS.
Critical Updates
Reservation Updates: Notify relevant staff when their reservations are approved or rejected.
System Messages: Provide system-wide announcements for maintenance or updates.
9. Audit Trail
History Tracking
Inventory Changes: Log all additions, updates, and deletions in the inventory, including timestamps and user actions.
Reservation Changes: Record all modifications to reservations for accountability
Access Logs
User Actions: Track user logins and significant actions performed within the system.
Security Auditing: Use logs to monitor for suspicious activities and enhance system security.
10. Admin selects a reservation from the list of reservations.
Transaction approval: Admin confirms that the reservation is valid and a transaction can be made.
Inventory Update: The quantity of flowers involved in the reservation is subtracted from the inventory.
Reservation Deletion: Once the transaction is completed, the reservation is deleted from the database.
11. API Documentation
Comprehensive Documentation
Endpoint Details: Document all API endpoints with descriptions, request and response formats.
Authentication Requirements: Specify which endpoints require JWT authentication and the necessary permissions.
Example Requests: Provide sample requests and responses for developers.
12. Non-Functional Requirements
Scalability
Architecture Design: Build the system to support up to 500 concurrent users seamlessly.
Performance Optimization: Optimize database queries and server responses for high performance.
Maintainability
Code Quality: Write clean, modular, and well-documented code following best practices.
Modular Structure: Organize code into modules or services to simplify updates and maintenance.
Security
Data Protection: Encrypt sensitive data in transit and at rest.
Regular Updates: Keep all dependencies and libraries up to date to mitigate security vulnerabilities.
Security Audits: Conduct periodic security assessments and penetration testing.
Performance
Efficient Queries: Optimize database interactions to reduce latency.
Caching Mechanisms: Implement caching where appropriate to improve response times.
Load Testing: Perform load testing to ensure the system can handle peak traffic.
User Experience
Responsive Design: Ensure the mobile app provides a consistent experience across different Android devices.
Intuitive Interface: Design user interfaces that are easy to navigate and understand.
Accessibility: Follow accessibility guidelines to make the app usable for all users.

