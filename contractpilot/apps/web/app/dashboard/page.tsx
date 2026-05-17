import { currentUser } from "@clerk/nextjs/server";
import { redirect } from "next/navigation";
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
  Zap
} from "lucide-react";
import { Button } from "../components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "../components/ui/card";

export default async function DashboardPage() {
  const user = await currentUser();

  if (!user) {
    redirect("/");
  }

  const contracts = [
    { id: 1, name: "Enterprise Service Agreement", status: "Active", type: "Service", date: "Oct 24, 2023", amount: "$12,000" },
    { id: 2, name: "Marketing Vendor Contract", status: "Pending", type: "Vendor", date: "Oct 22, 2023", amount: "$3,500" },
    { id: 3, name: "NDA - Project Apollo", status: "Active", type: "Legal", date: "Oct 15, 2023", amount: "$0" },
    { id: 4, name: "Office Lease Renewal", status: "Expired", type: "Lease", date: "Sep 30, 2023", amount: "$45,000" },
    { id: 5, name: "Cloud Infrastructure Terms", status: "Active", type: "Tech", date: "Sep 12, 2023", amount: "$800/mo" },
  ];

  return (
    <div className="flex min-h-screen bg-slate-50/50">
      {/* Sidebar */}
      <aside className="w-64 border-r border-slate-200 bg-white hidden lg:flex flex-col sticky top-[65px] h-[calc(100vh-65px)]">
        <div className="p-6 flex-1">
          <nav className="space-y-1">
            <NavItem icon={<Home size={18} />} label="Dashboard" active />
            <NavItem icon={<FileText size={18} />} label="My Contracts" />
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
        </div>
        
        <div className="p-4 border-t border-slate-100">
          <div className="bg-slate-900 rounded-xl p-4 text-white">
            <p className="text-xs font-medium text-slate-400 mb-1">Current Plan</p>
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
          <header className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-10">
            <div>
              <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">
                Welcome back, {user.firstName || user.username}
              </h1>
              <p className="text-slate-500 mt-1">Here's a summary of your workspace activity.</p>
            </div>
            <Button className="rounded-full shadow-lg shadow-blue-500/20 px-6">
              <Plus size={18} className="mr-2" /> New Contract
            </Button>
          </header>

          {/* Stats Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
            <StatCard label="Total Contracts" value="24" change="+12%" icon={<FileText className="text-blue-600" />} />
            <StatCard label="Active Now" value="18" change="+5%" icon={<Zap className="text-emerald-600" />} />
            <StatCard label="Pending Review" value="4" change="-2" icon={<Clock className="text-amber-600" />} />
            <StatCard label="Upcoming Renewals" value="2" icon={<AlertCircle className="text-rose-600" />} />
          </div>

          <div className="grid lg:grid-cols-3 gap-8">
            {/* Main Table */}
            <Card className="lg:col-span-2 shadow-sm border-slate-200">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <div>
                  <CardTitle className="text-xl">Recent Contracts</CardTitle>
                  <CardDescription>A list of contracts recently modified in your workspace.</CardDescription>
                </div>
                <div className="flex gap-2">
                  <Button variant="outline" size="sm" className="h-8 px-2">
                    <Filter size={14} className="mr-2" /> Filter
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <div className="overflow-x-auto">
                  <table className="w-full text-sm text-left">
                    <thead>
                      <tr className="text-slate-400 border-b border-slate-100">
                        <th className="py-4 font-medium">Contract</th>
                        <th className="py-4 font-medium">Status</th>
                        <th className="py-4 font-medium text-right">Amount</th>
                        <th className="py-4 font-medium text-right"></th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-50">
                      {contracts.map((contract) => (
                        <tr key={contract.id} className="group hover:bg-slate-50/50 transition-colors">
                          <td className="py-4">
                            <div className="flex flex-col">
                              <span className="font-semibold text-slate-900">{contract.name}</span>
                              <span className="text-xs text-slate-500">{contract.type} • {contract.date}</span>
                            </div>
                          </td>
                          <td className="py-4">
                            <StatusBadge status={contract.status} />
                          </td>
                          <td className="py-4 text-right font-medium text-slate-700">
                            {contract.amount}
                          </td>
                          <td className="py-4 text-right">
                            <button className="p-1 hover:bg-slate-200 rounded-md text-slate-400">
                              <MoreVertical size={16} />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                <Button variant="ghost" className="w-full mt-4 text-slate-500 font-medium">
                  View all contracts <ArrowUpRight size={16} className="ml-1" />
                </Button>
              </CardContent>
            </Card>

            {/* Side Analytics */}
            <div className="space-y-8">
              <Card className="shadow-sm border-slate-200 bg-blue-600 text-white overflow-hidden relative">
                <div className="absolute top-0 right-0 p-8 opacity-10">
                   <Zap size={120} />
                </div>
                <CardHeader>
                  <CardTitle className="text-lg">AI Assistant</CardTitle>
                  <CardDescription className="text-blue-100">Ready to analyze your files</CardDescription>
                </CardHeader>
                <CardContent>
                  <p className="text-sm mb-6 leading-relaxed">
                    Upload your contract and our AI will extract key dates and risks automatically.
                  </p>
                  <Button variant="outline" className="w-full bg-white/10 border-white/20 text-white hover:bg-white/20">
                    Try AI Analysis
                  </Button>
                </CardContent>
              </Card>

              <Card className="shadow-sm border-slate-200">
                <CardHeader>
                  <CardTitle className="text-lg">Upcoming Renewals</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-center gap-3 p-3 rounded-lg border border-slate-100 hover:border-blue-200 transition-colors cursor-pointer">
                    <div className="w-10 h-10 rounded-full bg-rose-50 flex items-center justify-center text-rose-600">
                      <AlertCircle size={18} />
                    </div>
                    <div>
                      <p className="text-sm font-bold text-slate-900">Office Lease</p>
                      <p className="text-xs text-slate-500">Expiring in 12 days</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3 p-3 rounded-lg border border-slate-100 hover:border-blue-200 transition-colors cursor-pointer">
                    <div className="w-10 h-10 rounded-full bg-blue-50 flex items-center justify-center text-blue-600">
                      <Clock size={18} />
                    </div>
                    <div>
                      <p className="text-sm font-bold text-slate-900">AWS Terms</p>
                      <p className="text-xs text-slate-500">Expiring in 45 days</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

function NavItem({ icon, label, active = false }: { icon: React.ReactNode, label: string, active?: boolean }) {
  return (
    <div className={`
      flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-semibold transition-all cursor-pointer
      ${active ? 'bg-blue-50 text-blue-600' : 'text-slate-500 hover:bg-slate-50 hover:text-slate-900'}
    `}>
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
    Active: "bg-emerald-50 text-emerald-700 border-emerald-100",
    Pending: "bg-amber-50 text-amber-700 border-amber-100",
    Expired: "bg-rose-50 text-rose-700 border-rose-100",
  };
  
  return (
    <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border ${styles[status as keyof typeof styles]}`}>
      {status}
    </span>
  );
}
