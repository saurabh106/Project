"use client";

import { useState, useRef } from "react";
import { useAuth } from "@clerk/nextjs";
import { Upload, File, X, CheckCircle, Loader2 } from "lucide-react";
import { Button } from "./ui/button";
import { Card, CardContent } from "./ui/card";

export function FileUpload({ onSuccess }: { onSuccess?: () => void }) {
  const [file, setFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const [status, setStatus] = useState<"idle" | "success" | "error">("idle");
  const fileInputRef = useRef<HTMLInputElement>(null);
  const { getToken } = useAuth();

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const selectedFile = e.target.files[0];
      console.log("File selected:", selectedFile.name, selectedFile.type);
      if (selectedFile.type === "application/pdf") {
        setFile(selectedFile);
        setStatus("idle");
      } else {
        alert("Please select a PDF file.");
      }
    }
  };

  const handleUpload = async () => {
    if (!file) return;

    console.log("Starting upload for:", file.name);
    setUploading(true);
    setStatus("idle");
    
    try {
      const token = await getToken();
      if (!token) {
        console.error("No auth token available");
        setStatus("error");
        return;
      }

      const formData = new FormData();
      formData.append("contract", file);

      const response = await fetch("http://localhost:4000/api/contracts/upload", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
        body: formData,
      });

      const data = await response.json();
      console.log("Upload response:", response.status, data);

      if (response.ok) {
        setStatus("success");
        setFile(null);
        if (onSuccess) onSuccess();
      } else {
        setStatus("error");
        console.error("Upload failed server-side:", data.error);
      }
    } catch (error) {
      console.error("Upload request failed:", error);
      setStatus("error");
    } finally {
      setUploading(false);
    }
  };

  const triggerFileInput = () => {
    console.log("Triggering file input");
    fileInputRef.current?.click();
  };

  return (
    <Card className="border-dashed border-2 border-white/10 bg-slate-900/50 backdrop-blur-sm hover:border-blue-500/30 transition-all group">
      <CardContent className="p-8 flex flex-col items-center justify-center text-center">
        {!file ? (
          <>
            <div className="w-14 h-14 rounded-2xl bg-blue-600/10 flex items-center justify-center text-blue-500 mb-4 group-hover:scale-110 transition-transform">
              <Upload size={28} />
            </div>
            <h3 className="text-lg font-black text-white mb-1 tracking-tight">Upload Vault</h3>
            <p className="text-xs text-slate-500 mb-6 font-medium uppercase tracking-widest">Select legal PDF for AI processing</p>
            <input
              type="file"
              accept=".pdf"
              className="hidden"
              ref={fileInputRef}
              onChange={handleFileChange}
            />
            <Button variant="outline" className="cursor-pointer rounded-xl border-white/10 bg-slate-950/50 hover:bg-white/5 text-slate-300 font-bold px-8" onClick={triggerFileInput}>
              Browse Files
            </Button>
          </>
        ) : (
          <div className="w-full">
            <div className="flex items-center gap-3 p-4 bg-slate-950/50 rounded-2xl border border-blue-500/20 mb-6">
              <div className="w-10 h-10 rounded-xl bg-blue-500/10 flex items-center justify-center text-blue-400">
                <File size={20} />
              </div>
              <div className="flex-1 text-left">
                <p className="text-sm font-bold text-white truncate max-w-[150px]">{file.name}</p>
                <p className="text-[10px] text-slate-500 font-black uppercase tracking-widest">{(file.size / 1024 / 1024).toFixed(2)} MB</p>
              </div>
              <button 
                onClick={() => setFile(null)} 
                className="p-1.5 hover:bg-white/5 rounded-xl text-slate-500 hover:text-white transition-all"
                disabled={uploading}
              >
                <X size={18} />
              </button>
            </div>
            
            <Button 
              className="w-full rounded-xl bg-blue-600 hover:bg-blue-500 font-black uppercase tracking-widest text-[10px] py-6 shadow-lg shadow-blue-500/10" 
              onClick={handleUpload} 
              disabled={uploading}
            >
              {uploading ? (
                <>
                  <Loader2 className="mr-2 animate-spin" size={16} />
                  Processing...
                </>
              ) : (
                "Confirm & Analyze"
              )}
            </Button>
          </div>
        )}

        {status === "success" && (
          <div className="mt-4 flex flex-col items-center gap-2">
            <div className="flex items-center gap-2 text-emerald-400 text-xs font-black uppercase tracking-widest">
              <CheckCircle size={14} /> Vault Synchronized
            </div>
          </div>
        )}
        {status === "error" && (
          <div className="mt-4 text-rose-400 text-xs font-black uppercase tracking-widest">
            Synchronization Failed
          </div>
        )}
      </CardContent>
    </Card>
  );
}
