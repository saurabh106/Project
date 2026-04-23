"use client";

import { useRef } from "react";
import { useRouter } from "next/navigation";
import { Calendar, MapPin, Users, ArrowRight, Loader2 } from "lucide-react";
import { format } from "date-fns";
import { useConvexQuery } from "@/hooks/use-convex-query";
import { api } from "@/convex/_generated/api";
import { createLocationSlug } from "@/lib/location-utils";
import Image from "next/image";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from "@/components/ui/carousel";
import { CATEGORIES } from "@/lib/data";
import Autoplay from "embla-carousel-autoplay";
import EventCard from "@/components/event-card";

export default function ExplorePage() {
  const router = useRouter();
  const plugin = useRef(Autoplay({ delay: 2000, stopOnInteraction: true }));

  // Fetch current user for location
  const { data: currentUser } = useConvexQuery(api.users.getCurrentUser);

  // Fetch events
  const { data: featuredEvents, isLoading: loadingFeatured } = useConvexQuery(
    api.explore.getFeaturedEvents,
    { limit: 3 }
  );

  const { data: localEvents, isLoading: loadingLocal } = useConvexQuery(
    api.explore.getEventsByLocation,
    {
      city: currentUser?.location?.city || "Gurugram",
      state: currentUser?.location?.state || "Haryana",
      limit: 4,
    }
  );

  const { data: popularEvents, isLoading: loadingPopular } = useConvexQuery(
    api.explore.getPopularEvents,
    { limit: 6 }
  );

  const { data: categoryCounts } = useConvexQuery(
    api.explore.getCategoryCounts
  );

  const handleEventClick = (slug) => {
    router.push(`/events/${slug}`);
  };

  const handleCategoryClick = (categoryId) => {
    router.push(`/explore/${categoryId}`);
  };

  const handleViewLocalEvents = () => {
    const city = currentUser?.location?.city || "Gurugram";
    const state = currentUser?.location?.state || "Haryana";
    const slug = createLocationSlug(city, state);
    router.push(`/explore/${slug}`);
  };

  // Format categories with counts
  const categoriesWithCounts = CATEGORIES.map((cat) => ({
    ...cat,
    count: categoryCounts?.[cat.id] || 0,
  }));

  // Loading state
  const isLoading = loadingFeatured || loadingLocal || loadingPopular;

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="w-8 h-8 animate-spin text-purple-500" />
      </div>
    );
  }

  return (
    <>
      {/* Hero Title */}
      <div className="pb-16 text-center pt-8">
        <h1 className="text-5xl md:text-7xl font-extrabold mb-6 tracking-tight">
          Explore{" "}
          <span className="bg-linear-to-r from-indigo-400 via-purple-400 to-pink-500 bg-clip-text text-transparent">
            Experiences
          </span>
        </h1>
        <p className="text-lg md:text-xl text-zinc-400 max-w-2xl mx-auto font-light leading-relaxed">
          Discover handpicked events, explore your local scene, or browse what&apos;s trending across the globe.
        </p>
      </div>

      {/* Featured Carousel */}
      {featuredEvents && featuredEvents.length > 0 && (
        <div className="mb-16">
          <Carousel
            plugins={[plugin.current]}
            className="w-full"
            onMouseEnter={plugin.current.stop}
            onMouseLeave={plugin.current.reset}
          >
            <CarouselContent>
              {featuredEvents.map((event) => (
                <CarouselItem key={event._id}>
                  <div
                    className="relative h-[400px] rounded-xl overflow-hidden cursor-pointer"
                    onClick={() => handleEventClick(event.slug)}
                  >
                    {event.coverImage ? (
                      <Image
                        src={event.coverImage}
                        alt={event.title}
                        fill
                        className="object-cover"
                        priority
                      />
                    ) : (
                      <div
                        className="absolute inset-0"
                        style={{ backgroundColor: event.themeColor }}
                      />
                    )}
                    <div className="absolute inset-0 bg-gradient-to-r from-black/60 to-black/30" />
                    <div className="relative h-full flex flex-col justify-end p-8 md:p-12">
                      <Badge className="w-fit mb-4" variant="secondary">
                        {event.city}, {event.state || event.country}
                      </Badge>
                      <h2 className="text-3xl md:text-5xl font-bold mb-3 text-white">
                        {event.title}
                      </h2>
                      <p className="text-lg text-white/90 mb-4 max-w-2xl line-clamp-2">
                        {event.description}
                      </p>
                      <div className="flex items-center gap-4 text-white/80">
                        <div className="flex items-center gap-2">
                          <Calendar className="w-4 h-4" />
                          <span className="text-sm">
                            {format(event.startDate, "PPP")}
                          </span>
                        </div>
                        <div className="flex items-center gap-2">
                          <MapPin className="w-4 h-4" />
                          <span className="text-sm">{event.city}</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <Users className="w-4 h-4" />
                          <span className="text-sm">
                            {event.registrationCount} registered
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                </CarouselItem>
              ))}
            </CarouselContent>
            <CarouselPrevious className="left-4" />
            <CarouselNext className="right-4" />
          </Carousel>
        </div>
      )}

      {/* Local Events */}
      {localEvents && localEvents.length > 0 && (
        <div className="mb-16">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-3xl font-bold mb-1">Events Near You</h2>
              <p className="text-muted-foreground">
                Happening in {currentUser?.location?.city || "your area"}
              </p>
            </div>
            <Button
              variant="outline"
              className="gap-2"
              onClick={handleViewLocalEvents}
            >
              View All <ArrowRight className="w-4 h-4" />
            </Button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {localEvents.map((event) => (
              <EventCard
                key={event._id}
                event={event}
                variant="compact"
                onClick={() => handleEventClick(event.slug)}
              />
            ))}
          </div>
        </div>
      )}

      {/* Browse by Category */}
      <div className="mb-20">
        <h2 className="text-3xl font-bold mb-8">Browse by Category</h2>

        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-4 gap-5">
          {categoriesWithCounts.map((category) => (
            <Card
              key={category.id}
              className="py-0 group cursor-pointer hover:shadow-[0_0_30px_rgba(168,85,247,0.15)] hover:-translate-y-2 transition-all duration-500 bg-zinc-950/50 backdrop-blur-lg border-white/5 overflow-hidden"
              onClick={() => handleCategoryClick(category.id)}
            >
              <div className="absolute inset-0 bg-linear-to-br from-white/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
              <CardContent className="px-5 py-6 sm:p-8 flex flex-col items-center text-center gap-4 relative z-10">
                <div className="text-4xl sm:text-5xl transform group-hover:scale-110 transition-transform duration-500 drop-shadow-2xl">
                  {category.icon}
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-bold text-lg mb-1 group-hover:text-indigo-400 transition-colors duration-300 tracking-wide">
                    {category.label}
                  </h3>
                  <p className="text-sm text-zinc-500 font-medium bg-white/5 inline-block px-3 py-1 rounded-full border border-white/5">
                    {category.count} Event{category.count !== 1 ? "s" : ""}
                  </p>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Popular Events Across Country */}
      {popularEvents && popularEvents.length > 0 && (
        <div className="mb-16">
          <div className="mb-6">
            <h2 className="text-3xl font-bold mb-1">Popular Across India</h2>
            <p className="text-muted-foreground">Trending events nationwide</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {popularEvents.map((event) => (
              <EventCard
                key={event._id}
                event={event}
                variant="list"
                onClick={() => handleEventClick(event.slug)}
              />
            ))}
          </div>
        </div>
      )}

      {/* Empty State */}
      {!loadingFeatured &&
        !loadingLocal &&
        !loadingPopular &&
        (!featuredEvents || featuredEvents.length === 0) &&
        (!localEvents || localEvents.length === 0) &&
        (!popularEvents || popularEvents.length === 0) && (
          <Card className="p-12 text-center">
            <div className="max-w-md mx-auto space-y-4">
              <div className="text-6xl mb-4">🎉</div>
              <h2 className="text-2xl font-bold">No events yet</h2>
              <p className="text-muted-foreground">
                Be the first to create an event in your area!
              </p>
              <Button asChild className="gap-2">
                <a href="/create-event">Create Event</a>
              </Button>
            </div>
          </Card>
        )}
    </>
  );
}
