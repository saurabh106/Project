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
      <body className="bg-background text-foreground overflow-x-hidden min-h-screen selection:bg-primary/30 selection:text-primary-foreground font-sans antialiased">
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
                {/* Subtle, mature background gradients */}
                <div className="fixed inset-0 -z-10 overflow-hidden pointer-events-none bg-[#0a0a0a]">
                  <div className="absolute top-[-20%] left-[-10%] w-[50%] h-[50%] bg-indigo-900/10 rounded-full blur-[120px] mix-blend-screen" />
                  <div className="absolute bottom-[-20%] right-[-10%] w-[50%] h-[50%] bg-blue-900/10 rounded-full blur-[150px] mix-blend-screen" />
                  <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-[0.03] mix-blend-overlay" />
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
