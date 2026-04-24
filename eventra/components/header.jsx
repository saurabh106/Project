"use client";

import React, { useState } from "react";
import Link from "next/link";
import { Building, Crown, Plus, Sparkles, Ticket, Bookmark } from "lucide-react";
import { SignInButton, useAuth, UserButton, SignedIn, SignedOut } from "@clerk/nextjs";
import { BarLoader } from "react-spinners";
import { useStoreUser } from "@/hooks/use-store-user";
import { useOnboarding } from "@/hooks/use-onboarding";
import OnboardingModal from "./onboarding-modal";
import SearchLocationBar from "./search-location-bar";
import { Button } from "@/components/ui/button";
import Image from "next/image";
import UpgradeModal from "./upgrade-modal";
import { Badge } from "./ui/badge";

export default function Header() {
  const [showUpgradeModal, setShowUpgradeModal] = useState(false);

  const { isLoading } = useStoreUser();
  const { showOnboarding, handleOnboardingComplete, handleOnboardingSkip } =
    useOnboarding();

  const { has } = useAuth();
  const hasPro = has?.({ plan: "pro" });

  return (
    <>
      <nav className="fixed top-4 left-4 right-4 md:left-1/2 md:-translate-x-1/2 md:w-[95%] max-w-7xl glass-panel z-50 rounded-full transition-all duration-300">
        <div className="px-6 py-3 flex items-center justify-between">
          {/* Logo */}
          <Link href="/" className="flex items-center">
            <div className="flex items-center gap-2">
              <Sparkles className="w-6 h-6 text-indigo-400" />
              <span className="font-extrabold text-2xl tracking-tight bg-clip-text text-transparent bg-linear-to-r from-indigo-400 via-purple-400 to-pink-400">
                Eventra
              </span>
            </div>
            {hasPro && (
              <Badge className="bg-linear-to-r from-pink-500 to-orange-500 gap-1 text-white ml-3 shadow-lg shadow-pink-500/20">
                <Crown className="w-3 h-3" />
                Pro
              </Badge>
            )}
          </Link>

          {/* Search & Location - Desktop Only */}
          <div className="hidden md:flex flex-1 justify-center">
            <SearchLocationBar />
          </div>

          {/* Right Side Actions */}
          <div className="flex items-center">
            {/* Show Pro badge or Upgrade button */}
            {!hasPro && (
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setShowUpgradeModal(true)}
              >
                Pricing
              </Button>
            )}

            <Button variant="ghost" size="sm" asChild className={"mr-2"}>
              <Link href="/explore">Explore</Link>
            </Button>

            <SignedIn>
              {/* Create Event Button */}
              <Button size="sm" asChild className="flex gap-2 mr-4 bg-indigo-600 hover:bg-indigo-700 text-white border-0 shadow-md shadow-indigo-500/20">
                <Link href="/create-event">
                  <Plus className="w-4 h-4" />
                  <span className="hidden sm:inline">Create Event</span>
                </Link>
              </Button>

              {/* User Button */}
              <UserButton
                afterSignOutUrl="/"
                appearance={{
                  elements: {
                    avatarBox: "w-9 h-9 border border-white/20",
                  },
                }}
              >
                <UserButton.MenuItems>
                  <UserButton.Link
                    label="My Tickets"
                    labelIcon={<Ticket size={16} />}
                    href="/my-tickets"
                  />
                  <UserButton.Link
                    label="My Events"
                    labelIcon={<Building size={16} />}
                    href="/my-events"
                  />
                  <UserButton.Link
                    label="Saved Events"
                    labelIcon={<Bookmark size={16} />}
                    href="/saved-events"
                  />
                  <UserButton.Action label="manageAccount" />
                </UserButton.MenuItems>
              </UserButton>
            </SignedIn>

            <SignedOut>
              <SignInButton mode="modal">
                <Button size="sm" className="bg-indigo-600 hover:bg-indigo-700 text-white border-0 shadow-lg shadow-indigo-500/20">Sign In</Button>
              </SignInButton>
            </SignedOut>
          </div>
        </div>

        {/* Mobile Search & Location - Below Header */}
        <div className="md:hidden px-4 pb-4">
          <SearchLocationBar />
        </div>

        {isLoading && (
          <div className="absolute bottom-0 left-0 w-full">
            <BarLoader width={"100%"} color="#a855f7" />
          </div>
        )}
      </nav>

      {/* Onboarding Modal */}
      <OnboardingModal
        isOpen={showOnboarding}
        onClose={handleOnboardingSkip}
        onComplete={handleOnboardingComplete}
      />

      <UpgradeModal
        isOpen={showUpgradeModal}
        onClose={() => setShowUpgradeModal(false)}
        trigger="header"
      />
    </>
  );
}
