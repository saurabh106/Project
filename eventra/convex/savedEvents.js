import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

export const toggleSave = mutation({
  args: { eventId: v.id("events") },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Unauthenticated");

    const user = await ctx.db
      .query("users")
      .withIndex("by_token", (q) => q.eq("tokenIdentifier", identity.subject))
      .first();

    if (!user) throw new Error("User not found");

    const existingSave = await ctx.db
      .query("savedEvents")
      .withIndex("by_user_event", (q) =>
        q.eq("userId", user._id).eq("eventId", args.eventId)
      )
      .first();

    if (existingSave) {
      await ctx.db.delete(existingSave._id);
      return { saved: false };
    } else {
      await ctx.db.insert("savedEvents", {
        userId: user._id,
        eventId: args.eventId,
        savedAt: Date.now(),
      });
      return { saved: true };
    }
  },
});

export const getSavedEvents = query({
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) return [];

    const user = await ctx.db
      .query("users")
      .withIndex("by_token", (q) => q.eq("tokenIdentifier", identity.subject))
      .first();

    if (!user) return [];

    const savedRecords = await ctx.db
      .query("savedEvents")
      .withIndex("by_user", (q) => q.eq("userId", user._id))
      .order("desc")
      .collect();

    const events = await Promise.all(
      savedRecords.map(async (record) => {
        const event = await ctx.db.get(record.eventId);
        return event;
      })
    );

    // Filter out any null events (if an event was deleted)
    return events.filter((e) => e !== null);
  },
});

export const isSaved = query({
  args: { eventId: v.id("events") },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) return false;

    const user = await ctx.db
      .query("users")
      .withIndex("by_token", (q) => q.eq("tokenIdentifier", identity.subject))
      .first();

    if (!user) return false;

    const existingSave = await ctx.db
      .query("savedEvents")
      .withIndex("by_user_event", (q) =>
        q.eq("userId", user._id).eq("eventId", args.eventId)
      )
      .first();

    return !!existingSave;
  },
});
