import type { ReactNode } from "react";
import { cn } from "@/lib/utils";
import { MailtoLink } from "@/components/mailto-link";

type SiteFooterProps = {
  logo?: ReactNode;
  note?: string;
  email?: string;
  /** Solo si el footer flota. El default es superficie sólida. */
  glass?: boolean;
};

export function SiteFooter({ logo, note, email, glass = false }: SiteFooterProps) {
  return (
    <footer
      className={cn(
        "mx-auto flex w-full max-w-6xl items-center justify-between gap-6 px-5 py-8 sm:px-8",
        glass
          ? "glass-chrome silver-rim rounded-3xl"
          : "rounded-[1rem] bg-elevated",
      )}
    >
      <div>{logo}</div>
      <div className="flex flex-col items-end gap-1 text-sm text-muted">
        {note ? <p>{note}</p> : null}
        {email ? <MailtoLink email={email} /> : null}
      </div>
    </footer>
  );
}
