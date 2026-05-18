"use client";

import React from "react";
import { 
  AlertTriangle, 
  CheckCircle2, 
  Info, 
  ShieldAlert, 
  ChevronRight, 
  FileText,
  TrendingUp,
  AlertCircle,
  Scale,
  Zap,
  ChevronDown,
  Copy,
  Check,
  BarChart,
  Layers,
  Activity,
  ArrowRight,
  ExternalLink
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "./ui/card";
import { Button } from "./ui/button";
import { useState, useMemo } from "react";

interface AnalysisData {
  contract_type: string;
  overall_risk_score: number;
  overall_risk_level: string;
  summary: {
    critical_issues: number;
    high_risk: number;
    medium_risk: number;
    low_risk: number;
  };
  clauses: Array<{
    id: string;
    section: string;
    title: string;
    category: string;
    risk_score: number;
    risk_level: string;
    original_text: string;
    plain_english: {
      simple_explanation: string;
      business_impact: string;
      real_world_example: string;
    };
    problem_detected: string[];
    recommendation: {
      primary_action: string;
      priority: string;
    };
    negotiation_language?: {
      email_text: string;
    };
  }>;
  final_recommendation: {
    decision: string;
    next_steps: string[];
  };
}

const RoadmapItem = ({ title, status, description, icon: Icon }: { title: string, status: 'complete' | 'current' | 'pending', description: string, icon: any }) => (
  <div className="flex gap-3 items-start relative pb-6 last:pb-0 group">
    <div className="flex flex-col items-center">
      <div className={`p-1.5 rounded-lg border-2 transition-all ${
        status === 'complete' ? 'bg-emerald-500 border-emerald-500 text-white' : 
        status === 'current' ? 'bg-blue-100 border-blue-500 text-blue-600 animate-pulse' : 
        'bg-slate-50 border-slate-200 text-slate-300'
      }`}>
        <Icon size={14} />
      </div>
      <div className={`w-0.5 flex-1 mt-2 mb-2 ${status === 'complete' ? 'bg-emerald-200' : 'bg-slate-100'}`} />
    </div>
    <div>
      <p className={`text-xs font-black uppercase tracking-widest ${status === 'pending' ? 'text-slate-300' : 'text-slate-900'}`}>{title}</p>
      <p className="text-[10px] text-slate-400 font-medium">{description}</p>
    </div>
  </div>
);

const RiskDashboard = ({ data, categories, topRisks }: { data: any, categories: any[], topRisks: any[] }) => {
  const getRiskColor = (level: string) => {
    switch (level.toUpperCase()) {
      case "CRITICAL": return "bg-rose-500";
      case "HIGH": return "bg-orange-500";
      case "MEDIUM": return "bg-amber-500";
      default: return "bg-emerald-500";
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-top-4 duration-700">
      {/* Top Row: Distribution & Rating */}
      <div className="grid lg:grid-cols-3 gap-6">
        {/* Category Distribution */}
        <Card className="lg:col-span-2 border-white/5 bg-slate-900/50 backdrop-blur-sm shadow-xl overflow-hidden">
          <CardHeader className="pb-2 border-b border-white/5">
            <CardTitle className="text-xs font-black uppercase tracking-[0.2em] text-slate-500 flex items-center gap-2">
              <BarChart size={16} className="text-blue-500" />
              Risk Distribution
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-6">
            <div className="grid grid-cols-2 gap-8">
               <div className="space-y-5">
                {categories.map((cat) => (
                  <div key={cat.name} className="space-y-2 group">
                    <div className="flex justify-between text-[10px] font-black uppercase tracking-widest">
                      <span className="text-slate-400 group-hover:text-blue-400 transition-colors">{cat.name}</span>
                      <span className="text-slate-500">{cat.count}</span>
                    </div>
                    <div className="h-1 w-full bg-white/5 rounded-full overflow-hidden">
                      <div 
                        className="h-full bg-blue-600 rounded-full transition-all duration-1000 group-hover:bg-blue-400 group-hover:shadow-[0_0_10px_rgba(59,130,246,0.5)]" 
                        style={{ width: `${(cat.count / data.clauses.length) * 100}%` }}
                      />
                    </div>
                  </div>
                ))}
               </div>
               <div className="bg-slate-950/50 rounded-3xl p-6 flex flex-col justify-center border border-white/5 shadow-inner">
                  <div className="flex flex-wrap gap-1.5 justify-center">
                    {data.clauses.map((c: any, i: number) => (
                      <div 
                        key={i} 
                        className={`w-3.5 h-3.5 rounded-sm ${getRiskColor(c.risk_level)} opacity-70 hover:opacity-100 hover:scale-125 transition-all cursor-help shadow-lg`}
                        title={`${c.title} (${c.risk_level})`}
                      />
                    ))}
                  </div>
                  <p className="text-[9px] text-slate-500 font-black uppercase text-center mt-4 tracking-[0.2em]">Intensity Heatmap</p>
               </div>
            </div>
          </CardContent>
        </Card>

        {/* Quick Verdict */}
        <Card className="bg-slate-900 border-white/5 shadow-2xl relative overflow-hidden flex flex-col group">
          <div className="absolute top-0 right-0 p-4 opacity-10 rotate-12 transition-transform group-hover:rotate-45 duration-700">
            <ShieldAlert size={140} className="text-blue-500" />
          </div>
          <CardHeader className="border-b border-white/5 bg-slate-950/30">
            <CardTitle className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-500">Security Rating</CardTitle>
          </CardHeader>
          <CardContent className="flex-1 flex flex-col justify-center items-center text-center py-10">
             <div className={`w-24 h-24 rounded-full border-4 flex items-center justify-center mb-6 shadow-2xl transition-all duration-700 group-hover:scale-110 ${
               data.overall_risk_score > 70 ? 'border-rose-500/50 text-rose-500 shadow-rose-500/10' : 
               data.overall_risk_score > 40 ? 'border-amber-500/50 text-amber-500 shadow-amber-500/10' : 'border-emerald-500/50 text-emerald-500 shadow-emerald-500/10'
             }`}>
                <span className="text-4xl font-black">{data.overall_risk_score}</span>
             </div>
             <p className="text-xl font-black mb-1 tracking-tight text-white uppercase">{data.overall_risk_level} RISK</p>
             <p className="text-[10px] text-slate-500 font-black uppercase tracking-widest">Composite Security Score</p>
          </CardContent>
        </Card>
      </div>

      {/* Top Red Flags */}
      <div className="grid lg:grid-cols-1 gap-4">
        <h4 className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-500 ml-2">Priority Red Flags</h4>
        {topRisks.map((risk, i) => (
          <div key={i} className="flex items-center gap-6 p-5 rounded-3xl bg-slate-900/50 border border-white/5 hover:border-blue-500/30 transition-all group cursor-pointer shadow-xl backdrop-blur-sm">
            <div className={`w-14 h-14 rounded-2xl ${getRiskColor(risk.risk_level)} flex items-center justify-center text-white shrink-0 shadow-2xl shadow-rose-900/20 group-hover:scale-110 transition-transform`}>
              <AlertTriangle size={28} />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-3 mb-1">
                <span className="text-[10px] font-black text-blue-400 uppercase tracking-widest">{risk.category}</span>
                <span className="w-1 h-1 rounded-full bg-slate-700" />
                <span className="text-[10px] font-black text-rose-500 uppercase tracking-widest">Severity: {risk.risk_score}</span>
              </div>
              <p className="text-lg font-bold text-white truncate tracking-tight group-hover:text-blue-400 transition-colors">{risk.title}</p>
            </div>
            <div className="p-3 rounded-xl bg-white/5 text-slate-500 group-hover:text-blue-400 transition-all group-hover:translate-x-1">
              <ArrowRight size={20} />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export function ContractAnalysis({ data }: { data: any }) {
  const [expandedClauses, setExpandedClauses] = useState<Record<number, boolean>>({ 0: true });
  const [copiedId, setCopiedId] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'dashboard' | 'clauses'>('dashboard');

  const categories = useMemo(() => {
    const counts: Record<string, number> = {};
    data.clauses.forEach((c: any) => {
      counts[c.category] = (counts[c.category] || 0) + 1;
    });
    return Object.entries(counts).map(([name, count]) => ({ name, count }));
  }, [data.clauses]);

  const topRisks = useMemo(() => {
    return [...data.clauses]
      .sort((a, b) => b.risk_score - a.risk_score)
      .slice(0, 3);
  }, [data.clauses]);

  const exportToPDF = async () => {
    const { jsPDF } = await import("jspdf");
    await import("jspdf-autotable");
    const doc = new jsPDF();
    const pageWidth = doc.internal.pageSize.getWidth();
    
    // Header
    doc.setFillColor(15, 23, 42); // slate-900
    doc.rect(0, 0, pageWidth, 40, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(22);
    doc.setFont("helvetica", "bold");
    doc.text("ContractPilot Intelligence Report", 20, 25);
    
    // Summary Section
    doc.setTextColor(15, 23, 42);
    doc.setFontSize(16);
    doc.text(`Analysis: ${data.contract_type}`, 20, 55);
    
    doc.setFontSize(12);
    doc.setFont("helvetica", "normal");
    doc.text(`Overall Risk Score: ${data.overall_risk_score}/100`, 20, 65);
    doc.text(`Risk Level: ${data.overall_risk_level}`, 20, 72);
    doc.text(`Final Verdict: ${data.final_recommendation.decision}`, 20, 79);

    // Stats
    const statsData = [
      ["Critical", data.summary.critical_issues],
      ["High", data.summary.high_risk],
      ["Medium", data.summary.medium_risk],
      ["Low", data.summary.low_risk]
    ];

    (doc as any).autoTable({
      startY: 90,
      head: [['Risk Level', 'Issue Count']],
      body: statsData,
      theme: 'striped',
      headStyles: { fillColor: [59, 130, 246] } // blue-600
    });

    // Clause Details
    doc.setFontSize(14);
    doc.setFont("helvetica", "bold");
    doc.text("Detailed Clause Analysis", 20, (doc as any).lastAutoTable.finalY + 15);

    const clausesData = data.clauses.map((c: any) => [
      c.section,
      c.title,
      c.risk_level,
      c.plain_english.simple_explanation,
      c.recommendation.primary_action
    ]);

    (doc as any).autoTable({
      startY: (doc as any).lastAutoTable.finalY + 20,
      head: [['ID', 'Title', 'Risk', 'Explanation', 'Action']],
      body: clausesData,
      theme: 'grid',
      headStyles: { fillColor: [15, 23, 42] },
      columnStyles: {
        0: { cellWidth: 10 },
        1: { cellWidth: 30 },
        2: { cellWidth: 20 },
        3: { cellWidth: 80 },
        4: { cellWidth: 40 }
      },
      styles: { fontSize: 9, overflow: 'linebreak' }
    });

    doc.save(`Analysis-${data.contract_type.replace(/\s+/g, '-')}.pdf`);
  };

  if (data.error) {
    return (
      <Card className="border-rose-200 bg-rose-50/50">
        <CardContent className="p-12 text-center">
          <div className="w-16 h-16 rounded-full bg-rose-100 flex items-center justify-center text-rose-600 mx-auto mb-6">
            <AlertCircle size={32} />
          </div>
          <h2 className="text-xl font-bold text-slate-900 mb-2">Analysis Failed</h2>
          <p className="text-slate-600 max-w-md mx-auto mb-8">
            {data.message || "We encountered an error while analyzing your contract. Please try again in a moment."}
          </p>
          <Button variant="outline" onClick={() => window.location.reload()}>
            Retry Analysis
          </Button>
        </CardContent>
      </Card>
    );
  }

  const getRiskColor = (level: string) => {
    switch (level.toUpperCase()) {
      case "CRITICAL": return {
        text: "text-rose-600",
        bg: "bg-rose-50",
        border: "border-rose-100",
        solid: "bg-rose-500",
        icon: <ShieldAlert className="text-rose-500" size={18} />
      };
      case "HIGH": return {
        text: "text-orange-600",
        bg: "bg-orange-50",
        border: "border-orange-100",
        solid: "bg-orange-500",
        icon: <AlertTriangle className="text-orange-500" size={18} />
      };
      case "MEDIUM": return {
        text: "text-amber-600",
        bg: "bg-amber-50",
        border: "border-amber-100",
        solid: "bg-amber-500",
        icon: <Info className="text-amber-500" size={18} />
      };
      default: return {
        text: "text-emerald-600",
        bg: "bg-emerald-50",
        border: "border-emerald-100",
        solid: "bg-emerald-500",
        icon: <CheckCircle2 className="text-emerald-500" size={18} />
      };
    }
  };

  const toggleClause = (index: number) => {
    setExpandedClauses(prev => ({
      ...prev,
      [index]: !prev[index]
    }));
  };

  const copyToClipboard = (text: string, id: string) => {
    navigator.clipboard.writeText(text);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 2000);
  };

  return (
    <div className="grid lg:grid-cols-4 gap-8 items-start animate-in fade-in slide-in-from-bottom-4 duration-700">
      {/* Sidebar: Roadmap & Concept */}
      <div className="lg:col-span-1 space-y-6 sticky top-[100px]">
        <Card className="border-slate-200 shadow-sm overflow-hidden bg-white/50 backdrop-blur-sm">
          <CardHeader className="pb-4">
            <CardTitle className="text-sm font-black uppercase tracking-widest text-slate-400">Analysis Roadmap</CardTitle>
          </CardHeader>
          <CardContent>
            <RoadmapItem 
              title="Extraction" 
              status="complete" 
              description="Legal text successfully parsed" 
              icon={FileText} 
            />
            <RoadmapItem 
              title="Context Mapping" 
              status="complete" 
              description="Identifying legal obligations" 
              icon={Scale} 
            />
            <RoadmapItem 
              title="Risk Profiling" 
              status="complete" 
              description="Scoring impact & probability" 
              icon={AlertCircle} 
            />
            <RoadmapItem 
              title="Final Verdict" 
              status="current" 
              description="Generating recommendations" 
              icon={Zap} 
            />
          </CardContent>
        </Card>

        <div className="p-6 rounded-3xl bg-blue-600 text-white shadow-xl shadow-blue-500/20">
          <div className="flex items-center gap-2 mb-4">
            <Info size={18} />
            <span className="text-xs font-black uppercase tracking-widest">The Concept</span>
          </div>
          <p className="text-sm font-bold leading-relaxed mb-4">
            AI analysis isn't just a spellcheck.
          </p>
          <p className="text-[11px] opacity-80 leading-relaxed italic">
            "We look for missing protections, unusual wording, and hidden liabilities that standard legal reviews might overlook."
          </p>
        </div>
      </div>

      {/* Main Analysis Area */}
      <div className="lg:col-span-3 space-y-8">
        {/* Tab Navigation */}
        <div className="flex items-center justify-between">
          <div className="flex p-1 bg-slate-900 border border-white/5 rounded-2xl w-fit">
            <button 
              onClick={() => setActiveTab('dashboard')}
              className={`px-6 py-2 rounded-xl text-[10px] font-black uppercase tracking-[0.2em] transition-all ${
                activeTab === 'dashboard' ? 'bg-blue-600 text-white shadow-lg' : 'text-slate-500 hover:text-slate-300'
              }`}
            >
              Dashboard
            </button>
            <button 
              onClick={() => setActiveTab('clauses')}
              className={`px-6 py-2 rounded-xl text-[10px] font-black uppercase tracking-[0.2em] transition-all ${
                activeTab === 'clauses' ? 'bg-blue-600 text-white shadow-lg' : 'text-slate-500 hover:text-slate-300'
              }`}
            >
              Clause Insights
            </button>
          </div>
          
          <Button 
            onClick={exportToPDF}
            className="rounded-xl bg-slate-900 border border-white/10 hover:bg-slate-800 text-slate-300 text-[10px] font-black uppercase tracking-widest px-6"
          >
            <ExternalLink size={14} className="mr-2 text-blue-500" />
            Export PDF
          </Button>
        </div>

        {activeTab === 'dashboard' ? (
          <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
             <RiskDashboard data={data} categories={categories} topRisks={topRisks} />
          </div>
        ) : (
          <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-700">
            <div className="flex items-center justify-between">
              <h3 className="text-2xl font-black text-slate-900 tracking-tight flex items-center gap-3">
                <div className="p-2 bg-blue-100 rounded-xl">
                  <FileText size={24} className="text-blue-600" />
                </div>
                Detailed Insights
              </h3>
            </div>
            
            <div className="space-y-4">
              {data.clauses.map((clause, index) => {
                const colors = getRiskColor(clause.risk_level);
                const isExpanded = expandedClauses[index];

                return (
                  <div 
                    key={index} 
                    className={`group border rounded-3xl overflow-hidden transition-all duration-300 ${
                      isExpanded ? 'shadow-xl border-slate-300 ring-1 ring-slate-200' : 'hover:border-slate-300 border-slate-200 bg-white'
                    }`}
                  >
                    {/* Header / Summary View */}
                    <button 
                      onClick={() => toggleClause(index)}
                      className="w-full text-left p-5 flex items-center justify-between transition-colors"
                    >
                      <div className="flex items-center gap-4 flex-1 min-w-0">
                        <div className={`w-10 h-10 rounded-2xl ${colors.bg} ${colors.text} flex items-center justify-center shrink-0 font-black`}>
                          {clause.section}
                        </div>
                        <div className="min-w-0">
                          <div className="flex items-center gap-2 mb-0.5">
                            <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest truncate">
                              {clause.category}
                            </span>
                            <div className={`px-2 py-0.5 rounded-full text-[9px] font-black border flex items-center gap-1 ${colors.bg} ${colors.text} ${colors.border}`}>
                              {clause.risk_level}
                            </div>
                          </div>
                          <h4 className="text-lg font-bold text-slate-900 truncate tracking-tight">{clause.title}</h4>
                        </div>
                      </div>
                      <ChevronDown className={`text-slate-400 transition-transform duration-300 ${isExpanded ? 'rotate-180' : ''}`} size={20} />
                    </button>

                    {/* Expanded Content */}
                    {isExpanded && (
                      <div className="p-6 bg-slate-50/50 border-t border-slate-200 animate-in slide-in-from-top-2 duration-300">
                        <div className="grid lg:grid-cols-2 gap-8">
                          {/* Human-Centered Analysis */}
                          <div className="space-y-6">
                            <div className="bg-white rounded-3xl p-6 shadow-sm border border-slate-100">
                              <div className="flex items-center gap-2 mb-4">
                                <div className="p-1.5 bg-blue-50 rounded-lg">
                                  <Info size={16} className="text-blue-600" />
                                </div>
                                <h5 className="text-xs font-black text-slate-800 uppercase tracking-widest">Why This Matters</h5>
                              </div>
                              <p className="text-md text-slate-800 leading-relaxed font-bold mb-4 italic border-l-4 border-blue-400 pl-4">
                                "{clause.plain_english.simple_explanation}"
                              </p>
                              <div className="space-y-3">
                                <div className="flex items-start gap-3 p-3 rounded-2xl bg-blue-50/50 border border-blue-100">
                                  <Zap size={14} className="text-blue-500 mt-1 shrink-0" />
                                  <div>
                                    <p className="text-[10px] font-black text-blue-400 uppercase tracking-widest">Business Impact</p>
                                    <p className="text-xs text-slate-600 leading-relaxed font-medium">{clause.plain_english.business_impact}</p>
                                  </div>
                                </div>
                                <div className="flex items-start gap-3 p-3 rounded-2xl bg-emerald-50/50 border border-emerald-100">
                                  <TrendingUp size={14} className="text-emerald-500 mt-1 shrink-0" />
                                  <div>
                                    <p className="text-[10px] font-black text-emerald-400 uppercase tracking-widest">Concrete Example</p>
                                    <p className="text-xs text-slate-600 leading-relaxed font-medium">{clause.plain_english.real_world_example}</p>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </div>

                          {/* Technical/Action Analysis */}
                          <div className="space-y-6">
                            <div className={`${colors.bg} rounded-3xl p-6 border ${colors.border}`}>
                              <div className="flex items-center gap-2 mb-4">
                                <div className="p-1.5 bg-white rounded-lg">
                                  {colors.icon}
                                </div>
                                <h5 className={`text-xs font-black ${colors.text} uppercase tracking-widest`}>AI Findings</h5>
                              </div>
                              <ul className="space-y-3">
                                {clause.problem_detected.map((p, i) => (
                                  <li key={i} className="text-sm text-slate-800 flex items-start gap-3 font-bold tracking-tight">
                                    <div className={`mt-1.5 w-1.5 h-1.5 rounded-full ${colors.solid} shrink-0`} />
                                    {p}
                                  </li>
                                ))}
                              </ul>
                            </div>

                            <div className="bg-slate-900 rounded-3xl p-6 text-white shadow-xl">
                              <h5 className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-4">What to do now</h5>
                              <p className="text-md font-black mb-2 flex items-center gap-2 tracking-tight text-blue-300">
                                <Zap size={18} className="text-amber-400 fill-amber-400" />
                                {clause.recommendation.primary_action}
                              </p>
                              <div className="flex items-center gap-2 mt-4 pt-4 border-t border-white/10">
                                <span className="text-[10px] text-slate-500 uppercase font-black">Priority Level:</span>
                                <span className={`px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-widest ${
                                  clause.recommendation.priority.toLowerCase() === 'must fix' ? 'bg-rose-500' : 'bg-slate-700'
                                }`}>
                                  {clause.recommendation.priority}
                                </span>
                              </div>
                            </div>
                          </div>
                        </div>
                        
                        {clause.negotiation_language && (
                           <div className="mt-8 pt-8 border-t border-slate-200">
                             <div className="flex items-center justify-between mb-4">
                                <div className="flex items-center gap-2">
                                  <div className="p-1.5 bg-slate-200 rounded-lg">
                                    <Copy size={14} className="text-slate-600" />
                                  </div>
                                  <h5 className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Negotiation Toolkit</h5>
                                </div>
                                <Button 
                                  variant="outline" 
                                  size="sm" 
                                  onClick={() => copyToClipboard(clause.negotiation_language!.email_text, `neg-${index}`)}
                                  className="h-8 text-xs gap-1.5 rounded-xl border-slate-200"
                                >
                                  {copiedId === `neg-${index}` ? <Check size={14} className="text-emerald-600" /> : <Copy size={14} />}
                                  {copiedId === `neg-${index}` ? 'Copied' : 'Copy suggested text'}
                                </Button>
                             </div>
                             <div className="p-5 rounded-2xl bg-white border border-slate-200 text-slate-600 text-sm leading-relaxed font-bold italic shadow-inner">
                                "{clause.negotiation_language.email_text}"
                             </div>
                           </div>
                        )}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
