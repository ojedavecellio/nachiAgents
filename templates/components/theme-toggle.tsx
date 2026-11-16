"use client";

import { useEffect, useState } from "react";

export function ThemeToggle() {
  const [theme, setTheme] = useState<"dark" | "light">("dark");

  useEffect(() => {
    const current =
      document.documentElement.dataset.theme === "light" ? "light" : "dark";
    setTheme(current);
  }, []);

  function toggle() {
    const next = theme === "dark" ? "light" : "dark";
    if (next === "light") document.documentElement.dataset.theme = "light";
    else delete document.documentElement.dataset.theme;
    setTheme(next);
  }

  return (
    <button
      type="button"
      onClick={toggle}
      className="glass-nav silver-rim pill inline-flex h-10 items-center px-4 text-sm text-foreground"
    >
      {theme === "dark" ? "Claro" : "Oscuro"}
    </button>
  );
}
