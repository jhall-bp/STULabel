#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# ///
"""Generate STULabel's UnicodeCodePointProperties lookup tables.

The generated tables use STULabel's historical compact lookup layout:

* U+0000..U+D7FF: 2-stage table with 32-code-point leaf blocks.
* U+D800..U+1FFFF: 3-stage table with 8-code-point leaf blocks and groups of
  16 leaf indices (128 code points) in the middle stage.
* U+20000..U+10FFFF was historically handled by compact hard-coded rules and
  therefore is intentionally not represented in these tables.

The property byte layout matches UnicodeCodePointProperties.hpp:

    bits 0..1  BidiStrongType
    bit  2     isIgnorable
    bit  3     isWhitespace
    bits 4..7  GraphemeClusterCategory

By default the script downloads the required UCD files for Unicode 17.0.0 into
an on-disk cache. Pass --ucd-dir to use an already unpacked UCD tree instead.

Python 3.11+ is required. The code is written to type-check cleanly with strict
mypy/pyright settings without third-party runtime dependencies.
"""

from __future__ import annotations

import argparse
import hashlib
import sys
import urllib.error
import urllib.request
from collections.abc import Iterable, Iterator, Sequence
from dataclasses import dataclass
from enum import IntEnum
from pathlib import Path
from typing import Final, NewType, TypeAlias, TypeVar

CodePoint = NewType("CodePoint", int)
PropertyByte = NewType("PropertyByte", int)
BlockIndex = NewType("BlockIndex", int)

MAX_UNICODE: Final[int] = 0x10FFFF
TABLE1_END: Final[int] = 0xD800  # exclusive
TABLE2_END: Final[int] = 0x20000  # exclusive
LEAF1_SIZE: Final[int] = 32
LEAF2_SIZE: Final[int] = 8
MIDDLE_BLOCK_SIZE: Final[int] = 16

DEFAULT_UNICODE_VERSION: Final[str] = "17.0.0"


class BidiStrongType(IntEnum):
    NONE = 0
    LTR = 1
    RTL = 2
    ISOLATE = 3


class GraphemeClusterCategory(IntEnum):
    OTHER = 0
    CONTROL_CR = 1
    CONTROL_LF = 2
    CONTROL_OTHER = 3
    PREPEND = 4
    SPACING_MARK = 5
    EXTEND = 6
    ZWJ = 7
    REGIONAL_INDICATOR = 8
    EXTENDED_PICTOGRAPHIC = 9
    HANGUL_LVT = 10
    HANGUL_LV = 11
    HANGUL_L = 12
    HANGUL_V = 13
    HANGUL_T = 14


BIDI_STRONG_BY_UCD: Final[dict[str, BidiStrongType]] = {
    "L": BidiStrongType.LTR,
    "Left_To_Right": BidiStrongType.LTR,
    "R": BidiStrongType.RTL,
    "Right_To_Left": BidiStrongType.RTL,
    "AL": BidiStrongType.RTL,
    "Arabic_Letter": BidiStrongType.RTL,
    "LRI": BidiStrongType.ISOLATE,
    "Left_To_Right_Isolate": BidiStrongType.ISOLATE,
    "RLI": BidiStrongType.ISOLATE,
    "Right_To_Left_Isolate": BidiStrongType.ISOLATE,
    "FSI": BidiStrongType.ISOLATE,
    "First_Strong_Isolate": BidiStrongType.ISOLATE,
    "PDI": BidiStrongType.ISOLATE,
    "Pop_Directional_Isolate": BidiStrongType.ISOLATE,
}

GCB_BY_UCD: Final[dict[str, GraphemeClusterCategory]] = {
    "Other": GraphemeClusterCategory.OTHER,
    "Control": GraphemeClusterCategory.CONTROL_OTHER,
    "CR": GraphemeClusterCategory.CONTROL_CR,
    "LF": GraphemeClusterCategory.CONTROL_LF,
    "Prepend": GraphemeClusterCategory.PREPEND,
    "SpacingMark": GraphemeClusterCategory.SPACING_MARK,
    "Extend": GraphemeClusterCategory.EXTEND,
    "ZWJ": GraphemeClusterCategory.ZWJ,
    "Regional_Indicator": GraphemeClusterCategory.REGIONAL_INDICATOR,
    "LVT": GraphemeClusterCategory.HANGUL_LVT,
    "LV": GraphemeClusterCategory.HANGUL_LV,
    "L": GraphemeClusterCategory.HANGUL_L,
    "V": GraphemeClusterCategory.HANGUL_V,
    "T": GraphemeClusterCategory.HANGUL_T,
}

# These were grapheme-break values in the ICU 62 / Unicode 11 era. STULabel's
# tests require them only in Apple's private-use range U+F7F3..<U+F900.
LEGACY_EMOJI_GCB: Final[frozenset[str]] = frozenset(
    {"E_Base", "E_Base_GAZ", "E_Modifier", "Glue_After_Zwj", "Glue_After_ZWJ"}
)

# The public UCD does not contain Apple's private-use assignments.
# These full property-byte overrides are the Apple PUA values present in the
# checked-in ICU 62.1-derived STULabel table. Keeping them explicit makes the
# generator reproducible without requiring a particular historical Apple OS.
APPLE_PUA_PROPERTY_OVERRIDES: Final[tuple[tuple[int, int, int], ...]] = (
    # ICU treats the first three Apple private-use assignments as
    # other-neutral, while the UCD marks the whole BMP PUA as left-to-right.
    (0xF7F0, 0xF7F2, 0x00),
    (0xF7F3, 0xF86F, 0x00),
    (0xF870, 0xF87F, 0x60),
    (0xF880, 0xF881, 0x01),
    (0xF882, 0xF883, 0x02),
    (0xF884, 0xF899, 0x60),
    (0xF89A, 0xF89E, 0x02),
    (0xF89F, 0xF89F, 0x60),
    (0xF8A0, 0xF8A1, 0x00),
    (0xF8A2, 0xF8AC, 0x01),
    (0xF8AD, 0xF8B1, 0x00),
    (0xF8B2, 0xF8B3, 0x01),
    (0xF8B4, 0xF8B7, 0x00),
    (0xF8B8, 0xF8B8, 0x01),
    (0xF8B9, 0xF8C0, 0x00),
    (0xF8C1, 0xF8D6, 0x01),
    (0xF8D7, 0xF8FF, 0x00),
)


@dataclass(frozen=True, slots=True)
class RangeValue:
    start: int
    end: int  # inclusive
    value: str


@dataclass(frozen=True, slots=True)
class SourceFiles:
    derived_bidi_class: Path
    derived_core_properties: Path
    prop_list: Path
    grapheme_break_property: Path
    emoji_data: Path


@dataclass(frozen=True, slots=True)
class Tables:
    indices: tuple[int, ...]
    data1: tuple[int, ...]
    indices1: tuple[int, ...]
    indices2: tuple[int, ...]
    data2: tuple[int, ...]


@dataclass(frozen=True, slots=True)
class PropertySources:
    bidi: tuple[RangeValue, ...]
    whitespace: tuple[RangeValue, ...]
    default_ignorable: tuple[RangeValue, ...]
    grapheme_break: tuple[RangeValue, ...]
    extended_pictographic: tuple[RangeValue, ...]


T = TypeVar("T", bound=tuple[int, ...])
Block: TypeAlias = tuple[int, ...]


def _parse_code_point_range(text: str) -> tuple[int, int]:
    token = text.strip()
    if ".." in token:
        first, last = token.split("..", 1)
        return int(first, 16), int(last, 16)
    value = int(token, 16)
    return value, value


def _parse_property_file(path: Path, *, include_missing: bool = False) -> tuple[RangeValue, ...]:
    """Parse UCD `range ; value` records.

    When include_missing is true, `# @missing: range; value` directives are
    included *before* explicit records so later records override them during
    materialization.
    """
    missing: list[RangeValue] = []
    explicit: list[RangeValue] = []

    for raw_line in path.read_text(encoding="utf-8").splitlines():
        stripped = raw_line.strip()
        if include_missing and stripped.startswith("# @missing:"):
            body = stripped.removeprefix("# @missing:").strip()
            fields = [field.strip() for field in body.split(";")]
            if len(fields) >= 2:
                start, end = _parse_code_point_range(fields[0])
                missing.append(RangeValue(start, end, fields[1]))
            continue

        data, _, _comment = raw_line.partition("#")
        data = data.strip()
        if not data:
            continue
        fields = [field.strip() for field in data.split(";")]
        if len(fields) < 2:
            raise ValueError(f"Malformed UCD record in {path}: {raw_line!r}")
        start, end = _parse_code_point_range(fields[0])
        explicit.append(RangeValue(start, end, fields[1]))

    return tuple([*missing, *explicit])


def _filter_property(records: Sequence[RangeValue], property_name: str) -> tuple[RangeValue, ...]:
    return tuple(record for record in records if record.value == property_name)


def _materialize_values(
    records: Sequence[RangeValue],
    *,
    limit: int,
    default: str,
) -> list[str]:
    values = [default] * limit
    for record in records:
        if record.start >= limit:
            continue
        start = max(record.start, 0)
        end = min(record.end, limit - 1)
        for cp in range(start, end + 1):
            values[cp] = record.value
    return values


def _materialize_bool(records: Sequence[RangeValue], *, limit: int) -> bytearray:
    values = bytearray(limit)
    for record in records:
        if record.start >= limit:
            continue
        start = max(record.start, 0)
        end = min(record.end, limit - 1)
        values[start : end + 1] = b"\x01" * (end - start + 1)
    return values


def load_property_sources(files: SourceFiles) -> PropertySources:
    bidi = _parse_property_file(files.derived_bidi_class, include_missing=True)

    derived_core = _parse_property_file(files.derived_core_properties)
    prop_list = _parse_property_file(files.prop_list)
    gcb = _parse_property_file(files.grapheme_break_property, include_missing=True)
    emoji = _parse_property_file(files.emoji_data)

    return PropertySources(
        bidi=bidi,
        whitespace=_filter_property(prop_list, "White_Space"),
        default_ignorable=_filter_property(derived_core, "Default_Ignorable_Code_Point"),
        grapheme_break=gcb,
        extended_pictographic=_filter_property(emoji, "Extended_Pictographic"),
    )


def _is_iso_control(cp: int) -> bool:
    return cp <= 0x1F or 0x7F <= cp <= 0x9F


def build_property_bytes(sources: PropertySources, *, limit: int = TABLE2_END) -> bytes:
    if not 0 <= limit <= MAX_UNICODE + 1:
        raise ValueError(f"invalid code-point limit: {limit:#x}")

    bidi = _materialize_values(sources.bidi, limit=limit, default="L")
    whitespace = _materialize_bool(sources.whitespace, limit=limit)
    ignorable = _materialize_bool(sources.default_ignorable, limit=limit)
    gcb = _materialize_values(sources.grapheme_break, limit=limit, default="Other")
    pictographic = _materialize_bool(sources.extended_pictographic, limit=limit)

    result = bytearray(limit)
    for cp in range(limit):
        strong = BIDI_STRONG_BY_UCD.get(bidi[cp], BidiStrongType.NONE)

        is_whitespace = bool(whitespace[cp])
        is_ignorable = (
            bool(ignorable[cp])
            or (_is_iso_control(cp) and not is_whitespace)
            or 0xFFF9 <= cp <= 0xFFFB
        )

        gcb_name = gcb[cp]
        if gcb_name == "Other":
            category = (
                GraphemeClusterCategory.EXTENDED_PICTOGRAPHIC
                if pictographic[cp]
                else GraphemeClusterCategory.OTHER
            )
        elif gcb_name in LEGACY_EMOJI_GCB:
            if not 0xF7F3 <= cp < 0xF900:
                raise ValueError(
                    f"legacy grapheme-break value {gcb_name!r} outside Apple's PUA at U+{cp:04X}"
                )
            category = (
                GraphemeClusterCategory.EXTEND
                if gcb_name == "E_Modifier"
                else GraphemeClusterCategory.EXTENDED_PICTOGRAPHIC
            )
        else:
            try:
                category = GCB_BY_UCD[gcb_name]
            except KeyError as exc:
                raise ValueError(f"unsupported Grapheme_Cluster_Break value {gcb_name!r} at U+{cp:04X}") from exc

        value = int(strong)
        if is_ignorable:
            value |= 1 << 2
        if is_whitespace:
            value |= 1 << 3
        value |= int(category) << 4

        if not 0 <= value <= 0xFF:
            raise AssertionError(f"property byte overflow at U+{cp:04X}: {value:#x}")
        result[cp] = value

    # Replace the public-UCD defaults with the historical Apple ICU properties.
    for start, end, value in APPLE_PUA_PROPERTY_OVERRIDES:
        if start >= limit:
            continue
        clipped_end = min(end, limit - 1)
        result[start : clipped_end + 1] = bytes([value]) * (clipped_end - start + 1)

    return bytes(result)


def _chunks(values: Sequence[int], size: int) -> Iterator[Block]:
    if size <= 0:
        raise ValueError("chunk size must be positive")
    if len(values) % size != 0:
        raise ValueError(f"sequence length {len(values)} is not divisible by block size {size}")
    for start in range(0, len(values), size):
        yield tuple(int(v) for v in values[start : start + size])


def _intern_blocks(blocks: Iterable[Block]) -> tuple[tuple[int, ...], tuple[int, ...]]:
    """Intern equal blocks in first-seen order.

    Returns (indices, flattened_unique_blocks). First-seen ordering is
    important: it reproduces the historical generated arrays exactly.
    """
    block_to_index: dict[Block, int] = {}
    unique: list[Block] = []
    indices: list[int] = []

    for block in blocks:
        index = block_to_index.get(block)
        if index is None:
            index = len(unique)
            if index > 0xFF:
                raise ValueError(
                    "more than 256 unique blocks; UInt8 indices cannot represent this table layout"
                )
            block_to_index[block] = index
            unique.append(block)
        indices.append(index)

    flattened = tuple(value for block in unique for value in block)
    return tuple(indices), flattened


def build_tables(properties: bytes) -> Tables:
    if len(properties) < TABLE2_END:
        raise ValueError(
            f"need property bytes through U+{TABLE2_END - 1:04X}; got {len(properties)} bytes"
        )

    # U+0000..U+D7FF: one byte in `indices` selects a unique 32-byte leaf.
    indices, data1 = _intern_blocks(_chunks(properties[:TABLE1_END], LEAF1_SIZE))

    # U+D800..U+1FFFF: first deduplicate 8-byte leaves. The resulting raw
    # leaf-index stream has one element per 8 code points.
    leaf_indices, data2 = _intern_blocks(_chunks(properties[TABLE1_END:TABLE2_END], LEAF2_SIZE))

    # Then deduplicate groups of 16 leaf indices. One `indices1` entry covers
    # 16 * 8 = 128 code points; `indices2` stores the unique middle blocks.
    indices1, indices2 = _intern_blocks(_chunks(leaf_indices, MIDDLE_BLOCK_SIZE))

    tables = Tables(indices=indices, data1=data1, indices1=indices1, indices2=indices2, data2=data2)
    _validate_uint8_tables(tables)
    return tables


def _validate_uint8_tables(tables: Tables) -> None:
    for name, values in (
        ("indices", tables.indices),
        ("data1", tables.data1),
        ("indices1", tables.indices1),
        ("indices2", tables.indices2),
        ("data2", tables.data2),
    ):
        bad = next((value for value in values if not 0 <= value <= 0xFF), None)
        if bad is not None:
            raise ValueError(f"{name} contains non-UInt8 value {bad}")

    expected_indices = TABLE1_END // LEAF1_SIZE
    expected_indices1 = (TABLE2_END - TABLE1_END) // (LEAF2_SIZE * MIDDLE_BLOCK_SIZE)
    if len(tables.indices) != expected_indices:
        raise AssertionError((len(tables.indices), expected_indices))
    if len(tables.indices1) != expected_indices1:
        raise AssertionError((len(tables.indices1), expected_indices1))
    if len(tables.data1) % LEAF1_SIZE != 0:
        raise AssertionError("data1 is not a whole number of leaf blocks")
    if len(tables.indices2) % MIDDLE_BLOCK_SIZE != 0:
        raise AssertionError("indices2 is not a whole number of middle blocks")
    if len(tables.data2) % LEAF2_SIZE != 0:
        raise AssertionError("data2 is not a whole number of leaf blocks")


def lookup_tables(tables: Tables, cp: int) -> int:
    """Historical table/hard-coded lookup, useful for generator verification."""
    if cp < 0:
        return 0
    if cp < TABLE1_END:
        i0 = cp >> 5
        i1 = (cp & 31) + (tables.indices[i0] << 5)
        return tables.data1[i1]
    if cp < TABLE2_END:
        x = cp - TABLE1_END
        i0 = x >> 7
        i1 = ((x >> 3) & 15) + (tables.indices1[i0] << 4)
        i2 = (x & 7) + (tables.indices2[i1] << 3)
        return tables.data2[i2]
    if cp <= MAX_UNICODE:
        if 0xE0000 <= cp <= 0xE0FFF:
            return 0x64 if (0xE0020 <= cp <= 0xE007F) or (0xE0100 <= cp <= 0xE01EF) else 0x34
        return int((cp & 0xFFFF) <= 0xFFFD)
    return 0


def verify_table_round_trip(properties: bytes, tables: Tables) -> None:
    for cp, expected in enumerate(properties[:TABLE2_END]):
        actual = lookup_tables(tables, cp)
        if actual != expected:
            raise AssertionError(
                f"table round-trip failed at U+{cp:04X}: expected {expected:#04x}, got {actual:#04x}"
            )


def verify_historical_tail(sources: PropertySources) -> None:
    """Check the old U+20000..U+10FFFF hard-coded shortcut against input UCD.

    This is intentionally separate from table generation because the historical
    implementation never stored this range in the generated arrays.
    """
    full = build_property_bytes(sources, limit=MAX_UNICODE + 1)
    for cp in range(TABLE2_END, MAX_UNICODE + 1):
        expected = full[cp]
        hard_coded = lookup_tables(
            Tables(indices=(), data1=(), indices1=(), indices2=(), data2=()), cp
        )
        if expected != hard_coded:
            raise ValueError(
                "input Unicode data is not compatible with STULabel's historical "
                f"hard-coded >U+1FFFF lookup: U+{cp:04X} is {expected:#04x}, "
                f"historical lookup gives {hard_coded:#04x}"
            )


def _format_array(name: str, values: Sequence[int], *, hexadecimal: bool, columns: int) -> str:
    if columns <= 0:
        raise ValueError("columns must be positive")

    rendered = [f"0x{value:X}" if hexadecimal else str(value) for value in values]
    width = max((len(item) for item in rendered), default=1)
    lines: list[str] = []
    for start in range(0, len(rendered), columns):
        row = rendered[start : start + columns]
        lines.append("    " + ", ".join(item.rjust(width) for item in row) + ",")

    return (
        f"const UInt8 CodePointProperties::{name}[{len(values)}] = {{\n"
        + "\n".join(lines)
        + "\n};\n"
    )


def _unicode_version_major(unicode_version: str) -> int:
    try:
        major = int(unicode_version.split(".", 1)[0])
    except ValueError as exc:
        raise ValueError(f"invalid Unicode version {unicode_version!r}") from exc
    if not 0 <= major <= 0xFF:
        raise ValueError(f"Unicode version major {major} does not fit in UInt8")
    return major


def render_cpp(tables: Tables, *, unicode_version: str) -> str:
    return "\n".join(
        [
            f"// Generated from Unicode {unicode_version} data. DO NOT EDIT.\n"
            "// Property definitions match UnicodeCodePointPropertiesTests.mm.\n"
            "// Table structure matches STULabel's 2-/3-stage lookup.\n",
            f"const UInt8 CodePointProperties::unicodeDataVersionMajor = {_unicode_version_major(unicode_version)};\n",
            _format_array("indices", tables.indices, hexadecimal=False, columns=16),
            _format_array("data1", tables.data1, hexadecimal=True, columns=16),
            _format_array("indices1", tables.indices1, hexadecimal=False, columns=16),
            _format_array("indices2", tables.indices2, hexadecimal=False, columns=16),
            _format_array("data2", tables.data2, hexadecimal=True, columns=16),
        ]
    )


def _required_relative_paths() -> tuple[str, ...]:
    return (
        "extracted/DerivedBidiClass.txt",
        "DerivedCoreProperties.txt",
        "PropList.txt",
        "auxiliary/GraphemeBreakProperty.txt",
        "emoji/emoji-data.txt",
    )


def _source_files_from_dir(ucd_dir: Path) -> SourceFiles:
    paths = {relative: ucd_dir / relative for relative in _required_relative_paths()}
    missing = [path for path in paths.values() if not path.is_file()]
    if missing:
        formatted = "\n".join(f"  - {path}" for path in missing)
        raise FileNotFoundError(f"missing required UCD files:\n{formatted}")
    return SourceFiles(
        derived_bidi_class=paths["extracted/DerivedBidiClass.txt"],
        derived_core_properties=paths["DerivedCoreProperties.txt"],
        prop_list=paths["PropList.txt"],
        grapheme_break_property=paths["auxiliary/GraphemeBreakProperty.txt"],
        emoji_data=paths["emoji/emoji-data.txt"],
    )


def _download_ucd(version: str, cache_dir: Path) -> Path:
    ucd_dir = cache_dir / f"unicode-{version}" / "ucd"
    base_url = f"https://www.unicode.org/Public/{version}/ucd"

    for relative in _required_relative_paths():
        destination = ucd_dir / relative
        if destination.is_file():
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        url = f"{base_url}/{relative}"
        print(f"downloading {url}", file=sys.stderr)
        request = urllib.request.Request(
            url,
            headers={"User-Agent": "STULabel Unicode table generator/1"},
        )
        try:
            with urllib.request.urlopen(request, timeout=30) as response:  # noqa: S310 - fixed HTTPS host
                data = response.read()
        except (urllib.error.URLError, TimeoutError) as exc:
            raise RuntimeError(f"failed to download {url}: {exc}") from exc
        temporary = destination.with_suffix(destination.suffix + ".tmp")
        temporary.write_bytes(data)
        temporary.replace(destination)

    return ucd_dir


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _print_stats(tables: Tables, files: SourceFiles) -> None:
    print(
        "generated tables:\n"
        f"  indices : {len(tables.indices):5d} bytes, {len(tables.data1) // LEAF1_SIZE:3d} unique 32-byte leaves\n"
        f"  data1   : {len(tables.data1):5d} bytes\n"
        f"  indices1: {len(tables.indices1):5d} bytes\n"
        f"  indices2: {len(tables.indices2):5d} bytes, {len(tables.indices2) // MIDDLE_BLOCK_SIZE:3d} unique middle blocks\n"
        f"  data2   : {len(tables.data2):5d} bytes, {len(tables.data2) // LEAF2_SIZE:3d} unique 8-byte leaves\n"
        f"  total   : {sum(map(len, (tables.indices, tables.data1, tables.indices1, tables.indices2, tables.data2))):5d} bytes",
        file=sys.stderr,
    )
    for path in (
        files.derived_bidi_class,
        files.derived_core_properties,
        files.prop_list,
        files.grapheme_break_property,
        files.emoji_data,
    ):
        print(f"  sha256 {path.name}: {_sha256(path)}", file=sys.stderr)


def _build_argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--unicode-version",
        default=DEFAULT_UNICODE_VERSION,
        help=f"Unicode version to download/use in generated comment (default: {DEFAULT_UNICODE_VERSION})",
    )
    parser.add_argument(
        "--ucd-dir",
        type=Path,
        help="path to an unpacked UCD directory; if omitted, required files are downloaded",
    )
    parser.add_argument(
        "--cache-dir",
        type=Path,
        default=Path.home() / ".cache" / "stulabel-unicode-generator",
        help="download cache directory",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="write generated C++ table definitions here (default: stdout)",
    )
    parser.add_argument(
        "--verify-tail",
        action="store_true",
        help="also verify that U+20000..U+10FFFF matches the historical hard-coded shortcut",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _build_argument_parser().parse_args(argv)
    unicode_version: str = args.unicode_version
    ucd_dir: Path = args.ucd_dir or _download_ucd(unicode_version, args.cache_dir)
    files = _source_files_from_dir(ucd_dir)
    sources = load_property_sources(files)

    properties = build_property_bytes(sources)
    tables = build_tables(properties)
    verify_table_round_trip(properties, tables)
    if args.verify_tail:
        verify_historical_tail(sources)

    output = render_cpp(tables, unicode_version=unicode_version)
    if args.output is None:
        sys.stdout.write(output)
    else:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(output, encoding="utf-8")
        print(f"wrote {args.output}", file=sys.stderr)

    _print_stats(tables, files)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
