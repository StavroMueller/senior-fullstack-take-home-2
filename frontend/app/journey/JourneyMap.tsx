import Box from "@mui/material/Box";
import { Map as MapLibreMap } from "maplibre-gl";
import { useEffect, useRef } from "react";

const franceCenter: [number, number] = [2.4, 46.6];
const franceZoom = 5;
const openFreeMapStyle = "https://tiles.openfreemap.org/styles/liberty";

export function JourneyMap() {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;
    const map = new MapLibreMap({
      container: containerRef.current,
      style: openFreeMapStyle,
      center: franceCenter,
      zoom: franceZoom,
    });
    return () => map.remove();
  }, []);

  return (
    <Box
      ref={containerRef}
      role="region"
      aria-label="Journey map"
      sx={{ width: "100%", height: "100%" }}
    />
  );
}
