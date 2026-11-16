import type { Metadata } from "next";

type SiteMetadataInput = {
  title: string;
  description: string;
  url: string;
  ogImage?: string;
};

export function siteMetadata(input: SiteMetadataInput): Metadata {
  const image = input.ogImage ?? "/api/og";

  return {
    metadataBase: new URL(input.url),
    title: input.title,
    description: input.description,
    openGraph: {
      title: input.title,
      description: input.description,
      url: input.url,
      images: [{ url: image, width: 1200, height: 630 }],
    },
    twitter: {
      card: "summary_large_image",
      title: input.title,
      description: input.description,
      images: [image],
    },
  };
}
