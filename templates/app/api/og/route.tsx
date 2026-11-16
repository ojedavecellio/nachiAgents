import { OgImage } from "@/lib/og";

export function GET() {
  return OgImage({ title: "Titulo del sitio" });
}
