"use client";

import { Calendar, MapPin, Users, Trash2, X, QrCode, Eye, Bookmark } from "lucide-react";
import { format } from "date-fns";
import Image from "next/image";
import { getCategoryIcon, getCategoryLabel } from "@/lib/data";
import { useConvexQuery, useConvexMutation } from "@/hooks/use-convex-query";
import { api } from "@/convex/_generated/api";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";

export default function EventCard({
  event,
  onClick,
  onDelete,
  variant = "grid", // "grid" or "list"
  action = null, // "event" | "ticket" | null
  className = "",
}) {
  const isSaved = useConvexQuery(api.savedEvents.isSaved, { eventId: event._id });
  const toggleSave = useConvexMutation(api.savedEvents.toggleSave);

  const handleSaveToggle = async (e) => {
    e.stopPropagation();
    try {
      const result = await toggleSave({ eventId: event._id });
      if (result.saved) {
        toast.success("Event saved to your bookmarks!");
      } else {
        toast.success("Event removed from bookmarks.");
      }
    } catch (err) {
      toast.error("You need to be logged in to save events.");
    }
  };

  // List variant (compact horizontal layout)
  if (variant === "list") {
    return (
      <Card
        className={`py-0 group cursor-pointer hover:shadow-[0_0_30px_rgba(99,102,241,0.15)] transition-all duration-500 hover:border-indigo-500/40 bg-zinc-950/40 backdrop-blur-xl border-white/5 overflow-hidden ${className}`}
        onClick={onClick}
      >
        <div className="absolute inset-0 bg-linear-to-r from-indigo-500/0 via-indigo-500/0 to-pink-500/0 group-hover:from-indigo-500/10 group-hover:to-pink-500/10 transition-colors duration-500" />
        <CardContent className="p-3 flex gap-4 relative z-10">
          {/* Event Image */}
          <div className="w-24 h-24 rounded-xl shrink-0 overflow-hidden relative shadow-lg shadow-black/40 border border-white/10">
            {event.coverImage ? (
              <Image
                src={event.coverImage}
                alt={event.title}
                fill
                className="object-cover group-hover:scale-110 transition-transform duration-700 ease-out"
              />
            ) : (
              <div
                className="absolute inset-0 flex items-center justify-center text-4xl group-hover:scale-110 transition-transform duration-700"
                style={{ backgroundColor: event.themeColor }}
              >
                {getCategoryIcon(event.category)}
              </div>
            )}
          </div>

          {/* Event Details */}
          <div className="flex-1 min-w-0 flex flex-col justify-center">
            <h3 className="font-bold text-base mb-1 group-hover:text-indigo-400 transition-colors duration-300 line-clamp-2 leading-tight">
              {event.title}
            </h3>
            <p className="text-xs font-medium text-indigo-300/80 mb-2">
              {format(event.startDate, "EEE, dd MMM, HH:mm")}
            </p>
            <div className="flex items-center gap-1.5 text-xs text-zinc-400 mb-1.5 font-light">
              <MapPin className="w-3.5 h-3.5 text-zinc-500" />
              <span className="line-clamp-1">
                {event.locationType === "online" ? "Online Event" : event.city}
              </span>
            </div>
            <div className="flex items-center gap-1.5 text-xs text-zinc-400 font-light">
              <Users className="w-3.5 h-3.5 text-zinc-500" />
              <span>{event.registrationCount} attending</span>
            </div>
          </div>
        </CardContent>
      </Card>
    );
  }

  // Grid variant (default - original design)
  return (
    <Card
      className={`overflow-hidden group pt-0 bg-zinc-950/40 backdrop-blur-xl border-white/5 hover:border-indigo-500/40 ${onClick ? "cursor-pointer hover:shadow-[0_0_40px_rgba(99,102,241,0.15)] hover:-translate-y-2 transition-all duration-500" : ""} ${className}`}
      onClick={onClick}
    >
      <div className="relative h-56 overflow-hidden">
        <div className="absolute inset-0 bg-linear-to-t from-zinc-950/80 via-transparent to-transparent z-10" />
        {event.coverImage ? (
          <Image
            src={event.coverImage}
            alt={event.title}
            className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-700 ease-out"
            width={500}
            height={224}
            priority
          />
        ) : (
          <div
            className="w-full h-full flex items-center justify-center text-5xl group-hover:scale-110 transition-transform duration-700"
            style={{ backgroundColor: event.themeColor }}
          >
            {getCategoryIcon(event.category)}
          </div>
        )}
        <div className="absolute top-4 right-4 z-20 flex flex-col gap-2">
          <button 
            onClick={handleSaveToggle}
            className={`w-8 h-8 rounded-full flex items-center justify-center backdrop-blur-md border transition-all duration-300 ${isSaved ? 'bg-indigo-500/80 border-indigo-400 text-white shadow-[0_0_15px_rgba(99,102,241,0.5)]' : 'bg-zinc-950/60 border-white/10 text-white/70 hover:bg-zinc-950/80 hover:text-white hover:scale-110'}`}
          >
            <Bookmark className={`w-4 h-4 ${isSaved ? 'fill-current' : ''}`} />
          </button>
          <Badge className="bg-zinc-950/80 backdrop-blur-md border border-white/10 text-white font-semibold shadow-lg">
            {event.ticketType === "free" ? "Free" : "Paid"}
          </Badge>
        </div>
      </div>

      <CardContent className="space-y-4 p-6 relative">
        <div className="absolute top-0 right-0 w-32 h-32 bg-indigo-500/10 rounded-full blur-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
        
        <div>
          <Badge variant="outline" className="mb-3 border-white/10 bg-white/5 backdrop-blur-sm">
            {getCategoryIcon(event.category)} {getCategoryLabel(event.category)}
          </Badge>
          <h3 className="font-bold text-xl line-clamp-2 group-hover:text-indigo-400 transition-colors duration-300 leading-tight">
            {event.title}
          </h3>
        </div>

        <div className="space-y-2.5 text-sm text-zinc-400 font-light">
          <div className="flex items-center gap-2.5">
            <Calendar className="w-4 h-4 text-indigo-400/80" />
            <span className="font-medium text-zinc-300">{format(event.startDate, "PPP")}</span>
          </div>
          <div className="flex items-center gap-2.5">
            <MapPin className="w-4 h-4 text-indigo-400/80" />
            <span className="line-clamp-1">
              {event.locationType === "online"
                ? "Online Event"
                : `${event.city}, ${event.state || event.country}`}
            </span>
          </div>
          <div className="flex items-center gap-2.5">
            <Users className="w-4 h-4 text-indigo-400/80" />
            <span>
              <span className="text-zinc-300 font-medium">{event.registrationCount}</span> / {event.capacity} registered
            </span>
          </div>
        </div>

        {action && (
          <div className="flex gap-3 pt-3 mt-2 border-t border-white/5 relative z-10">
            {/* Primary button */}
            <Button
              variant="outline"
              size="sm"
              className="flex-1 gap-2 bg-white/5 border-white/10 hover:bg-white/10 hover:text-white transition-colors"
              onClick={(e) => {
                e.stopPropagation();
                onClick?.(e);
              }}
            >
              {action === "event" ? (
                <>
                  <Eye className="w-4 h-4" />
                  View
                </>
              ) : (
                <>
                  <QrCode className="w-4 h-4" />
                  Ticket
                </>
              )}
            </Button>

            {/* Secondary button - delete / cancel */}
            {onDelete && (
              <Button
                variant="outline"
                size="sm"
                className="gap-2 text-red-400 border-white/10 hover:text-red-300 hover:bg-red-500/20 hover:border-red-500/30 transition-colors"
                onClick={(e) => {
                  e.stopPropagation();
                  onDelete(event._id);
                }}
              >
                {action === "event" ? (
                  <Trash2 className="w-4 h-4" />
                ) : (
                  <X className="w-4 h-4" />
                )}
              </Button>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
