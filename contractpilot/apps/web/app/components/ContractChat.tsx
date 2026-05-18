"use client";

import React, { useState, useRef, useEffect } from "react";
import { useAuth } from "@clerk/nextjs";
import { Send, User, Bot, Loader2, X } from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";

interface Message {
  role: "user" | "model";
  content: string;
}

export function ContractChat({ contractId }: { contractId: string }) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const { getToken } = useAuth();
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const handleSend = async () => {
    if (!input.trim() || loading) return;

    const userMessage = input.trim();
    setInput("");
    setMessages((prev) => [...prev, { role: "user", content: userMessage }]);
    setLoading(true);

    try {
      const token = await getToken();
      const response = await fetch(`http://localhost:4000/api/contracts/${contractId}/chat`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          message: userMessage,
          history: messages.map(m => ({
            role: m.role,
            parts: [{ text: m.content }]
          })),
        }),
      });

      const data = await response.json();
      if (response.ok) {
        setMessages((prev) => [...prev, { role: "model", content: data.answer }]);
      } else {
        setMessages((prev) => [...prev, { role: "model", content: "Sorry, I couldn't process that. Please try again." }]);
      }
    } catch (error) {
      console.error("Chat error:", error);
      setMessages((prev) => [...prev, { role: "model", content: "Connection error. Is the backend running?" }]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card className="flex flex-col h-[600px] border-white/5 bg-slate-900/50 backdrop-blur-xl shadow-2xl overflow-hidden rounded-3xl">
      <CardHeader className="border-b border-white/5 bg-slate-950/30 py-4 px-6">
        <CardTitle className="text-xs font-black uppercase tracking-widest flex items-center gap-3 text-slate-400">
          <div className="w-2 h-2 rounded-full bg-blue-500 shadow-[0_0_10px_rgba(59,130,246,0.5)] animate-pulse" />
          Intelligence Terminal
        </CardTitle>
      </CardHeader>
      
      <CardContent className="flex-1 overflow-y-auto p-6 space-y-6" ref={scrollRef}>
        {messages.length === 0 && (
          <div className="text-center py-12">
            <div className="w-16 h-16 rounded-3xl bg-blue-600/10 flex items-center justify-center text-blue-500 mx-auto mb-4 border border-blue-500/20">
              <Bot size={32} />
            </div>
            <p className="text-sm font-bold text-white tracking-tight">AI Contract Assistant Active</p>
            <p className="text-[10px] text-slate-500 mt-1 uppercase font-black tracking-widest">Inquire regarding liabilities or terms</p>
          </div>
        )}
        
        {messages.map((msg, i) => (
          <div key={i} className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'} animate-in fade-in slide-in-from-bottom-2 duration-300`}>
            <div className={`max-w-[85%] rounded-3xl px-5 py-3 text-sm ${
              msg.role === 'user' 
                ? 'bg-blue-600 text-white rounded-tr-none shadow-lg shadow-blue-500/10 font-bold' 
                : 'bg-slate-800 text-slate-200 rounded-tl-none border border-white/5 font-medium'
            }`}>
              <p className="leading-relaxed">{msg.content}</p>
            </div>
          </div>
        ))}
        
        {loading && (
          <div className="flex justify-start">
            <div className="bg-slate-800 border border-white/5 rounded-3xl rounded-tl-none px-5 py-3">
              <Loader2 size={18} className="animate-spin text-blue-400" />
            </div>
          </div>
        )}
      </CardContent>

      <div className="p-6 bg-slate-950/30 border-t border-white/5">
        <div className="relative flex items-center group">
          <input
            type="text"
            placeholder="Query contract intelligence..."
            className="w-full bg-slate-900 border border-white/5 rounded-2xl pl-5 pr-14 py-4 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all text-white placeholder:text-slate-600"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSend()}
          />
          <button 
            onClick={handleSend}
            disabled={!input.trim() || loading}
            className="absolute right-2 p-3 bg-blue-600 text-white rounded-xl hover:bg-blue-500 disabled:opacity-30 disabled:hover:bg-blue-600 transition-all shadow-lg active:scale-95"
          >
            <Send size={18} />
          </button>
        </div>
      </div>
    </Card>
  );
}
