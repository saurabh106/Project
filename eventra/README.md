# Project Documentation: Spott (AI Event Organiser)

## 1. Project Overview & Motive

**Project Name:** Spott
**Core Motive:** Spott is a modern, full-stack web application designed to seamlessly bridge the gap between event organizers and attendees. It aims to provide a beautiful, frictionless experience for users to discover local or online events, seamlessly register for them, and easily host their own events. 

The platform simplifies event ticketing by generating unique QR codes for attendees and gives organizers a simple dashboard to manage capacities, locations, and attendees. The ultimate goal is to make event management as simple as a few clicks, leveraging modern UI/UX principles and real-time data sync.

---

## 2. Technical Architecture & Tech Stack

The application is built using a modern React stack, prioritizing performance, real-time updates, and developer experience.

*   **Frontend Framework:** Next.js 16 (App Router) with React 19.
*   **Styling:** Tailwind CSS v4.
*   **UI Components:** Shadcn UI (Radix UI primitives) for accessible, customizable components.
*   **Backend & Database:** Convex. Provides a real-time, serverless database and cloud functions.
*   **Authentication:** Clerk. Handles user sign-ups, secure sessions, and JWT-based authorization with Convex.
*   **Image Sourcing:** Unsplash API integration to fetch high-quality cover photos for events.
*   **Ticketing:** QR code generation (`react-qr-code`) and scanning (`html5-qrcode`) for seamless event check-ins.
*   **AI Integration:** Google Generative AI (Gemini) integration (via `@google/generative-ai`), likely intended to assist organizers in generating event descriptions, suggesting tags, or optimizing schedules.

---

## 3. Core Features & Routing Structure

The application is split into protected routes (requiring login) and public routes.

### Public Features (`app/(public)`)
*   **Landing Page (`/`):** A visually striking hero section introducing "Spott" and encouraging users to explore.
*   **Explore (`/explore`):** A discovery feed where users can search for events based on categories, titles, or dates.
*   **Event Details (`/events/[slug]`):** A detailed view of a specific event showing date, location (physical/online), capacity, price, and a registration button.

### Protected Features for Organizers & Attendees (`app/(main)`)
*   **Create Event (`/create-event`):** A robust form (powered by `react-hook-form` and `zod`) for users to create new events. Organizers can define capacity, free/paid status, physical/online locations, and pick an Unsplash cover image.
*   **My Events (`/my-events`):** A dashboard for organizers to view the events they have hosted and track registration counts.
*   **My Tickets (`/my-tickets`):** A digital wallet for attendees displaying their confirmed registrations. This includes a unique QR code for each ticket that organizers can scan for check-in.

---

## 4. Database Schema (Convex Models)

The data layer is structured in `convex/schema.js` and consists of three main tables:

### A. `users` Table
Stores user profiles and limits.
*   **Auth:** `tokenIdentifier` (links to Clerk), `email`, `name`, `imageUrl`.
*   **Preferences:** `location` (city, state, country), `interests` (array of categories to personalize the explore feed).
*   **Organizer Limits:** `freeEventsCreated` (tracks how many events a user has hosted to enforce free-tier limits).

### B. `events` Table
Stores all event details.
*   **Basic Info:** `title`, `description`, `slug`, `category`, `tags`.
*   **Logistics:** `startDate`, `endDate`, `timezone`.
*   **Location:** `locationType` (physical or online), `venue`, `address`, `city`, `country`.
*   **Ticketing:** `capacity`, `ticketType` (free/paid), `ticketPrice`, `registrationCount`.
*   **Media:** `coverImage`, `themeColor`.
*   **Relations:** `organizerId` (links to `users`).

### C. `registrations` Table
The "Tickets" table mapping users to events.
*   **Relations:** `eventId` (links to `events`), `userId` (links to `users`).
*   **Attendee Info:** `attendeeName`, `attendeeEmail`.
*   **Access:** `qrCode` (unique string for entry), `status` (confirmed/cancelled).
*   **Check-in Logic:** `checkedIn` (boolean), `checkedInAt` (timestamp).

---

## 5. Development Workflow

1.  **UI Construction:** Components are built modularly in `components/ui/` (Shadcn UI) and custom domain components in `components/`.
2.  **State & Data Fetching:** Frontend components use Convex React hooks (`useQuery`, `useMutation`) to interact with `convex/*.js` server functions.
3.  **Form Submissions:** When an event is created, it passes through Zod validation before firing a Convex mutation.
4.  **Real-time sync:** Because it uses Convex, actions like a user registering for an event instantly update the `registrationCount` on the frontend for all users viewing that event without a page reload.
