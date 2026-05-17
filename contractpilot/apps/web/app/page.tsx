import { SignInButton, Show } from "@clerk/nextjs";
import Link from "next/link";
import Image from "next/image";
import { Shield, Zap, Bell, ArrowRight, CheckCircle2, ChevronRight } from "lucide-react";
import { Button } from "./components/ui/button";
import { Card, CardContent } from "./components/ui/card";

export default function LandingPage() {
  return (
    <div className="flex flex-col min-h-screen">
      {/* Hero Section */}
      <section className="relative pt-20 pb-32 overflow-hidden bg-white">
        <div className="container px-4 mx-auto relative z-10">
          <div className="flex flex-col items-center text-center max-w-4xl mx-auto">
            <div className="inline-flex items-center rounded-full border border-primary/20 bg-primary/5 px-3 py-1 text-sm font-medium text-primary mb-8 animate-fade-in">
              <span className="flex h-2 w-2 rounded-full bg-primary mr-2"></span>
              New: AI Contract Analysis is here
              <ChevronRight size={14} className="ml-1" />
            </div>
            
            <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight text-slate-900 mb-8 leading-[1.1]">
              The intelligent way to <br/>
              <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-indigo-600">
                manage contracts
              </span>
            </h1>
            
            <p className="text-xl text-slate-600 mb-10 max-w-2xl leading-relaxed">
              Contract Pilot automates your legal workflows with powerful AI insights. 
              Built for modern teams who want to close deals faster and stay compliant.
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4 w-full sm:w-auto justify-center">
              <Show when="signed-out">
                <SignInButton mode="modal">
                  <Button size="lg" className="rounded-full px-8">
                    Get Started for Free <ArrowRight size={18} className="ml-2" />
                  </Button>
                </SignInButton>
              </Show>
              
              <Show when="signed-in">
                <Link href="/dashboard">
                  <Button size="lg" className="rounded-full px-8">
                    Go to Dashboard <ArrowRight size={18} className="ml-2" />
                  </Button>
                </Link>
              </Show>
              
              <Button variant="outline" size="lg" className="rounded-full px-8">
                Watch Demo
              </Button>
            </div>
          </div>
        </div>

        {/* Hero Image / Mockup */}
        <div className="mt-16 container px-4 mx-auto">
          <div className="relative mx-auto max-w-5xl">
            <div className="absolute -inset-1 bg-gradient-to-r from-blue-600 to-indigo-600 rounded-2xl blur opacity-20"></div>
            <div className="relative bg-white rounded-2xl border border-slate-200 shadow-2xl overflow-hidden">
              <Image 
                src="https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&q=80&w=2026" 
                alt="Contract Pilot Dashboard" 
                width={1200}
                height={600}
                className="w-full h-auto"
                priority
              />
            </div>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="py-24 bg-slate-50">
        <div className="container px-4 mx-auto">
          <div className="text-center max-w-2xl mx-auto mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-slate-900 mb-4">
              Everything you need to scale
            </h2>
            <p className="text-lg text-slate-600">
              Powerful tools designed to simplify your contract lifecycle management.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <FeatureCard 
              icon={<Shield className="text-blue-600" />}
              title="Bank-Grade Security"
              description="Your data is protected with end-to-end encryption and enterprise-level compliance."
            />
            <FeatureCard 
              icon={<Zap className="text-blue-600" />}
              title="AI-Powered Analysis"
              description="Automatically extract key terms, obligations, and risks from any contract in seconds."
            />
            <FeatureCard 
              icon={<Bell className="text-blue-600" />}
              title="Smart Notifications"
              description="Never miss a renewal or expiration with automated multi-channel alerts."
            />
          </div>
        </div>
      </section>

      {/* Trust Section */}
      <section className="py-20 bg-white border-y border-slate-100">
        <div className="container px-4 mx-auto text-center">
          <h3 className="text-sm font-semibold uppercase tracking-wider text-slate-400 mb-12">
            Trusted by teams worldwide
          </h3>
          <div className="flex flex-wrap justify-center items-center gap-12 opacity-50 grayscale">
            {/* Logos could go here */}
            <div className="text-2xl font-bold">ACME Corp</div>
            <div className="text-2xl font-bold">Stark Industries</div>
            <div className="text-2xl font-bold">Wayne Enterprises</div>
            <div className="text-2xl font-bold">Globex</div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-slate-900 text-slate-400 py-12">
        <div className="container px-4 mx-auto flex flex-col md:flex-row justify-between items-center gap-8">
          <div className="text-xl font-bold text-white">ContractPilot</div>
          <div className="flex gap-8">
            <a href="#" className="hover:text-white transition-colors">Privacy</a>
            <a href="#" className="hover:text-white transition-colors">Terms</a>
            <a href="#" className="hover:text-white transition-colors">Twitter</a>
          </div>
          <div>© 2026 Contract Pilot. All rights reserved.</div>
        </div>
      </footer>
    </div>
  );
}

function FeatureCard({ icon, title, description }: { icon: React.ReactNode, title: string, description: string }) {
  return (
    <Card className="border-none shadow-none bg-transparent">
      <CardContent className="pt-6">
        <div className="w-12 h-12 rounded-2xl bg-white shadow-sm border border-slate-100 flex items-center justify-center mb-6">
          {icon}
        </div>
        <h3 className="text-xl font-bold text-slate-900 mb-3">{title}</h3>
        <p className="text-slate-600 leading-relaxed">{description}</p>
      </CardContent>
    </Card>
  );
}
