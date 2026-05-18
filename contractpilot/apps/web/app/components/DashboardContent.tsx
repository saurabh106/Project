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
  Loader2
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

  console.log("DashboardContent Rendering, analyzingId:", analyzingId);

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
    alert("Analyze started for ID: " + id);
    console.log("Analyze button clicked for ID:", id);
    setAnalyzingId(id);
    try {
      const token = await getToken();
      if (!token) {
        console.error("No auth token found");
        return;
      }
      
      console.log("Sending analysis request to backend...");
      const response = await fetch(`http://localhost:4000/api/contracts/${id}/analyze`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      console.log("Backend response status:", response.status);
      const data = await response.json();
      
      if (response.ok) {
        console.log("Analysis successful:", data);
        setSelectedAnalysis(data.analysis);
        setSelectedContractId(id);
        fetchContracts(); // Refresh to update status
      } else {
        console.error("Analysis failed server-side:", data.error || data.message);
        alert(`Analysis failed: ${data.error || "Unknown error"}`);
      }
    } catch (error) {
      console.error("Analysis request failed:", error);
      alert("Analysis request failed. Please check if the backend is running.");
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
    <div className="flex min-h-screen bg-slate-50/50">
      {/* Sidebar */}
      <aside className="w-64 border-r border-slate-200 bg-white hidden lg:flex flex-col sticky top-[65px] h-[calc(100vh-65px)] overflow-y-auto">
        <div className="p-6 flex-1 text-slate-900">
          <nav className="space-y-1">
            <NavItem icon={<Home size={18} />} label="Dashboard" active={!selectedAnalysis} onClick={() => { setSelectedAnalysis(null); setSelectedContractId(null); }} />
            <NavItem icon={<FileText size={18} />} label="My Contracts" onClick={() => { setSelectedAnalysis(null); setSelectedContractId(null); }} />
            <NavItem icon={<BarChart3 size={18} />} label="Analytics" />
            <NavItem icon={<Clock size={18} />} label="Activity" />
          </nav>
          
          <div className="mt-10 mb-4 px-4 text-xs font-semibold text-slate-400 uppercase tracking-wider">
            Workspace
          </div>
          <nav className="space-y-1">
            <NavItem icon={<Settings size={18} />} label="Settings" />
            <NavItem icon={<AlertCircle size={18} />} label="Help Center" />
          </nav>

          <div className="mt-10 mb-4 px-4 text-xs font-semibold text-slate-400 uppercase tracking-wider">
            Recent Uploads
          </div>
          <div className="px-4 space-y-2 pb-8">
            {contracts.slice(0, 5).map(c => (
              <div 
                key={c.id} 
                className={`text-xs truncate cursor-pointer transition-colors ${c.id === selectedContractId ? 'text-blue-600 font-bold' : 'text-slate-500 hover:text-blue-600'}`}
                onClick={() => {
                  if (c.analysis) {
                    setSelectedAnalysis(c.analysis);
                    setSelectedContractId(c.id);
                  }
                }}
              >
                • {c.name}
              </div>
            ))}
            {contracts.length === 0 && <div className="text-xs text-slate-400 italic">No uploads yet</div>}
          </div>
        </div>
        
        <div className="p-4 border-t border-slate-100 bg-white sticky bottom-0">
          <div className="bg-slate-900 rounded-xl p-4 text-white">
            <p className="text-xs font-medium text-slate-400 mb-1 text-slate-100">Current Plan</p>
            <p className="text-sm font-bold mb-3">Pro Version</p>
            <Button size="sm" className="w-full bg-white text-slate-900 hover:bg-slate-100">
              Upgrade
            </Button>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 p-8 overflow-y-auto">
        <div className="max-w-7xl mx-auto">
          {selectedAnalysis && selectedContractId ? (
            <div className="animate-in slide-in-from-bottom-4 duration-500">
              <div className="flex items-center justify-between mb-8">
                <Button variant="outline" size="sm" onClick={() => { setSelectedAnalysis(null); setSelectedContractId(null); }} className="rounded-full">
                  ← Back to Dashboard
                </Button>
                <div className="flex gap-2">
                  <Button variant="outline" size="sm" className="rounded-full">Download PDF</Button>
                  <Button size="sm" className="rounded-full">Export Report</Button>
                </div>
              </div>

              <div className="grid lg:grid-cols-3 gap-8">
                <div className="lg:col-span-2">
                   <ContractAnalysis data={selectedAnalysis} />
                </div>
                <div className="lg:col-span-1">
                   <ContractChat contractId={selectedContractId} />
                </div>
              </div>
            </div>
          ) : (
            <>
              <header className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-10 text-slate-900">
                <div>
                  <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">
                    Welcome back, {user?.firstName || user?.username}
                  </h1>
                  <p className="text-slate-500 mt-1">Here's a summary of your workspace activity.</p>
                </div>
                <Button className="rounded-full shadow-lg shadow-blue-500/20 px-6">
                  <Plus size={18} className="mr-2" /> New Contract
                </Button>
              </header>

              {/* Stats Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
                <StatCard label="Total Contracts" value={contracts.length.toString()} icon={<FileText className="text-blue-600" />} />
                <StatCard label="Active Now" value={contracts.filter(c => c.status === 'ACTIVE').length.toString()} icon={<Zap className="text-emerald-600" />} />
                <StatCard label="Pending Review" value={contracts.filter(c => c.status === 'PENDING' || c.status === 'REVIEW').length.toString()} icon={<Clock className="text-amber-600" />} />
                <StatCard label="Recent Uploads" value={contracts.length > 0 ? "New" : "0"} icon={<AlertCircle className="text-rose-600" />} />
              </div>

              <div className="grid lg:grid-cols-3 gap-8 text-slate-900">
                {/* Main Table */}
                <Card className="lg:col-span-2 shadow-sm border-slate-200">
                  <CardHeader className="flex flex-row items-center justify-between pb-2">
                    <div>
                      <CardTitle className="text-xl">My Contracts</CardTitle>
                      <CardDescription>All your uploaded contracts in one place.</CardDescription>
                    </div>
                    <div className="flex gap-2">
                      <div className="relative">
                        <Search size={14} className="absolute left-2.5 top-2.5 text-slate-400" />
                        <input 
                          type="text" 
                          placeholder="Search..." 
                          className="h-9 w-40 pl-8 pr-3 text-xs border border-slate-200 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-500 bg-white"
                          value={searchTerm}
                          onChange={(e) => setSearchTerm(e.target.value)}
                        />
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="overflow-x-auto">
                      {loading ? (
                        <div className="flex items-center justify-center py-12">
                          <Loader2 className="animate-spin text-blue-600" size={32} />
                        </div>
                      ) : (
                        <table className="w-full text-sm text-left">
                          <thead>
                            <tr className="text-slate-400 border-b border-slate-100">
                              <th className="py-4 font-medium font-bold uppercase text-[10px] tracking-wider">Contract</th>
                              <th className="py-4 font-medium font-bold uppercase text-[10px] tracking-wider">Status</th>
                              <th className="py-4 font-medium font-bold uppercase text-[10px] tracking-wider text-right">Actions</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-slate-50">
                            {filteredContracts.map((contract) => (
                              <tr key={contract.id} className="group hover:bg-slate-50/50 transition-colors">
                                <td className="py-4">
                                  <div className="flex flex-col">
                                    <span className="font-semibold text-slate-900">{contract.name}</span>
                                    <span className="text-xs text-slate-500">{new Date(contract.createdAt).toLocaleDateString()}</span>
                                  </div>
                                </td>
                                <td className="py-4">
                                  <StatusBadge status={contract.status} />
                                </td>
                                <td className="py-4 text-right">
                                  <div className="flex justify-end gap-2">
                                    {contract.analysis ? (
                                      <Button 
                                        size="sm" 
                                        variant="outline" 
                                        className="h-8 text-xs bg-blue-50 border-blue-100 text-blue-600 hover:bg-blue-100 rounded-full"
                                        onClick={() => {
                                          setSelectedAnalysis(contract.analysis);
                                          setSelectedContractId(contract.id);
                                        }}
                                      >
                                        View Analysis
                                      </Button>
                                    ) : (
                                      <Button 
                                        size="sm" 
                                        className="h-8 text-xs rounded-full" 
                                        disabled={analyzingId === contract.id}
                                        onClick={() => handleAnalyze(contract.id)}
                                      >
                                        {analyzingId === contract.id ? (
                                          <>
                                            <Loader2 className="mr-1 animate-spin" size={12} />
                                            Analyzing...
                                          </>
                                        ) : (
                                          <>
                                            <Zap size={12} className="mr-1" />
                                            Analyze
                                          </>
                                        )}
                                      </Button>
                                    )}
                                    <button 
                                      onClick={() => handleDelete(contract.id)}
                                      className="p-2 hover:bg-rose-50 rounded-full text-slate-400 hover:text-rose-600 transition-colors"
                                    >
                                      <Trash2 size={16} />
                                    </button>
                                  </div>
                                </td>
                              </tr>
                            ))}
                            {filteredContracts.length === 0 && (
                              <tr>
                                <td colSpan={3} className="py-12 text-center text-slate-400 italic font-medium">
                                  No contracts found. Upload your first contract to get started!
                                </td>
                              </tr>
                            )}
                          </tbody>
                        </table>
                      )}
                    </div>
                  </CardContent>
                </Card>

                {/* Side Analytics */}
                <div className="space-y-8">
                  <FileUpload onSuccess={fetchContracts} />

                  <Card className="shadow-sm border-slate-200">
                    <CardHeader>
                      <CardTitle className="text-lg">Workspace Stats</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      <div className="flex items-center justify-between p-3 rounded-xl border border-slate-100 bg-white">
                        <span className="text-sm text-slate-600 font-medium">Storage Used</span>
                        <span className="text-sm font-bold text-slate-900">{(contracts.length * 2.4).toFixed(1)} MB</span>
                      </div>
                      <div className="flex items-center justify-between p-3 rounded-xl border border-slate-100 bg-white">
                        <span className="text-sm text-slate-600 font-medium">AI Credits</span>
                        <span className="text-sm font-bold text-slate-900">{contracts.filter(c => c.analysis).length} / 50</span>
                      </div>
                    </CardContent>
                  </Card>
                </div>
              </div>
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
        flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-semibold transition-all cursor-pointer
        ${active ? 'bg-blue-50 text-blue-600' : 'text-slate-500 hover:bg-slate-50 hover:text-slate-900'}
      `}
    >
      {icon} {label}
    </div>
  );
}

function StatCard({ label, value, change, icon }: { label: string, value: string, change?: string, icon: React.ReactNode }) {
  return (
    <Card className="border-slate-200 shadow-sm overflow-hidden">
      <CardContent className="p-6">
        <div className="flex justify-between items-start mb-4">
          <div className="p-2 rounded-xl bg-slate-50 border border-slate-100">
            {icon}
          </div>
          {change && (
            <span className={`text-xs font-bold px-2 py-1 rounded-full ${change.startsWith('+') ? 'bg-emerald-50 text-emerald-600' : 'bg-rose-50 text-rose-600'}`}>
              {change}
            </span>
          )}
        </div>
        <div>
          <p className="text-sm font-medium text-slate-500 mb-1">{label}</p>
          <h3 className="text-2xl font-extrabold text-slate-900">{value}</h3>
        </div>
      </CardContent>
    </Card>
  );
}

function StatusBadge({ status }: { status: string }) {
  const styles = {
    ACTIVE: "bg-emerald-50 text-emerald-700 border-emerald-100",
    PENDING: "bg-amber-50 text-amber-700 border-amber-100",
    EXPIRED: "bg-rose-50 text-rose-700 border-rose-100",
    REVIEW: "bg-blue-50 text-blue-700 border-blue-100",
  };
  
  return (
    <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border ${styles[status as keyof typeof styles] || styles.PENDING}`}>
      {status}
    </span>
  );
}
