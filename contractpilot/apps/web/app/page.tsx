import { SignInButton } from "@clerk/nextjs";
import { auth } from "@clerk/nextjs/server";
import Link from "next/link";
import { 
  Shield, 
  Zap, 
  Bell, 
  ArrowRight, 
  CheckCircle2, 
  ChevronRight, 
  Scale, 
  FileText, 
  Activity, 
  Bot,
  Layers,
  Globe,
  Cpu
} from "lucide-react";
import { Button } from "./components/ui/button";
import { Card, CardContent } from "./components/ui/card";

export default async function LandingPage() {
  const { userId } = await auth();
  const isIdExist = !!userId;

  return (
    <div className="flex flex-col min-h-screen bg-[#020617] text-slate-200">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 border-b border-white/5 bg-[#020617]/80 backdrop-blur-xl">
        <div className="container mx-auto px-6 h-20 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-blue-600 rounded-2xl flex items-center justify-center shadow-lg shadow-blue-500/20">
              <Scale size={24} className="text-white" />
            </div>
            <span className="text-xl font-black tracking-tighter text-white">Pilot</span>
          </div>
          <div className="hidden md:flex items-center gap-10">
            <a href="#features" className="text-sm font-black uppercase tracking-widest text-slate-400 hover:text-blue-400 transition-colors">Features</a>
            <a href="#security" className="text-sm font-black uppercase tracking-widest text-slate-400 hover:text-blue-400 transition-colors">Security</a>
            <a href="#pricing" className="text-sm font-black uppercase tracking-widest text-slate-400 hover:text-blue-400 transition-colors">Enterprise</a>
          </div>
          <div className="flex items-center gap-4">
            {!isIdExist ? (
              <>
                <SignInButton mode="modal">
                  <Button variant="ghost" className="text-sm font-black uppercase tracking-widest text-white hover:bg-white/5">Log In</Button>
                </SignInButton>
                <SignInButton mode="modal">
                  <Button className="rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-black uppercase tracking-widest text-[10px] px-6 py-5 shadow-lg shadow-blue-500/20 border-none">Get Started</Button>
                </SignInButton>
              </>
            ) : (
              <Link href="/dashboard">
                <Button className="rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-black uppercase tracking-widest text-[10px] px-6 py-5 shadow-lg shadow-blue-500/20 border-none">Open Vault</Button>
              </Link>
            )}
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative pt-40 pb-32 overflow-hidden">
        {/* Background Gradients */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[1000px] h-[600px] bg-blue-600/10 rounded-full blur-[120px] -z-10" />
        <div className="absolute top-40 left-1/2 -translate-x-1/2 w-[600px] h-[400px] bg-indigo-600/10 rounded-full blur-[100px] -z-10" />

        <div className="container px-6 mx-auto relative z-10 text-center">
          <div className="inline-flex items-center rounded-2xl border border-blue-500/20 bg-blue-500/5 px-4 py-2 text-[10px] font-black uppercase tracking-[0.2em] text-blue-400 mb-10 animate-fade-in shadow-2xl">
            <span className="flex h-2 w-2 rounded-full bg-blue-500 mr-3 shadow-[0_0_10px_rgba(59,130,246,0.8)]"></span>
            Intelligence Engine 2.0 is Active
          </div>
          
          <h1 className="text-6xl md:text-8xl font-black tracking-tighter text-white mb-8 leading-[0.9]">
            The Legal <br/>
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 via-indigo-400 to-blue-600 animate-gradient-x">
              Intelligence OS
            </span>
          </h1>
          
          <p className="text-lg md:text-xl text-slate-400 mb-12 max-w-2xl mx-auto font-medium leading-relaxed">
            Automate high-stakes legal analysis with the world's most advanced AI contract auditor. 
            Understand risk in seconds, not weeks.
          </p>
          
          <div className="flex flex-col sm:flex-row gap-6 w-full sm:w-auto justify-center items-center">
            {!isIdExist ? (
              <SignInButton mode="modal">
                <Button size="lg" className="rounded-2xl px-10 py-8 bg-blue-600 hover:bg-blue-500 text-white font-black uppercase tracking-widest text-xs shadow-2xl shadow-blue-500/20 transition-all hover:scale-105 active:scale-95 border-none">
                  Begin Free Audit <ArrowRight size={18} className="ml-3" />
                </Button>
              </SignInButton>
            ) : (
              <Link href="/dashboard">
                <Button size="lg" className="rounded-2xl px-10 py-8 bg-blue-600 hover:bg-blue-500 text-white font-black uppercase tracking-widest text-xs shadow-2xl shadow-blue-500/20 transition-all hover:scale-105 active:scale-95 border-none">
                  Access Dashboard <ArrowRight size={18} className="ml-3" />
                </Button>
              </Link>
            )}
            
            <Button variant="outline" size="lg" className="rounded-2xl px-10 py-8 border-white/10 bg-white/5 hover:bg-white/10 text-white font-black uppercase tracking-widest text-xs backdrop-blur-xl">
              <Cpu size={18} className="mr-3 text-blue-400" /> System Specs
            </Button>
          </div>
        </div>

        {/* Hero Mockup */}
        <div className="mt-24 container px-6 mx-auto">
          <div className="relative mx-auto max-w-6xl group">
            <div className="absolute -inset-1 bg-gradient-to-r from-blue-600 via-indigo-600 to-blue-400 rounded-[2.5rem] blur opacity-25 group-hover:opacity-40 transition duration-1000"></div>
            <div className="relative bg-[#0f172a] rounded-[2rem] border border-white/5 shadow-2xl overflow-hidden backdrop-blur-3xl">
              <div className="flex items-center gap-2 px-6 py-4 border-b border-white/5 bg-slate-950/50">
                <div className="flex gap-1.5">
                  <div className="w-3 h-3 rounded-full bg-rose-500/50" />
                  <div className="w-3 h-3 rounded-full bg-amber-500/50" />
                  <div className="w-3 h-3 rounded-full bg-emerald-500/50" />
                </div>
                <div className="flex-1 flex justify-center">
                  <div className="w-64 h-6 rounded-lg bg-white/5 border border-white/5 flex items-center px-3">
                    <div className="w-2 h-2 rounded-full bg-blue-500 mr-2" />
                    <span className="text-[10px] text-slate-500 font-black uppercase tracking-widest">security-vault.v2</span>
                  </div>
                </div>
              </div>
              <div className="aspect-video bg-slate-900/50 relative overflow-hidden">
                {/* Simulated UI Content */}
                <div className="absolute inset-0 p-8 grid grid-cols-4 gap-6 opacity-40">
                  <div className="col-span-3 space-y-6">
                    <div className="h-10 w-full bg-white/5 rounded-xl border border-white/5" />
                    <div className="grid grid-cols-4 gap-4">
                      <div className="h-24 bg-blue-600/10 rounded-2xl border border-blue-500/20" />
                      <div className="h-24 bg-white/5 rounded-2xl border border-white/5" />
                      <div className="h-24 bg-white/5 rounded-2xl border border-white/5" />
                      <div className="h-24 bg-white/5 rounded-2xl border border-white/5" />
                    </div>
                    <div className="h-64 w-full bg-white/5 rounded-3xl border border-white/5" />
                  </div>
                  <div className="space-y-6">
                    <div className="h-80 w-full bg-blue-600/5 rounded-3xl border border-blue-500/10" />
                  </div>
                </div>
                <div className="absolute inset-0 flex items-center justify-center">
                   <div className="p-4 rounded-3xl bg-blue-600/10 border border-blue-500/20 backdrop-blur-2xl shadow-2xl flex items-center gap-4 animate-bounce">
                      <Bot size={40} className="text-blue-500" />
                      <div>
                        <p className="text-xs font-black text-white uppercase tracking-widest">Analysis Engine</p>
                        <p className="text-[10px] text-blue-400 font-bold">Scanning Liabilities...</p>
                      </div>
                   </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Dashboard */}
      <section className="py-20 border-y border-white/5 bg-slate-950/30">
        <div className="container px-6 mx-auto">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            <div className="text-center">
              <p className="text-4xl font-black text-white mb-2 tracking-tight">1.2s</p>
              <p className="text-[10px] text-slate-500 font-black uppercase tracking-[0.2em]">Avg Analysis Time</p>
            </div>
            <div className="text-center">
              <p className="text-4xl font-black text-white mb-2 tracking-tight">99.8%</p>
              <p className="text-[10px] text-slate-500 font-black uppercase tracking-[0.2em]">Accuracy Rating</p>
            </div>
            <div className="text-center">
              <p className="text-4xl font-black text-white mb-2 tracking-tight">256-bit</p>
              <p className="text-[10px] text-slate-500 font-black uppercase tracking-[0.2em]">Vault Encryption</p>
            </div>
            <div className="text-center">
              <p className="text-4xl font-black text-white mb-2 tracking-tight">150M+</p>
              <p className="text-[10px] text-slate-500 font-black uppercase tracking-[0.2em]">Data Points Analyzed</p>
            </div>
          </div>
        </div>
      </section>

      {/* Features */}
      <section id="features" className="py-32">
        <div className="container px-6 mx-auto">
          <div className="max-w-3xl mb-24">
            <h2 className="text-4xl md:text-5xl font-black text-white mb-6 tracking-tighter">
              A specialized intelligence layer <br/>
              <span className="text-blue-500">for your legal workspace.</span>
            </h2>
            <p className="text-lg text-slate-400 font-medium">
              We've redesigned contract management from the ground up, placing 
              AI-first workflows at the core of every operation.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-10">
            <FeatureCard 
              icon={<Zap className="text-blue-500" />}
              title="Real-time Risk Heatmap"
              description="Instantly visualize the density and severity of risks across your entire contract repository with our neural heatmap engine."
            />
            <FeatureCard 
              icon={<Bot className="text-indigo-400" />}
              title="Negotiation Toolkit"
              description="AI-generated email templates and fallback positions for every high-risk clause, ready to copy and send in one click."
            />
            <FeatureCard 
              icon={<Shield className="text-emerald-500" />}
              title="Autonomous Audit"
              description="Our system automatically detects missing protections and hidden liabilities that human reviews frequently overlook."
            />
            <FeatureCard 
              icon={<Activity className="text-rose-500" />}
              title="Performance Metrics"
              description="Track contract health trends over time with automated scoring and executive-level dashboard reporting."
            />
            <FeatureCard 
              icon={<Layers className="text-blue-400" />}
              title="Vault Integration"
              description="End-to-end encrypted document storage with permanent analysis persistence and version history tracking."
            />
            <FeatureCard 
              icon={<Globe className="text-indigo-500" />}
              title="Global Compliance"
              description="Built-in intelligence for jurisdictional regulations, ensuring your contracts meet the latest legal standards."
            />
          </div>
        </div>
      </section>

      {/* Enterprise CTA */}
      <section className="py-24 container px-6 mx-auto">
        <div className="relative rounded-[3rem] bg-gradient-to-br from-blue-600 to-indigo-800 p-12 md:p-20 overflow-hidden shadow-2xl">
          <div className="absolute top-0 right-0 p-10 opacity-10">
             <Scale size={300} className="text-white" />
          </div>
          <div className="relative z-10 max-w-2xl">
            <h2 className="text-4xl md:text-6xl font-black text-white mb-8 leading-tight tracking-tighter">
              Ready to secure your legal future?
            </h2>
            <p className="text-xl text-blue-100 mb-12 font-medium">
              Join the world's most innovative legal teams and start automating your contract review workflow today.
            </p>
            {!isIdExist ? (
              <SignInButton mode="modal">
                <Button size="lg" className="rounded-2xl px-12 py-8 bg-white text-blue-600 hover:bg-slate-100 font-black uppercase tracking-widest text-sm shadow-xl transition-all hover:scale-105 active:scale-95 border-none">
                  Get Started Now
                </Button>
              </SignInButton>
            ) : (
              <Link href="/dashboard">
                <Button size="lg" className="rounded-2xl px-12 py-8 bg-white text-blue-600 hover:bg-slate-100 font-black uppercase tracking-widest text-sm shadow-xl transition-all hover:scale-105 active:scale-95 border-none">
                  Open Dashboard
                </Button>
              </Link>
            )}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-20 border-t border-white/5 bg-slate-950/50">
        <div className="container px-6 mx-auto flex flex-col md:flex-row justify-between items-center gap-12">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-white/5 rounded-2xl flex items-center justify-center border border-white/10">
              <Scale size={24} className="text-white" />
            </div>
            <span className="text-xl font-black tracking-tighter text-white">Pilot</span>
          </div>
          <div className="flex gap-12">
            <a href="#" className="text-xs font-black uppercase tracking-widest text-slate-500 hover:text-white transition-colors">Privacy</a>
            <a href="#" className="text-xs font-black uppercase tracking-widest text-slate-500 hover:text-white transition-colors">Security</a>
            <a href="#" className="text-xs font-black uppercase tracking-widest text-slate-500 hover:text-white transition-colors">Twitter</a>
          </div>
          <div className="text-[10px] font-black uppercase tracking-widest text-slate-700">© 2026 Contract Pilot. Legal Intelligence Engine.</div>
        </div>
      </footer>
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode, title: string, description: string }) {
  return (
    <Card className="border border-white/5 bg-white/5 backdrop-blur-sm rounded-[2rem] hover:border-blue-500/30 transition-all group p-4 shadow-xl">
      <CardContent className="pt-8">
        <div className="w-16 h-16 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center mb-8 group-hover:scale-110 group-hover:bg-blue-600/10 group-hover:border-blue-500/20 transition-all duration-500 shadow-inner">
          <div className="group-hover:scale-110 transition-transform duration-500">
            {icon}
          </div>
        </div>
        <h3 className="text-xl font-black text-white mb-4 tracking-tight group-hover:text-blue-400 transition-colors">{title}</h3>
        <p className="text-slate-400 text-sm font-medium leading-relaxed group-hover:text-slate-300 transition-colors">{description}</p>
      </CardContent>
    </Card>
  );
}
