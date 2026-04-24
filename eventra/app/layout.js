import { ClerkProvider } from "@clerk/nextjs";
import { auth } from "@clerk/nextjs/server";
import Header from "@/components/header";
import "./globals.css";
import { dark } from "@clerk/themes";
import { ThemeProvider } from "@/components/theme-provider";
import Footer from "@/components/footer";
import { ConvexClientProvider } from "@/components/convex-client-provider";
import { Toaster } from "sonner";

export const metadata = {
  title: "Eventra - The Ultimate Event Experience",
  description: "Discover and create amazing events with Eventra",
};

export default async function RootLayout({ children }) {
  // DEBUGGING FOR CONVEX AUTH
  try {
    const { getToken } = await auth();
    const token = await getToken({ template: "convex" });
    if (token) {
      const payload = JSON.parse(atob(token.split('.')[1]));
      console.log("\n\n🔥 ================================= 🔥");
      console.log("🔥 NEXT.JS SERVER - JWT PAYLOAD:");
      console.log("ISS (Issuer):", payload.iss);
      console.log("AUD (Audience):", payload.aud);
      console.log("🔥 ================================= 🔥\n\n");
    } else {
      console.log("\n\n🔥 NO 'convex' TOKEN FOUND! The Clerk JWT Template doesn't exist! 🔥\n\n");
    }
  } catch (e) {
    // Ignore auth errors during build
  }

  return (
    <html lang="en" suppressHydrationWarning>
      <body className="bg-linear-to-br from-gray-950 via-zinc-900 to-stone-900 text-white">
        <ThemeProvider
          attribute="class"
          defaultTheme="dark"
          enableSystem
          disableTransitionOnChange
        >
          <ClerkProvider appearance={{ baseTheme: dark }}>
            <ConvexClientProvider>
              <Header />

              <main className="relative min-h-screen container mx-auto pt-40 md:pt-32">
                {/* Background glow effects (behind everything) */}
                <div className="pointer-events-none absolute inset-0 -z-10 overflow-hidden">
                  <div className="absolute top-0 left-1/4 w-96 h-96 bg-indigo-600/20 rounded-full blur-3xl animate-pulse" />
                  <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-purple-600/20 rounded-full blur-3xl" />
                  <div className="absolute top-1/2 left-1/2 w-[500px] h-[500px] bg-pink-600/10 rounded-full blur-[100px] transform -translate-x-1/2 -translate-y-1/2" />
                </div>

                {/* Page content (above glow) */}
                <div className="relative z-10">{children}</div>
                <Footer />
              </main>
              <Toaster position="top-center" richColors />
            </ConvexClientProvider>
          </ClerkProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
