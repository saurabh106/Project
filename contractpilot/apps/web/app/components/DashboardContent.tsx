"use client";

import { useEffect, useState, useCallback } from "react";
import { useAuth, useUser } from "@clerk/nextjs";
import { 
  FileText, 
  Plus, 
  BarChart3, 
  Settings, 
  Home, 
  Clock, 
  AlertCircle,
  Search,
  Filter,
  ArrowUpRight,
  MoreVertical,
  Zap,
  Trash2,
  ExternalLink,
  Loader2,
  Scale,
  ArrowRight,
  Layers
} from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "./ui/card";
import { FileUpload } from "./FileUpload";
import { ContractChat } from "./ContractChat";
import { ContractAnalysis } from "./ContractAnalysis";

interface Contract {
  id: string;
  name: string;
  status: string;
  createdAt: string;
  fileUrl: string;
  analysis?: any;
}

export function DashboardContent() {
  const { user } = useUser();
  const { getToken } = useAuth();
  const [contracts, setContracts] = useState<Contract[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [analyzingId, setAnalyzingId] = useState<string | null>(null);
  const [selectedAnalysis, setSelectedAnalysis] = useState<any | null>(null);
  const [selectedContractId, setSelectedContractId] = useState<string | null>(null);
  const [view, setView] = useState<'dashboard' | 'history' | 'analytics' | 'settings'>('dashboard');

  const fetchContracts = useCallback(async () => {
    try {
      const token = await getToken();
      const response = await fetch("http://localhost:4000/api/contracts/my-contracts", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      if (response.ok) {
        const data = await response.json();
        setContracts(data);
      }
    } catch (error) {
      console.error("Failed to fetch contracts:", error);
    } finally {
      setLoading(false);
    }
  }, [getToken]);

  useEffect(() => {
    fetchContracts();
  }, [fetchContracts]);

  const handleAnalyze = async (id: string) => {
    setAnalyzingId(id);
    try {
      const token = await getToken();
      const response = await fetch(`http://localhost:4000/api/contracts/${id}/analyze`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      const data = await response.json();
      if (response.ok) {
        setSelectedAnalysis(data.analysis);
        setSelectedContractId(id);
        fetchContracts();
      } else {
        alert(`Analysis failed: ${data.error || "Unknown error"}`);
      }
    } catch (error) {
      console.error("Analysis request failed:", error);
    } finally {
      setAnalyzingId(null);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure you want to delete this contract?")) return;
    try {
      const token = await getToken();
      const response = await fetch(`http://localhost:4000/api/contracts/${id}`, {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      if (response.ok) {
        setContracts(contracts.filter(c => c.id !== id));
        if (selectedContractId === id) {
          setSelectedAnalysis(null);
          setSelectedContractId(null);
        }
      }
    } catch (error) {
      console.error("Delete failed:", error);
    }
  };

  const filteredContracts = contracts.filter(c => 
    c.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="flex min-h-screen bg-background text-foreground">
      {/* Sidebar */}
      <aside className="w-64 border-r border-white/5 bg-slate-900/50 backdrop-blur-xl hidden lg:flex flex-col sticky top-0 h-screen overflow-y-auto">
        <div className="p-6 flex-1">
          <div className="flex items-center gap-3 mb-10 px-2">
            <div className="w-10 h-10 bg-blue-600 rounded-2xl flex items-center justify-center shadow-lg shadow-blue-500/20 text-white">
              <Scale size={24} />
            </div>
            <span className="text-xl font-black tracking-tighter text-glow">Pilot</span>
          </div>

          <nav className="space-y-1">
            <NavItem icon={<Home size={18} />} label="Dashboard" active={view === 'dashboard' && !selectedAnalysis} onClick={() => { setView('dashboard'); setSelectedAnalysis(null); setSelectedContractId(null); }} />
            <NavItem icon={<Clock size={18} />} label="History" active={view === 'history'} onClick={() => { setView('history'); setSelectedAnalysis(null); }} />
            <NavItem icon={<BarChart3 size={18} />} label="Analytics" active={view === 'analytics'} onClick={() => { setView('analytics'); setSelectedAnalysis(null); }} />
          </nav>
          
          <div className="mt-10 mb-4 px-4 text-[10px] font-black text-slate-500 uppercase tracking-[0.2em]">
            Workspace
          </div>
          <nav className="space-y-1">
            <NavItem icon={<Settings size={18} />} label="Settings" active={view === 'settings'} onClick={() => { setView('settings'); setSelectedAnalysis(null); }} />
            <NavItem icon={<AlertCircle size={18} />} label="Support" />
          </nav>

          <div className="mt-10 mb-4 px-4 text-[10px] font-black text-slate-500 uppercase tracking-[0.2em]">
            Recent Projects
          </div>
          <div className="px-4 space-y-3 pb-8">
            {contracts.slice(0, 5).map(c => (
              <div 
                key={c.id} 
                className={`text-xs truncate cursor-pointer transition-all flex items-center gap-2 group ${c.id === selectedContractId ? 'text-blue-400 font-bold' : 'text-slate-400 hover:text-blue-300'}`}
                onClick={() => {
                  if (c.analysis) {
                    setSelectedAnalysis(c.analysis);
                    setSelectedContractId(c.id);
                  }
                }}
              >
                <div className={`w-1.5 h-1.5 rounded-full ${c.id === selectedContractId ? 'bg-blue-400' : 'bg-slate-700 group-hover:bg-blue-300'}`} />
                {c.name}
              </div>
            ))}
          </div>
        </div>
        
        <div className="p-6 border-t border-white/5 bg-slate-900/30">
          <div className="bg-gradient-to-br from-blue-600 to-indigo-700 rounded-3xl p-5 text-white shadow-xl shadow-blue-500/10 border border-white/10">
            <p className="text-[10px] font-black uppercase tracking-widest opacity-70 mb-1">Pro Account</p>
            <p className="text-sm font-black mb-4 tracking-tight">Enterprise Access</p>
            <Button size="sm" className="w-full bg-white text-blue-600 hover:bg-slate-100 rounded-xl font-bold shadow-lg border-none">
              Manage
            </Button>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto p-8 lg:p-12">
        <div className="max-w-7xl mx-auto">
          {selectedAnalysis && selectedContractId ? (
            <div className="animate-in slide-in-from-bottom-4 duration-500">
              <div className="flex items-center justify-between mb-8">
                <Button variant="outline" size="sm" onClick={() => { setSelectedAnalysis(null); setSelectedContractId(null); }} className="rounded-xl border-white/10 bg-slate-900/50 hover:bg-white/5 text-slate-300">
                  ← Back to Dashboard
                </Button>
                <div className="flex gap-2">
                   {/* Export logic is in ContractAnalysis now */}
                </div>
              </div>

              <div className="flex flex-col gap-12">
                 <ContractAnalysis data={selectedAnalysis} />
                 <div className="max-w-4xl mx-auto w-full">
                    <ContractChat contractId={selectedContractId} />
                 </div>
              </div>
            </div>
          ) : (
            <>
              {view === 'dashboard' && (
                <>
                  <header className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-10">
                    <div>
                      <h1 className="text-3xl font-black text-white tracking-tight">
                        Welcome back, <span className="text-blue-500">{user?.firstName || user?.username}</span>
                      </h1>
                      <p className="text-slate-400 mt-1 font-medium text-lg">Your legal intelligence overview is ready.</p>
                    </div>
                    <Button className="rounded-2xl shadow-xl shadow-blue-500/20 px-8 py-6 bg-blue-600 hover:bg-blue-500 font-bold transition-all hover:scale-105 active:scale-95 border-none">
                      <Plus size={18} className="mr-2" /> New Analysis
                    </Button>
                  </header>

                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
                    <StatCard label="Total Contracts" value={contracts.length.toString()} icon={<FileText className="text-blue-400" />} />
                    <StatCard label="Active Now" value={contracts.filter(c => c.status === 'ACTIVE').length.toString()} icon={<Zap className="text-emerald-400" />} />
                    <StatCard label="Pending Review" value={contracts.filter(c => c.status === 'PENDING' || c.status === 'REVIEW').length.toString()} icon={<Clock className="text-amber-400" />} />
                    <StatCard label="Recent Uploads" value={contracts.length > 0 ? "New" : "0"} icon={<AlertCircle className="text-rose-400" />} />
                  </div>

                  <div className="grid lg:grid-cols-3 gap-8">
                    <Card className="lg:col-span-2 border-white/5 bg-slate-900/50 backdrop-blur-sm shadow-2xl">
                      <CardHeader className="flex flex-row items-center justify-between pb-6 border-b border-white/5">
                        <div>
                          <CardTitle className="text-xl font-bold text-white">Repository</CardTitle>
                          <CardDescription className="text-slate-500 font-medium">Manage and track your contract versions.</CardDescription>
                        </div>
                        <div className="relative group">
                          <Search size={14} className="absolute left-3 top-3 text-slate-500 group-focus-within:text-blue-400 transition-colors" />
                          <input 
                            type="text" 
                            placeholder="Search repository..." 
                            className="h-10 w-48 pl-10 pr-4 text-xs border border-white/5 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/50 bg-slate-950/50 text-white transition-all"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                          />
                        </div>
                      </CardHeader>
                      <CardContent className="p-0">
                        <div className="overflow-x-auto">
                          {loading ? (
                            <div className="flex items-center justify-center py-20">
                              <Loader2 className="animate-spin text-blue-500" size={40} />
                            </div>
                          ) : (
                            <table className="w-full text-sm text-left">
                              <thead>
                                <tr className="text-slate-500 border-b border-white/5 bg-slate-950/30">
                                  <th className="px-6 py-4 font-black uppercase text-[10px] tracking-[0.2em]">Contract</th>
                                  <th className="px-6 py-4 font-black uppercase text-[10px] tracking-[0.2em]">Status</th>
                                  <th className="px-6 py-4 font-black uppercase text-[10px] tracking-[0.2em] text-right">Actions</th>
                                </tr>
                              </thead>
                              <tbody className="divide-y divide-white/5">
                                {filteredContracts.map((contract) => (
                                  <tr key={contract.id} className="group hover:bg-white/[0.02] transition-colors">
                                    <td className="px-6 py-5">
                                      <div className="flex flex-col">
                                        <span className="font-bold text-slate-200 group-hover:text-white transition-colors">{contract.name}</span>
                                        <span className="text-[10px] text-slate-500 font-medium uppercase tracking-wider">{new Date(contract.createdAt).toLocaleDateString()}</span>
                                      </div>
                                    </td>
                                    <td className="px-6 py-5">
                                      <StatusBadge status={contract.status} />
                                    </td>
                                    <td className="px-6 py-5 text-right">
                                      <div className="flex justify-end gap-3 opacity-60 group-hover:opacity-100 transition-opacity">
                                        {contract.analysis ? (
                                          <Button 
                                            size="sm" 
                                            variant="outline" 
                                            className="h-9 px-4 text-xs bg-blue-500/10 border-blue-500/20 text-blue-400 hover:bg-blue-500 hover:text-white rounded-xl transition-all font-bold"
                                            onClick={() => {
                                              setSelectedAnalysis(contract.analysis);
                                              setSelectedContractId(contract.id);
                                            }}
                                          >
                                            Review Analysis
                                          </Button>
                                        ) : (
                                          <Button 
                                            size="sm" 
                                            className="h-9 px-4 text-xs rounded-xl bg-slate-800 hover:bg-blue-600 text-white transition-all font-bold shadow-lg border-none" 
                                            disabled={analyzingId === contract.id}
                                            onClick={() => handleAnalyze(contract.id)}
                                          >
                                            {analyzingId === contract.id ? (
                                              <Loader2 className="animate-spin" size={14} />
                                            ) : (
                                              <Zap size={14} className="mr-2" />
                                            )}
                                            Analyze
                                          </Button>
                                        )}
                                        <button 
                                          onClick={() => handleDelete(contract.id)}
                                          className="p-2 hover:bg-rose-500/20 rounded-xl text-slate-500 hover:text-rose-500 transition-all"
                                        >
                                          <Trash2 size={16} />
                                        </button>
                                      </div>
                                    </td>
                                  </tr>
                                ))}
                              </tbody>
                            </table>
                          )}
                        </div>
                      </CardContent>
                    </Card>

                    <div className="space-y-8">
                      <FileUpload onSuccess={fetchContracts} />

                      <Card className="border-white/5 bg-slate-900/50 backdrop-blur-sm shadow-xl overflow-hidden">
                        <CardHeader>
                          <CardTitle className="text-lg font-bold text-white">System Health</CardTitle>
                        </CardHeader>
                        <CardContent className="space-y-4">
                          <div className="p-4 rounded-2xl bg-slate-950/50 border border-white/5">
                            <div className="flex items-center justify-between mb-2">
                              <span className="text-[10px] font-black text-slate-500 uppercase">Vault Storage</span>
                              <span className="text-xs font-bold text-white">{(contracts.length * 2.4).toFixed(1)} / 500 MB</span>
                            </div>
                            <div className="h-1 w-full bg-slate-800 rounded-full overflow-hidden">
                              <div className="h-full bg-blue-500 rounded-full" style={{ width: `${(contracts.length * 2.4 / 500) * 100}%` }} />
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    </div>
                  </div>
                </>
              )}

              {view === 'history' && (
                <div className="animate-in fade-in slide-in-from-bottom-4 duration-700">
                  <header className="mb-10">
                    <h1 className="text-3xl font-black text-white tracking-tight">Analysis <span className="text-blue-500">History</span></h1>
                    <p className="text-slate-400 mt-1 font-medium text-lg">Detailed log of all AI generated legal assessments.</p>
                  </header>
                  <div className="grid gap-4">
                     {contracts.filter(c => c.analysis).map(c => (
                       <Card key={c.id} className="border-white/5 bg-slate-900/50 backdrop-blur-sm hover:border-blue-500/30 transition-all group cursor-pointer" onClick={() => { setSelectedAnalysis(c.analysis); setSelectedContractId(c.id); }}>
                         <CardContent className="p-6 flex items-center justify-between">
                            <div className="flex items-center gap-4">
                               <div className="p-3 bg-blue-500/10 rounded-2xl text-blue-400">
                                  <FileText size={24} />
                               </div>
                               <div>
                                  <h4 className="font-bold text-slate-200 group-hover:text-white transition-colors">{c.name}</h4>
                                  <p className="text-[10px] text-slate-500 font-black uppercase tracking-widest mt-1">Analyzed on {new Date(c.createdAt).toLocaleDateString()}</p>
                               </div>
                            </div>
                            <div className="flex items-center gap-6">
                               <div className="text-right">
                                  <p className="text-[10px] text-slate-500 font-black uppercase tracking-widest">Risk Level</p>
                                  <p className={`font-black text-sm ${c.analysis.overall_risk_level === 'CRITICAL' ? 'text-rose-500' : 'text-emerald-500'}`}>{c.analysis.overall_risk_level}</p>
                               </div>
                               <ArrowRight size={20} className="text-slate-600 group-hover:text-blue-500 group-hover:translate-x-1 transition-all" />
                            </div>
                         </CardContent>
                       </Card>
                     ))}
                  </div>
                </div>
              )}

              {(view === 'analytics' || view === 'settings') && (
                <div className="py-20 text-center">
                   <div className="w-20 h-20 bg-slate-900 rounded-full flex items-center justify-center mx-auto mb-6 text-slate-600">
                      <Layers size={40} />
                   </div>
                   <h2 className="text-2xl font-black text-white">Module Under Construction</h2>
                   <p className="text-slate-500 mt-2 max-w-md mx-auto">We're building advanced legal data visualizations and enterprise management features. Check back soon!</p>
                   <Button variant="outline" className="mt-8 rounded-xl border-white/10" onClick={() => setView('dashboard')}>Return to Dashboard</Button>
                </div>
              )}
            </>
          )}
        </div>
      </main>
    </div>
  );
}

function NavItem({ icon, label, active = false, onClick }: { icon: React.ReactNode, label: string, active?: boolean, onClick?: () => void }) {
  return (
    <div 
      onClick={onClick}
      className={`
        flex items-center gap-3 px-4 py-3 rounded-2xl text-sm font-bold transition-all cursor-pointer
        ${active ? 'bg-blue-600/10 text-blue-400 shadow-sm border border-blue-500/10' : 'text-slate-400 hover:bg-white/5 hover:text-slate-200'}
      `}
    >
      {icon} {label}
    </div>
  );
}

function StatCard({ label, value, change, icon }: { label: string, value: string, change?: string, icon: React.ReactNode }) {
  return (
    <Card className="border-white/5 bg-slate-900/50 backdrop-blur-sm shadow-xl hover:border-white/10 transition-all group">
      <CardContent className="p-6">
        <div className="flex justify-between items-start mb-4">
          <div className="p-3 rounded-2xl bg-slate-950/50 border border-white/5 group-hover:border-blue-500/20 transition-all">
            {icon}
          </div>
          {change && (
            <span className={`text-[10px] font-black px-2 py-1 rounded-full uppercase tracking-widest ${change.startsWith('+') ? 'bg-emerald-500/10 text-emerald-500' : 'bg-rose-500/10 text-rose-500'}`}>
              {change}
            </span>
          )}
        </div>
        <div>
          <p className="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1">{label}</p>
          <h3 className="text-3xl font-black text-white tracking-tight">{value}</h3>
        </div>
      </CardContent>
    </Card>
  );
}

function StatusBadge({ status }: { status: string }) {
  const styles = {
    ACTIVE: "bg-emerald-500/10 text-emerald-500 border-emerald-500/20",
    PENDING: "bg-amber-500/10 text-amber-500 border-amber-500/20",
    EXPIRED: "bg-rose-500/10 text-rose-500 border-rose-500/20",
    REVIEW: "bg-blue-500/10 text-blue-500 border-blue-500/20",
  };
  
  return (
    <span className={`px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-[0.1em] border ${styles[status as keyof typeof styles] || styles.PENDING}`}>
      {status}
    </span>
  );
}
