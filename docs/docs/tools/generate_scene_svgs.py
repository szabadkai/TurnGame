#!/usr/bin/env python3
"""
Generate simple SVG storyboard illustrations for each scene defined in
docs/scene_illustration_index.json. These are placeholder visuals that
match the file naming scheme (but as .svg) and include:
- Title, act, location, key visual
- A background color by act
- A minimal UI overlay bar with dialogue/choices placeholders

Outputs:
- docs/illustrations/<scene_xxx_*.svg>
- docs/illustrations/index.html (gallery)
- docs/illustrations/manifest.json (summary of outputs)

This is offline and does not require network or external deps.
"""
import json
import os
from pathlib import Path
from html import escape

ROOT = Path(__file__).resolve().parents[1]
INDEX_PATH = ROOT / "scene_illustration_index.json"
OUT_DIR = ROOT / "illustrations"

ACT_BG = {
    1: ("#0f1e33", "#1b2a4a"),  # dark blue gradient
    2: ("#1a0f33", "#2a1b4a"),  # dark purple gradient
    3: ("#331e0f", "#4a2a1b"),  # dark amber gradient
}

LOC_ICON = {
    "spaceship_bridge": "console",
    "alien_gateway": "portal",
    "space_battle": "stars",
    "archaeological_site": "ruins",
    "space_blockade": "stars",
    "bridge_temporal_anomaly": "timeline",
    "ancient_ruins": "ruins",
    "earth_command": "badge",
    "earth_command_corrupted": "warning",
    "earth_command_interrogation": "badge",
    "wreck_exterior": "stars",
    "debris_field": "stars",
    "prometheus_interior": "ruins",
    "orbital_station": "station",
    "abandoned_station": "station",
    "space_distortion": "timeline",
    "probe_recovery": "sat",
}

SVG_W, SVG_H = 800, 600


def make_icon(icon: str) -> str:
    # Minimal geometric motifs per icon keyword.
    if icon == "console":
        return """
        <g opacity="0.8">
          <rect x="80" y="180" width="180" height="100" rx="8" fill="#0af"/>
          <rect x="85" y="185" width="90" height="15" fill="#0ff" opacity="0.5"/>
          <rect x="85" y="205" width="70" height="10" fill="#0ff" opacity="0.4"/>
          <circle cx="250" cy="255" r="12" fill="#fff" opacity="0.4"/>
        </g>
        """
    if icon == "portal":
        return """
        <g opacity="0.75">
          <ellipse cx="200" cy="260" rx="90" ry="130" fill="none" stroke="#7af" stroke-width="6"/>
          <ellipse cx="200" cy="260" rx="70" ry="100" fill="none" stroke="#bdf" stroke-width="3"/>
          <circle cx="200" cy="260" r="20" fill="#9cf" opacity="0.5"/>
        </g>
        """
    if icon == "stars":
        stars = []
        for i in range(30):
            x = 400 + (i * 11) % 380
            y = 100 + (i * 37) % 420
            r = 1 + (i % 3)
            stars.append(f'<circle cx="{x}" cy="{y}" r="{r}" fill="#ccd" opacity="0.8"/>')
        return "<g>" + "".join(stars) + "</g>"
    if icon == "ruins":
        return """
        <g opacity="0.85">
          <polygon points="120,360 160,260 200,360" fill="#9ad"/>
          <rect x="180" y="300" width="16" height="60" fill="#bcd"/>
          <rect x="210" y="320" width="12" height="40" fill="#bcd"/>
          <path d="M110 370 L240 370" stroke="#def" stroke-width="4"/>
        </g>
        """
    if icon == "badge":
        return """
        <g opacity="0.85">
          <rect x="120" y="220" width="140" height="140" rx="12" fill="#2e7"/>
          <circle cx="190" cy="260" r="30" fill="#fff" opacity="0.7"/>
          <rect x="140" y="310" width="120" height="18" fill="#cfc" opacity="0.9"/>
        </g>
        """
    if icon == "warning":
        return """
        <g opacity="0.9">
          <polygon points="140,220 240,220 190,330" fill="#f66"/>
          <rect x="186" y="250" width="8" height="40" fill="#fff"/>
          <rect x="186" y="297" width="8" height="10" fill="#fff"/>
        </g>
        """
    if icon == "timeline":
        return """
        <g opacity="0.8">
          <rect x="110" y="240" width="180" height="6" fill="#8cf"/>
          <circle cx="120" cy="243" r="10" fill="#bdf"/>
          <circle cx="200" cy="243" r="10" fill="#bdf"/>
          <circle cx="280" cy="243" r="10" fill="#bdf"/>
          <path d="M110 280 C 180 200, 220 360, 290 280" stroke="#def" stroke-width="3" fill="none"/>
        </g>
        """
    if icon == "station":
        return """
        <g opacity="0.85">
          <circle cx="190" cy="270" r="40" fill="#ddd"/>
          <rect x="175" y="230" width="30" height="80" fill="#bbb"/>
          <rect x="160" y="250" width="60" height="12" fill="#eee"/>
        </g>
        """
    if icon == "sat":
        return """
        <g opacity="0.85">
          <rect x="180" y="250" width="20" height="40" fill="#ccc"/>
          <rect x="150" y="255" width="30" height="8" fill="#aaf"/>
          <rect x="200" y="255" width="30" height="8" fill="#aaf"/>
        </g>
        """
    return ""


def render_svg(scene: dict) -> str:
    title = escape(scene.get("title", "Untitled"))
    act = int(scene.get("act", 1))
    location = escape(scene.get("location", "unknown"))
    key_visual = escape(scene.get("key_visual", ""))
    bg1, bg2 = ACT_BG.get(act, ACT_BG[1])
    icon = LOC_ICON.get(location, "stars")
    icon_svg = make_icon(icon)

    # UI overlay
    ui = f"""
      <g>
        <rect x="40" y="440" width="720" height="120" rx="10" fill="#000" opacity="0.55"/>
        <rect x="50" y="450" width="700" height="50" rx="6" fill="#111" opacity="0.8"/>
        <text x="60" y="482" font-family="monospace" font-size="20" fill="#e6f0ff" opacity="0.95">
          {title}: {key_visual[:70]}
        </text>
        <g>
          <rect x="60" y="510" width="180" height="34" rx="6" fill="#1e90ff" opacity="0.85"/>
          <rect x="260" y="510" width="180" height="34" rx="6" fill="#2ecc71" opacity="0.85"/>
          <rect x="460" y="510" width="180" height="34" rx="6" fill="#e67e22" opacity="0.85"/>
        </g>
      </g>
    """

    return f"""
<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{SVG_W}\" height=\"{SVG_H}\" viewBox=\"0 0 {SVG_W} {SVG_H}\">
  <defs>
    <linearGradient id=\"bg\" x1=\"0\" y1=\"0\" x2=\"0\" y2=\"1\">
      <stop offset=\"0%\" stop-color=\"{bg1}\"/>
      <stop offset=\"100%\" stop-color=\"{bg2}\"/>
    </linearGradient>
  </defs>
  <rect width=\"100%\" height=\"100%\" fill=\"url(#bg)\"/>
  <text x=\"40\" y=\"60\" font-family=\"sans-serif\" font-size=\"28\" fill=\"#e6f0ff\" opacity=\"0.95\">{title}</text>
  <text x=\"40\" y=\"90\" font-family=\"monospace\" font-size=\"16\" fill=\"#c9d6ff\" opacity=\"0.9\">Act {act} · {location}</text>
  {icon_svg}
  {ui}
</svg>
"""


def ensure_out_dir():
    OUT_DIR.mkdir(parents=True, exist_ok=True)


def build_gallery(scenes: list):
    items = []
    for s in scenes:
        svg_name = Path(s["illustration_file"]).with_suffix(".svg").name
        title = escape(s.get("title", "Untitled"))
        items.append(f"<figure><img src=\"{svg_name}\" alt=\"{escape(title)}\"><figcaption>{title}</figcaption></figure>")

    html = f"""
<!doctype html>
<html lang="en">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Scene Illustrations (SVG Storyboards)</title>
<style>
  body {{ font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; background:#0b1220; color:#e6f0ff; margin:0; }}
  header {{ padding:16px 24px; border-bottom:1px solid #1e2a44; position:sticky; top:0; background:#0b1220; }}
  .grid {{ display:grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap:16px; padding:24px; }}
  figure {{ margin:0; background:#0f1a30; border:1px solid #1e2a44; border-radius:8px; overflow:hidden; }}
  img {{ width:100%; height:auto; display:block; background:#091020; }}
  figcaption {{ padding:8px 12px; font-size:14px; color:#c9d6ff; }}
  .meta {{ color:#9fb3ff; font-size:12px; }}
  a {{ color:#8ab4ff; }}
  footer {{ padding:16px 24px; color:#9fb3ff; }}
  .hint {{ font-size:12px; color:#9fb3ff; }}
  code {{ background:#101a33; padding:2px 6px; border-radius:4px; }}
</style>
<header>
  <h1 style="margin:0; font-size:18px;">The Exodus Protocol — Scene Storyboards (SVG)</h1>
  <div class="hint">Generated placeholders; replace with final pixel-art PNGs later.</div>
</header>
<main class="grid">
  {''.join(items)}
  </main>
<footer>
  <div class="meta">Generated by docs/tools/generate_scene_svgs.py</div>
  <div class="hint">Files saved alongside this page. Use index JSON to map scenes.</div>
</footer>
</html>
"""
    (OUT_DIR / "index.html").write_text(html, encoding="utf-8")


def main():
    ensure_out_dir()
    data = json.loads(INDEX_PATH.read_text(encoding="utf-8"))
    scenes = data.get("illustration_index", {}).get("scene_mapping", [])
    written = []
    for s in scenes:
        svg_name = Path(s["illustration_file"]).with_suffix(".svg").name
        svg = render_svg(s)
        (OUT_DIR / svg_name).write_text(svg, encoding="utf-8")
        written.append(svg_name)
    # Write manifest
    manifest = {
        "count": len(written),
        "files": written,
        "source_index": str(INDEX_PATH.relative_to(ROOT)),
    }
    (OUT_DIR / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    # Gallery
    build_gallery(scenes)


if __name__ == "__main__":
    main()

