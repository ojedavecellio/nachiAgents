import type { ReactNode } from "react";

type NavLink = {
  href: string;
  label: string;
};

type GlassNavProps = {
  logo: ReactNode;
  links: NavLink[];
};

export function GlassNav({ logo, links }: GlassNavProps) {
  return (
    <header className="pointer-events-none fixed inset-x-0 top-4 z-50 flex justify-center px-5 pt-[env(safe-area-inset-top)] sm:top-6">
      <nav className="glass-nav silver-rim pill pointer-events-auto flex items-center gap-1 px-2 py-2">
        <div className="px-3">{logo}</div>
        {links.map((link) => (
          <a
            key={link.href}
            href={link.href}
            className="rounded-full px-3 py-1.5 text-sm tracking-[0.04em] text-foreground/65 transition-colors duration-200 hover:text-foreground"
          >
            {link.label}
          </a>
        ))}
      </nav>
    </header>
  );
}
