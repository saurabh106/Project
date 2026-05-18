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
    <Card className="border-dashed border-2 bg-slate-50/50">
      <CardContent className="p-8 flex flex-col items-center justify-center text-center">
        {!file ? (
          <>
            <div className="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 mb-4">
              <Upload size={24} />
            </div>
            <h3 className="text-lg font-bold mb-1">Upload Contract</h3>
            <p className="text-sm text-slate-500 mb-6">Drag and drop or click to select a PDF</p>
            <input
              type="file"
              accept=".pdf"
              className="hidden"
              ref={fileInputRef}
              onChange={handleFileChange}
            />
            <Button variant="outline" className="cursor-pointer" onClick={triggerFileInput}>
              Select PDF File
            </Button>
          </>
        ) : (
          <div className="w-full">
            <div className="flex items-center gap-3 p-4 bg-white rounded-xl border border-blue-200 mb-6">
              <div className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center text-blue-600">
                <File size={20} />
              </div>
              <div className="flex-1 text-left">
                <p className="text-sm font-bold truncate max-w-[200px]">{file.name}</p>
                <p className="text-xs text-slate-500">{(file.size / 1024 / 1024).toFixed(2)} MB</p>
              </div>
              <button 
                onClick={() => setFile(null)} 
                className="p-1 hover:bg-slate-100 rounded-full"
                disabled={uploading}
              >
                <X size={18} />
              </button>
            </div>
            
            <Button 
              className="w-full" 
              onClick={handleUpload} 
              disabled={uploading}
            >
              {uploading ? (
                <>
                  <Loader2 className="mr-2 animate-spin" size={18} />
                  Uploading...
                </>
              ) : (
                "Confirm Upload"
              )}
            </Button>
          </div>
        )}

        {status === "success" && (
          <div className="mt-4 flex flex-col items-center gap-2">
            <div className="flex items-center gap-2 text-emerald-600 text-sm font-bold">
              <CheckCircle size={16} /> Uploaded successfully!
            </div>
            <Button variant="ghost" size="sm" onClick={() => window.location.reload()}>
              Refresh List
            </Button>
          </div>
        )}
        {status === "error" && (
          <div className="mt-4 text-rose-600 text-sm font-bold">
            Upload failed. Please check the console for details.
          </div>
        )}
      </CardContent>
    </Card>
  );
}
