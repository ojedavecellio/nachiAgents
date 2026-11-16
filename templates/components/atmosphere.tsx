"use client";

import { useReducedMotion } from "@/hooks/use-reduced-motion";

export function Atmosphere() {
  const reduced = useReducedMotion();

  return (
    <div aria-hidden className="pointer-events-none fixed inset-0 -z-10">
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top,var(--glow),transparent_55%)]" />
      {reduced ? null : (
        <div className="film-grain absolute inset-0 opacity-[0.035]" />
      )}
    </div>
  );
}
