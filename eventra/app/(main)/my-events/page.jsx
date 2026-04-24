"use client";

import { useRouter } from "next/navigation";
import { Plus, Loader2 } from "lucide-react";
import Link from "next/link";
import { useConvexQuery, useConvexMutation } from "@/hooks/use-convex-query";
import { api } from "@/convex/_generated/api";
import { toast } from "sonner";
import { useAuth } from "@clerk/nextjs";

import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import EventCard from "@/components/event-card";

export default function MyEventsPage() {
  const router = useRouter();
  const { userId } = useAuth();

  const { data: events, isLoading } = useConvexQuery(api.events.getMyEvents, { clerkUserId: userId || "" });
  const { mutate: deleteEvent } = useConvexMutation(api.events.deleteEvent);

  const handleDelete = async (eventId) => {
    const confirmed = window.confirm(
      "Are you sure you want to delete this event? This action cannot be undone and will permanently delete the event and all associated registrations."
    );

    if (!confirmed) return;

    try {
      await deleteEvent({ eventId, clerkUserId: userId || "" });
      toast.success("Event deleted successfully");
    } catch (error) {
      toast.error(error.message || "Failed to delete event");
    }
  };

  // Navigate to event dashboard instead of event detail
  const handleEventClick = (eventId) => {
    router.push(`/my-events/${eventId}`);
  };

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="w-8 h-8 animate-spin text-purple-500" />
      </div>
    );
  }

  return (
    <div className="min-h-screen pb-20 px-4">
      <div className="max-w-7xl mx-auto">
        <div className="flex items-center justify-between mb-10 border-b border-white/10 pb-6">
          <div>
            <h1 className="text-4xl md:text-5xl font-extrabold mb-3 tracking-tight bg-clip-text text-transparent bg-linear-to-r from-indigo-400 to-pink-500">
              My Events
            </h1>
            <p className="text-zinc-400 font-light text-lg">Manage and track your hosted experiences</p>
          </div>
        </div>

        {events?.length === 0 ? (
          <Card className="p-16 text-center bg-white/5 border-white/10 backdrop-blur-md shadow-2xl relative overflow-hidden group">
            <div className="absolute inset-0 bg-linear-to-tr from-indigo-500/10 via-transparent to-pink-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
            <div className="max-w-md mx-auto space-y-6 relative z-10">
              <div className="text-7xl mb-6 transform group-hover:scale-110 transition-transform duration-500">✨</div>
              <h2 className="text-3xl font-bold tracking-tight">No events yet</h2>
              <p className="text-zinc-400 font-light leading-relaxed">
                Create your first event and start managing attendees like a pro.
              </p>
              <Button asChild className="gap-2 mt-4 bg-linear-to-r from-indigo-500 to-purple-600 hover:from-indigo-600 hover:to-purple-700 border-0 shadow-lg shadow-indigo-500/25">
                <Link href="/create-event">
                  <Plus className="w-5 h-5" />
                  Create Your First Event
                </Link>
              </Button>
            </div>
          </Card>
        ) : (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {events?.map((event) => (
              <EventCard
                key={event._id}
                event={event}
                action="event"
                onClick={() => handleEventClick(event._id)}
                onDelete={handleDelete}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
