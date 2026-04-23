# Eventra - Technical Documentation

**Project Name:** Eventra (Formerly Spott)
**Description:** A premium, modern, AI-powered event discovery and organization platform built with Next.js, Tailwind CSS, Convex, and Clerk.
**Path:** `S:\backup\Project\eventra`

---

## 1. Core Technologies & Architecture

*   **Framework:** Next.js 16 (App Router)
*   **Styling:** Tailwind CSS v4 with dark-mode Glassmorphism aesthetics (vibrant neon gradients, `backdrop-blur`).
*   **Database & Real-time:** Convex (Serverless Backend).
*   **Authentication:** Clerk (Using `<SignedIn>`, `<SignedOut>`, and `<UserButton>`).
*   **AI Integration:** Google Gemini API (Robust multi-model fallback wrapper).
*   **Media/Images:** Unsplash API (for event cover generation).
*   **Ticketing:** QR Code generation (`react-qr-code`) & scanning (`html5-qrcode`).

---

## 2. Features & Capabilities

### **Event Discovery (`/explore`)**
*   Premium "Bento box" style category browser.
*   Automated geo-location sorting (finds events in your city/state).
*   Beautiful glassmorphic event cards featuring interactive hover effects, animated cover images, and floating badges.

### **Saved Events / Bookmarking (`/saved-events`) [NEW]**
*   Users can bookmark events to revisit later without registering.
*   **Frontend:** A floating bookmark button on `EventCard` that highlights when an event is saved. Includes a dedicated dashboard (`/saved-events`) accessible via the User profile dropdown.
*   **Backend:** Powered by real-time Convex mutations (`api.savedEvents.toggleSave`) and queries.

### **AI-Powered Event Creation (`/create-event`)**
*   Organizers can prompt the AI to auto-fill event details (title, description, category, capacity, etc.).
*   **Robust Gemini Wrapper (`lib/gemini.js`):** [NEW] The AI integration automatically fetches available Gemini models (e.g., `gemini-1.5-flash`), falls back to secondary models if one fails, and automatically retries on `503` or `429` rate-limit errors.
*   Generates gorgeous, Unsplash-powered cover photos.

### **Ticketing & Dashboard (`/my-tickets`, `/my-events`)**
*   Users receive dynamic QR codes upon registration.
*   Organizers can check-in attendees by scanning QR codes.
*   Safe loading states and authentication handling prevent "null user" crashes.

### **Premium Upgrades**
*   Custom UI mockup for "Eventra Pro" upgrade modal (bypasses Clerk Billing requirement for local development).

---

## 3. Database Schema (Convex)

The real-time database consists of three main tables:

1.  **`users`**: Stores user profiles, preferences (location, interests), and tracks how many free events the user has created. Linked to Clerk via `tokenIdentifier`.
2.  **`events`**: Stores comprehensive event data (dates, location type, capacities, tickets, organizer ID, theming).
3.  **`registrations`**: Maps `users` to `events`, containing QR codes and check-in statuses.
4.  **`savedEvents` [NEW]**: Maps `users` to `events` they have bookmarked, including the timestamp of when it was saved.

---

## 4. Environment Variables Required

For deployment (e.g., Vercel) or cloning, you must have the following `.env.local`:

```env
# Clerk Auth
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up

# Convex Database
CONVEX_DEPLOYMENT=dev:...
NEXT_PUBLIC_CONVEX_URL=https://...

# AI & Media
GEMINI_API_KEY=AIza...
NEXT_PUBLIC_UNSPLASH_ACCESS_KEY=...
```

---

## 5. Recent Bug Fixes & Refactors

*   **Auth Flicker:** Replaced Convex's `<Authenticated>`/`<Unauthenticated>` wrappers with Clerk's `<SignedIn>`/`<SignedOut>` to fix the "Sign In" button flashing for already-logged-in users.
*   **Registration Crash:** Fixed a null-pointer exception (`Cannot read properties of null (reading '_id')`) on `/my-tickets` by gracefully handling unauthenticated states while Convex syncs with Clerk.
*   **Clerk Billing Crash:** Removed `<PricingTable />` to prevent development crashes since Stripe billing is disabled in the Clerk Dashboard, replacing it with a custom glassmorphic UI.
*   **Gemini Rate Limits:** Updated the API route to use a custom retry/fallback mechanism.
