import React from "react";
import Image from "next/image";
import { Button } from "@/components/ui/button";
import Link from "next/link";

export default function LandingPage() {
  return (
    <div>
      {/* Hero Section */}
      <section className="pb-16 relative overflow-hidden">
        <div className="max-w-7xl mx-auto grid lg:grid-cols-2 gap-12 items-center relative z-10">
          {/* Left content */}
          <div className="text-center sm:text-left relative z-10">
            <div className="mb-6 inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/5 border border-white/10 backdrop-blur-md">
              <span className="text-indigo-300 font-medium tracking-wide text-sm flex items-center gap-2">
                <span className="relative flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-indigo-400 opacity-75"></span>
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-indigo-500"></span>
                </span>
                Welcome to Eventra
              </span>
            </div>

            <h1 className="text-5xl sm:text-6xl md:text-7xl font-extrabold mb-6 leading-[1.1] tracking-tight text-white drop-shadow-lg">
              Discover &<br />
              create amazing
              <br />
              <span className="bg-linear-to-r from-indigo-400 via-purple-400 to-pink-500 bg-clip-text text-transparent animate-pulse">
                events.
              </span>
            </h1>

            <p className="text-lg sm:text-xl text-zinc-400 mb-12 max-w-lg font-light leading-relaxed">
              Whether you&apos;re hosting an intimate meetup or a global summit, Eventra makes every moment unforgettable. Join our community today.
            </p>

            <Link href="/explore">
              <Button size="xl" className={"rounded-full"}>
                Get Started
              </Button>
            </Link>
          </div>

          {/* Right - 3D Phone Mockup */}
          <div className="relative block group perspective-1000">
            <div className="absolute inset-0 bg-linear-to-tr from-indigo-500/20 to-purple-500/20 blur-3xl rounded-full transform group-hover:scale-110 transition-transform duration-700 ease-in-out"></div>
            <Image
              src="/hero.png"
              alt="Eventra mockup"
              width={700}
              height={700}
              className="w-full h-auto relative z-10 transform transition-all duration-700 ease-out group-hover:rotate-y-12 group-hover:-translate-y-4 group-hover:scale-[1.02] drop-shadow-2xl"
              priority
            />
            {/* <video
              width="100%"
              height="100%"
              loop
              playsInline
              autoPlay
              muted
              className="w-full h-auto"
            >
              <source
                src="https://cdn.lu.ma/landing/phone-dark.mp4"
                type="video/mp4;codecs=hvc1"
              />
              <source
                src="https://cdn.lu.ma/landing/phone-dark.webm"
                type="video/webm"
              />
            </video> */}
          </div>
        </div>
      </section>
    </div>
  );
}
