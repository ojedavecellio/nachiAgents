import { ImageResponse } from "next/og";

type OgImageInput = {
  title: string;
  eyebrow?: string;
};

export function OgImage({ title, eyebrow }: OgImageInput) {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "flex-end",
          background: "#07080a",
          color: "#f2f2f0",
          padding: 72,
        }}
      >
        {eyebrow ? (
          <div
            style={{
              fontSize: 22,
              letterSpacing: 1.5,
              color: "#9aa4ae",
              marginBottom: 16,
            }}
          >
            {eyebrow}
          </div>
        ) : null}
        <div
          style={{
            fontSize: 68,
            fontWeight: 500,
            letterSpacing: -1.5,
            lineHeight: 1.1,
            maxWidth: 900,
          }}
        >
          {title}
        </div>
      </div>
    ),
    { width: 1200, height: 630 },
  );
}
