"use client";

import { useRef, type ReactNode } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { useGSAP } from "@gsap/react";
import { cn } from "@/lib/utils";
import { useReducedMotion } from "@/hooks/use-reduced-motion";

gsap.registerPlugin(ScrollTrigger, useGSAP);

type RevealProps = {
  children: ReactNode;
  className?: string;
  /** Hero o LCP: visible en el primer frame. Solo un desplazamiento corto. */
  priority?: boolean;
};

export function Reveal({ children, className, priority = false }: RevealProps) {
  const ref = useRef<HTMLDivElement>(null);
  const reduced = useReducedMotion();

  useGSAP(
    () => {
      if (reduced || !ref.current) return;

      if (priority) {
        gsap.fromTo(
          ref.current,
          { y: 8 },
          { y: 0, duration: 0.52, ease: "power3.out" },
        );
        return;
      }

      gsap.fromTo(
        ref.current,
        { y: 16 },
        {
          y: 0,
          duration: 0.52,
          ease: "power3.out",
          scrollTrigger: {
            trigger: ref.current,
            start: "top 88%",
          },
        },
      );
    },
    { scope: ref, dependencies: [reduced, priority] },
  );

  return (
    <div ref={ref} className={cn(className)}>
      {children}
    </div>
  );
}
