import React from "react";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import Link from "next/link";

export default function LandingPage() {
  return (
    <div className="relative overflow-hidden w-full min-h-screen flex flex-col justify-center">
      {/* Dynamic Background Noise */}
      <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-20 mix-blend-overlay z-0 pointer-events-none" />

      {/* Hero Section */}
      <section className="relative z-10 px-6 pt-20 pb-32 w-full max-w-7xl mx-auto flex flex-col lg:flex-row items-center gap-16">
        
        {/* Left Content */}
        <div className="flex-1 flex flex-col items-start justify-center text-left">
          
          {/* Status Pill */}
          <div className="mb-8 inline-flex items-center gap-3 px-5 py-2.5 rounded-full bg-zinc-950/40 border border-white/10 backdrop-blur-xl shadow-2xl hover:bg-white/5 transition-all cursor-pointer group">
            <span className="relative flex h-3 w-3">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
              <span className="relative inline-flex rounded-full h-3 w-3 bg-primary"></span>
            </span>
            <span className="text-zinc-300 font-medium tracking-wide text-sm group-hover:text-white transition-colors">
              The Next Generation of Events
            </span>
            <span className="text-zinc-500 group-hover:translate-x-1 transition-transform">→</span>
          </div>

          {/* Epic Headline */}
          <h1 className="text-5xl sm:text-6xl lg:text-[5.5rem] font-bold mb-6 leading-[1.05] tracking-tight text-white drop-shadow-sm">
            Where <br/>
            Moments <br/>
            Become <br/>
            <span className="text-zinc-400">
              Legendary.
            </span>
          </h1>

          {/* Description */}
          <p className="text-xl sm:text-2xl text-zinc-400 mb-12 max-w-xl font-light leading-relaxed">
            Eventra is the ultra-premium platform to discover, curate, and host spectacular experiences. Built for those who refuse to settle for ordinary.
          </p>

          {/* CTA Buttons */}
          <div className="flex flex-col sm:flex-row gap-4 w-full sm:w-auto">
            <Link href="/explore" className="w-full sm:w-auto">
              <Button size="lg" className="w-full sm:w-auto py-6 px-8 text-base rounded-full font-semibold bg-white text-black hover:bg-zinc-200 transition-all">
                Explore Experiences
              </Button>
            </Link>
            <Link href="/create-event" className="w-full sm:w-auto">
              <Button size="lg" variant="outline" className="w-full sm:w-auto py-6 px-8 text-base rounded-full font-semibold bg-zinc-950/50 border-zinc-800 hover:bg-zinc-900 transition-all text-white">
                Host an Event
              </Button>
            </Link>
          </div>
          
          {/* Trust Metrics */}
          <div className="mt-16 flex items-center gap-8 border-t border-white/10 pt-8 w-full">
            <div>
              <p className="text-3xl font-bold text-white">10k+</p>
              <p className="text-sm text-zinc-500 uppercase tracking-wider font-semibold mt-1">Events Hosted</p>
            </div>
            <div className="w-px h-12 bg-white/10"></div>
            <div>
              <p className="text-3xl font-bold text-white">2.5m</p>
              <p className="text-sm text-zinc-500 uppercase tracking-wider font-semibold mt-1">Tickets Sold</p>
            </div>
          </div>

        </div>

        {/* Right Content - Stunning Imagery */}
        <div className="flex-1 w-full relative perspective-1000 mt-12 lg:mt-0">
          
          <div className="relative w-full aspect-[4/5] lg:aspect-square transform-gpu rotate-y-[-5deg] rotate-x-[2deg] hover:rotate-y-0 hover:rotate-x-0 transition-transform duration-1000 ease-out group">
            
            {/* Main Image */}
            <div className="absolute inset-0 overflow-hidden rounded-3xl border border-white/10 shadow-[0_20px_100px_-20px_rgba(0,0,0,0.5)]">
              <Image
                src="https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=2000"
                alt="Premium Event Experience"
                fill
                unoptimized
                className="object-cover transition-transform duration-[20s] ease-linear group-hover:scale-110 opacity-90"
                priority
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent pointer-events-none" />
            </div>

            {/* Floating Glassmorphic Cards */}
            <div className="absolute -left-12 bottom-20 w-72 glass-panel p-6 rounded-3xl animate-float" style={{ animationDelay: '0s' }}>
              <div className="flex items-center gap-4 mb-4">
                <div className="w-12 h-12 rounded-full bg-gradient-to-br from-pink-500 to-orange-400 flex items-center justify-center text-xl shadow-lg">🎫</div>
                <div>
                  <p className="text-white font-bold text-lg">VIP Pass Sold</p>
                  <p className="text-zinc-400 text-sm">Just now</p>
                </div>
              </div>
              <div className="h-2 w-full bg-white/10 rounded-full overflow-hidden">
                <div className="h-full w-3/4 bg-gradient-to-r from-primary to-accent rounded-full"></div>
              </div>
            </div>

            <div className="absolute -right-8 top-20 w-64 glass-panel p-5 rounded-3xl animate-float" style={{ animationDelay: '2s' }}>
              <div className="flex items-center gap-4">
                <div className="flex -space-x-4">
                  {[1, 2, 3].map((i) => (
                    <img key={i} src={`https://i.pravatar.cc/100?img=${i + 10}`} alt="User" className="w-10 h-10 rounded-full border-2 border-zinc-900" />
                  ))}
                </div>
                <p className="text-white font-semibold">+402 joined</p>
              </div>
            </div>
          </div>
        </div>

      </section>
    </div>
  );
}
