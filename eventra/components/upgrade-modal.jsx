"use client";

import { Sparkles } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";

export default function UpgradeModal({ isOpen, onClose, trigger = "limit" }) {
  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-2xl">
        <DialogHeader>
          <div className="flex items-center gap-2 mb-2">
            <Sparkles className="w-6 h-6 text-purple-500" />
            <DialogTitle className="text-2xl">Upgrade to Pro</DialogTitle>
          </div>
          <DialogDescription>
            {trigger === "header" && "Create Unlimited Events with Pro! "}
            {trigger === "limit" && "You've reached your free event limit. "}
            {trigger === "color" && "Custom theme colors are a Pro feature. "}
            Unlock unlimited events and premium features!
          </DialogDescription>
        </DialogHeader>

        {/* Custom Pricing UI Mockup */}
        <div className="bg-zinc-950/40 backdrop-blur-md border border-indigo-500/30 rounded-xl p-6 my-4 shadow-[0_0_30px_rgba(99,102,241,0.15)] relative overflow-hidden">
          <div className="absolute top-0 right-0 w-32 h-32 bg-indigo-500/20 rounded-full blur-3xl" />
          <div className="flex justify-between items-center mb-6 relative z-10">
            <div>
              <h3 className="text-2xl font-bold text-white mb-1">Eventra Pro</h3>
              <p className="text-sm text-zinc-400">Everything you need to host incredible events.</p>
            </div>
            <div className="text-right">
              <span className="text-4xl font-extrabold text-transparent bg-clip-text bg-linear-to-r from-indigo-400 to-pink-500">$9</span>
              <span className="text-zinc-500 text-sm">/mo</span>
            </div>
          </div>
          <ul className="space-y-3 mb-6 text-sm text-zinc-300 relative z-10">
            <li className="flex items-center gap-2"><div className="w-4 h-4 rounded-full bg-indigo-500/20 flex items-center justify-center text-indigo-400">✓</div> Unlimited active events</li>
            <li className="flex items-center gap-2"><div className="w-4 h-4 rounded-full bg-indigo-500/20 flex items-center justify-center text-indigo-400">✓</div> Custom premium theme colors</li>
            <li className="flex items-center gap-2"><div className="w-4 h-4 rounded-full bg-indigo-500/20 flex items-center justify-center text-indigo-400">✓</div> Priority AI event generation</li>
          </ul>
          <Button className="w-full bg-indigo-600 hover:bg-indigo-700 text-white border-0 shadow-lg shadow-indigo-500/20 relative z-10">
            Enable in Clerk Dashboard
          </Button>
        </div>

        {/* Footer */}
        <div className="flex gap-3">
          <Button variant="outline" onClick={onClose} className="flex-1">
            Maybe Later
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
