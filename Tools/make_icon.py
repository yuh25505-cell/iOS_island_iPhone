import math
import struct
import sys
import zlib
from pathlib import Path

SIZE = 1024


def mix(a, b, t):
    return a + (b - a) * t


def clamp(x, lo=0.0, hi=1.0):
    return lo if x < lo else hi if x > hi else x


def cover(d):
    return clamp(0.5 - d)


def round_rect_dist(px, py, cx, cy, hw, hh, r):
    qx = abs(px - cx) - (hw - r)
    qy = abs(py - cy) - (hh - r)
    ox = max(qx, 0.0)
    oy = max(qy, 0.0)
    return math.hypot(ox, oy) + min(max(qx, qy), 0.0) - r


def blend(base, color, alpha):
    return (
        mix(base[0], color[0], alpha),
        mix(base[1], color[1], alpha),
        mix(base[2], color[2], alpha),
    )


def render():
    c = SIZE / 2.0
    tile_half = 260.0
    tile_r = 150.0
    sun = (c + 95.0, c + 85.0, 62.0)
    mound_cx, mound_cy, mound_rx, mound_ry = c, c - 210.0, 240.0, 150.0
    rows = []
    for y in range(SIZE):
        t = y / (SIZE - 1)
        row = bytearray()
        for x in range(SIZE):
            glow = clamp(1.0 - math.hypot(x - SIZE * 0.3, y - SIZE * 0.2) / (SIZE * 0.9))
            base = (
                mix(0.60, 0.88, t) + glow * 0.10,
                mix(0.72, 0.92, t) + glow * 0.08,
                mix(0.95, 0.99, t),
            )
            px = x + 0.5
            py = SIZE - (y + 0.5)
            d = round_rect_dist(px, py, c, c, tile_half, tile_half, tile_r)
            inside = cover(d)
            col = base
            if inside > 0:
                col = blend(col, (1.0, 1.0, 1.0), 0.34 * inside)
            rim = cover(abs(d + 3.0) - 3.0)
            if rim > 0:
                col = blend(col, (1.0, 1.0, 1.0), 0.75 * rim)
            if inside > 0:
                ex = (px - mound_cx) / mound_rx
                ey = (py - mound_cy) / mound_ry
                k = math.sqrt(ex * ex + ey * ey)
                dm = (k - 1.0) * min(mound_rx, mound_ry)
                col = blend(col, (1.0, 1.0, 1.0), 0.96 * cover(dm) * inside)
                ds = math.hypot(px - sun[0], py - sun[1]) - sun[2]
                col = blend(col, (1.0, 1.0, 1.0), 0.96 * cover(ds) * inside)
            row.extend(
                (
                    int(clamp(col[0]) * 255 + 0.5),
                    int(clamp(col[1]) * 255 + 0.5),
                    int(clamp(col[2]) * 255 + 0.5),
                )
            )
        rows.append(b"\x00" + bytes(row))
    return b"".join(rows)


def chunk(tag, data):
    body = tag + data
    return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)


def write_png(path, raw):
    header = struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0)
    data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + chunk(b"IDAT", zlib.compress(raw, 6)) + chunk(b"IEND", b"")
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(data)


if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "AppIcon.png"
    write_png(target, render())
    print("icon written:", target)
