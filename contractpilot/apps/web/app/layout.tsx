import type { Metadata } from "next";
import { ClerkProvider, SignInButton, Show, UserButton } from "@clerk/nextjs";
import Link from "next/link";
import localFont from "next/font/local";
import "./globals.css";

const geistSans = localFont({
  src: "./fonts/GeistVF.woff",
  variable: "--font-geist-sans",
});
const geistMono = localFont({
  src: "./fonts/GeistMonoVF.woff",
  variable: "--font-geist-mono",
});

export const metadata: Metadata = {
  title: "Contract Pilot",
  description: "Automate your contract workflows",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <ClerkProvider>
      <html lang="en">
        <body className={`${geistSans.variable} ${geistMono.variable} antialiased`}>
          <header style={{ 
            position: 'sticky', 
            top: 0, 
            zIndex: 50, 
            background: 'rgba(255, 255, 255, 0.8)', 
            backdropFilter: 'blur(10px)',
            borderBottom: '1px solid var(--border)',
            padding: '1rem 0'
          }}>
            <div className="container" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <Link href="/" style={{ fontSize: '1.25rem', fontWeight: 800, color: 'var(--primary)', letterSpacing: '-0.02em' }}>
                ContractPilot
              </Link>
              <nav style={{ display: 'flex', alignItems: 'center', gap: '1.5rem' }}>
                <Show when="signed-out">
                  <SignInButton mode="modal">
                    <button style={{ 
                      padding: '0.625rem 1.25rem', 
                      background: 'var(--primary)', 
                      color: 'white', 
                      borderRadius: '0.5rem', 
                      fontWeight: 600,
                      fontSize: '0.875rem'
                    }}>
                      Sign In
                    </button>
                  </SignInButton>
                </Show>
                <Show when="signed-in">
                  <UserButton />
                </Show>
              </nav>
            </div>
          </header>
          <main>
            {children}
          </main>
        </body>
      </html>
    </ClerkProvider>
  );
}
