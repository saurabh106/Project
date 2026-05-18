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
  AlertCircle
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "./ui/card";
import { Button } from "./ui/button";

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

export function ContractAnalysis({ data }: { data: any }) {
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
      case "CRITICAL": return "text-rose-600 bg-rose-50 border-rose-100";
      case "HIGH": return "text-orange-600 bg-orange-50 border-orange-100";
      case "MEDIUM": return "text-amber-600 bg-amber-50 border-amber-100";
      default: return "text-emerald-600 bg-emerald-50 border-emerald-100";
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      {/* Executive Summary */}
      <div className="grid md:grid-cols-3 gap-6">
        <Card className="md:col-span-2 border-slate-200 shadow-sm">
          <CardHeader className="pb-4">
            <div className="flex justify-between items-start">
              <div>
                <CardTitle className="text-2xl font-bold text-slate-900">{data.contract_type} Analysis</CardTitle>
                <CardDescription>AI-generated risk assessment and clause breakdown</CardDescription>
              </div>
              <div className={`px-4 py-2 rounded-xl border font-bold text-lg ${getRiskColor(data.overall_risk_level)}`}>
                Score: {data.overall_risk_score}/100
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-2">
              <div className="p-3 rounded-xl bg-rose-50 border border-rose-100 text-center">
                <p className="text-xs font-bold text-rose-600 uppercase mb-1">Critical</p>
                <p className="text-2xl font-black text-rose-700">{data.summary.critical_issues}</p>
              </div>
              <div className="p-3 rounded-xl bg-orange-50 border border-orange-100 text-center">
                <p className="text-xs font-bold text-orange-600 uppercase mb-1">High</p>
                <p className="text-2xl font-black text-orange-700">{data.summary.high_risk}</p>
              </div>
              <div className="p-3 rounded-xl bg-amber-50 border border-amber-100 text-center">
                <p className="text-xs font-bold text-amber-600 uppercase mb-1">Medium</p>
                <p className="text-2xl font-black text-amber-700">{data.summary.medium_risk}</p>
              </div>
              <div className="p-3 rounded-xl bg-emerald-50 border border-emerald-100 text-center">
                <p className="text-xs font-bold text-emerald-600 uppercase mb-1">Low</p>
                <p className="text-2xl font-black text-emerald-700">{data.summary.low_risk}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-slate-900 text-white border-none shadow-xl relative overflow-hidden">
          <div className="absolute top-0 right-0 p-4 opacity-10">
            <TrendingUp size={80} />
          </div>
          <CardHeader>
            <CardTitle className="text-lg">Recommendation</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm font-medium text-slate-300 mb-4">{data.final_recommendation.decision}</p>
            <div className="space-y-2">
              {data.final_recommendation.next_steps.map((step, i) => (
                <div key={i} className="flex items-start gap-2 text-xs">
                  <CheckCircle2 size={14} className="text-emerald-400 mt-0.5 shrink-0" />
                  <span>{step}</span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Clause Analysis */}
      <div className="space-y-4">
        <h3 className="text-xl font-bold text-slate-900 flex items-center gap-2">
          <FileText size={22} className="text-blue-600" />
          Detailed Clause Analysis
        </h3>
        
        {data.clauses.map((clause, index) => (
          <Card key={index} className="border-slate-200 overflow-hidden group">
            <div className="flex flex-col lg:flex-row">
              {/* Risk Indicator Side */}
              <div className={`lg:w-2 shrink-0 ${
                clause.risk_level === 'CRITICAL' ? 'bg-rose-500' : 
                clause.risk_level === 'HIGH' ? 'bg-orange-500' : 
                clause.risk_level === 'MEDIUM' ? 'bg-amber-500' : 'bg-emerald-500'
              }`} />
              
              <div className="flex-1 p-6">
                <div className="flex flex-wrap justify-between items-start gap-4 mb-6">
                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-xs font-bold text-slate-400 uppercase tracking-widest">Section {clause.section}</span>
                      <span className={`px-2 py-0.5 rounded text-[10px] font-bold border ${getRiskColor(clause.risk_level)}`}>
                        {clause.risk_level}
                      </span>
                    </div>
                    <h4 className="text-lg font-bold text-slate-900">{clause.title}</h4>
                  </div>
                  <div className="text-right">
                    <p className="text-xs font-medium text-slate-500 mb-1">Category</p>
                    <p className="text-sm font-bold text-slate-700">{clause.category}</p>
                  </div>
                </div>

                <div className="grid lg:grid-cols-2 gap-8">
                  {/* Left Column: Understanding */}
                  <div className="space-y-4">
                    <div className="bg-slate-50 rounded-xl p-4 border border-slate-100">
                      <h5 className="text-xs font-bold text-slate-500 uppercase mb-3 flex items-center gap-1.5">
                        <Info size={14} /> Plain English
                      </h5>
                      <p className="text-sm text-slate-800 leading-relaxed font-medium">
                        {clause.plain_english.simple_explanation}
                      </p>
                    </div>

                    <div className="bg-blue-50/30 rounded-xl p-4 border border-blue-100/50">
                      <h5 className="text-xs font-bold text-blue-600 uppercase mb-3 flex items-center gap-1.5">
                        <AlertCircle size={14} /> Business Impact
                      </h5>
                      <p className="text-sm text-slate-700 leading-relaxed">
                        {clause.plain_english.business_impact}
                      </p>
                    </div>
                  </div>

                  {/* Right Column: Problem & Action */}
                  <div className="space-y-4">
                    <div className="p-4 rounded-xl border border-rose-100 bg-rose-50/20">
                      <h5 className="text-xs font-bold text-rose-600 uppercase mb-3 flex items-center gap-1.5">
                        <ShieldAlert size={14} /> Problems Detected
                      </h5>
                      <ul className="space-y-2">
                        {clause.problem_detected.map((p, i) => (
                          <li key={i} className="text-sm text-slate-700 flex items-start gap-2">
                            <div className="w-1.5 h-1.5 rounded-full bg-rose-400 mt-1.5 shrink-0" />
                            {p}
                          </li>
                        ))}
                      </ul>
                    </div>

                    <div className="p-4 rounded-xl border border-slate-200 bg-white">
                      <h5 className="text-xs font-bold text-slate-500 uppercase mb-3">Action Required</h5>
                      <p className="text-sm font-bold text-slate-900 mb-1">{clause.recommendation.primary_action}</p>
                      <p className="text-xs text-slate-500 italic">Priority: {clause.recommendation.priority}</p>
                    </div>
                  </div>
                </div>
                
                {clause.negotiation_language && (
                   <div className="mt-6 pt-6 border-t border-slate-100">
                     <h5 className="text-xs font-bold text-slate-500 uppercase mb-3">Suggested Negotiation Text</h5>
                     <div className="p-4 rounded-lg bg-slate-900 text-slate-300 text-xs font-mono relative group/code">
                        {clause.negotiation_language.email_text}
                        <button 
                          onClick={() => navigator.clipboard.writeText(clause.negotiation_language!.email_text)}
                          className="absolute top-2 right-2 p-1.5 bg-slate-800 hover:bg-slate-700 rounded text-slate-100 opacity-0 group-hover/code:opacity-100 transition-opacity"
                        >
                          Copy
                        </button>
                     </div>
                   </div>
                )}
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
