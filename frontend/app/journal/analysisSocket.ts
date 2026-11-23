import { Socket } from "phoenix";
import { useEffect } from "react";

const socketUrl = import.meta.env.VITE_SOCKET_URL ?? "ws://localhost:4000/socket";

let socket: Socket | undefined;

function connectedSocket() {
  socket ??= new Socket(socketUrl);
  socket.connect();
  return socket;
}

type JoinReply = { analysis_status: "analyzing" | "analyzed" | "analysis_failed" };

export function useAnalysisEnd(entryId: string, isAnalyzing: boolean, onAnalysisEnd: () => void) {
  useEffect(() => {
    if (!isAnalyzing) return;

    const channel = connectedSocket().channel(`entry:${entryId}`);
    channel.on("analysis_finished", onAnalysisEnd);
    channel.on("analysis_failed", onAnalysisEnd);
    channel.join().receive("ok", (reply: JoinReply) => {
      if (reply.analysis_status !== "analyzing") onAnalysisEnd();
    });

    return () => {
      channel.leave();
    };
  }, [entryId, isAnalyzing, onAnalysisEnd]);
}
