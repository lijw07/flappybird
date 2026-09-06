import random
from pathlib import Path

from PIL import Image

STRIP_WIDTH = 768
TILE_HEIGHT = 32
WAVE_PERIOD = 16
SHADOW_BLOCK = 16
SEED = 7

OUTLINE = (12, 46, 68, 255)
GRASS_LIGHT = (153, 230, 95, 255)
GRASS = (90, 197, 79, 255)
GRASS_DARK = (51, 152, 75, 255)
DIRT_RAMP = [(224, 116, 56, 255), (198, 69, 36, 255), (142, 37, 29, 255), (57, 31, 33, 255)]

GRASS_COLUMN = [OUTLINE, GRASS_LIGHT, GRASS, GRASS, GRASS, OUTLINE]
DIRT_BAND_ROWS = range(6, 9)
WAVE_TRANSITION_ROW = 9
WAVE_TRANSITION = "..mmmmm..mmmmmm."
WAVE_ROWS = ["...mmm....mmmm..", "................", "mm.....mm......m", "..m...m..m....m."]

TUFT = ["...lllll", ".....ll.", ".d......", "dddggggd", "Odddggd.", ".OOddOO.", "...OO..."]
TUFT_TOP_ROW = 2
NOTCHES = [["dgd", "OOO"], ["dggd", "OOOO"]]
NOTCH_TOP_ROW = 5
BUSH = ["....OO....", "..OOggO...", "OdggggO.OO", "dddgggO.Og", "OdOddOdO..", ".OmOOmO..."]
BUSH_TOP_ROW = 8

GLYPHS = {"O": OUTLINE, "l": GRASS_LIGHT, "g": GRASS, "d": GRASS_DARK, "m": DIRT_RAMP[1]}

SHADOW_STEPS = [None, 27, 23, 19]
DEEP_SHADOW_OFFSET = 8
TUFT_SPACING = (40, 90)
NOTCH_SPACING = (24, 70)
BUSH_SPACING = (110, 260)


def main() -> None:
    random.seed(SEED)
    image = Image.new("RGBA", (STRIP_WIDTH, TILE_HEIGHT))
    pixels = image.load()
    occupied = []
    paint_base(pixels)
    paint_shadows(pixels)
    scatter(pixels, occupied, [TUFT], TUFT_TOP_ROW, TUFT_SPACING)
    scatter(pixels, occupied, [BUSH], BUSH_TOP_ROW, BUSH_SPACING)
    scatter(pixels, occupied, NOTCHES, NOTCH_TOP_ROW, NOTCH_SPACING)
    output = Path(__file__).resolve().parent.parent / "assets" / "sprites" / "ground.png"
    image.save(output)


def paint_base(pixels) -> None:
    for x in range(STRIP_WIDTH):
        for y, color in enumerate(GRASS_COLUMN):
            pixels[x, y] = color
        for y in DIRT_BAND_ROWS:
            pixels[x, y] = DIRT_RAMP[1]
        pixels[x, WAVE_TRANSITION_ROW] = wave_color(WAVE_TRANSITION, x)
        for y in range(WAVE_TRANSITION_ROW + 1, TILE_HEIGHT):
            pixels[x, y] = wave_color(WAVE_ROWS[(y - WAVE_TRANSITION_ROW - 1) % len(WAVE_ROWS)], x)


def wave_color(row_pattern: str, x: int) -> tuple:
    return DIRT_RAMP[1] if row_pattern[x % WAVE_PERIOD] == "m" else DIRT_RAMP[0]


def paint_shadows(pixels) -> None:
    step = random.randrange(len(SHADOW_STEPS))
    for block_start in range(0, STRIP_WIDTH, SHADOW_BLOCK):
        step = max(0, min(len(SHADOW_STEPS) - 1, step + random.choice((-1, 0, 0, 1))))
        start_row = SHADOW_STEPS[step]
        if start_row is None:
            continue
        for x in range(block_start, block_start + SHADOW_BLOCK):
            for y in range(start_row, TILE_HEIGHT):
                darken(pixels, x, y)
            for y in range(start_row + DEEP_SHADOW_OFFSET, TILE_HEIGHT):
                darken(pixels, x, y)


def darken(pixels, x: int, y: int) -> None:
    level = DIRT_RAMP.index(pixels[x, y])
    pixels[x, y] = DIRT_RAMP[min(level + 1, len(DIRT_RAMP) - 1)]


def scatter(pixels, occupied: list, sprites: list, top_row: int, spacing: tuple) -> None:
    x = random.randrange(*spacing)
    while x < STRIP_WIDTH:
        sprite = random.choice(sprites)
        span = (x, x + len(sprite[0]))
        if span[1] <= STRIP_WIDTH and not overlaps(span, occupied):
            stamp(pixels, sprite, x, top_row)
            occupied.append(span)
        x += random.randrange(*spacing)


def overlaps(span: tuple, occupied: list) -> bool:
    return any(span[0] < end and start < span[1] for start, end in occupied)


def stamp(pixels, sprite: list, left: int, top: int) -> None:
    for dy, row in enumerate(sprite):
        for dx, glyph in enumerate(row):
            if glyph in GLYPHS:
                pixels[left + dx, top + dy] = GLYPHS[glyph]


if __name__ == "__main__":
    main()
