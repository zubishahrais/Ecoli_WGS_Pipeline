#!/usr/bin/env python3
import re
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

PROJECT_DIR = Path.cwd()
RESULTS_DIR = PROJECT_DIR / "results"
FIGURES_DIR = PROJECT_DIR / "figures"
FIGURES_DIR.mkdir(exist_ok=True)


def parse_flagstat(path):
    text = path.read_text()
    total_match = re.search(r"^(\d+)\s*\+\s*\d+\s+in total", text, re.MULTILINE)
    mapped_match = re.search(r"^(\d+)\s*\+\s*\d+\s+mapped\s+\(([\d.]+)%", text, re.MULTILINE)
    if not total_match or not mapped_match:
        raise ValueError(f"Could not parse flagstat file: {path}")
    total = int(total_match.group(1))
    mapped = int(mapped_match.group(1))
    mapped_pct = float(mapped_match.group(2))
    return {"total": total, "mapped": mapped, "unmapped": total - mapped, "mapped_pct": mapped_pct}


def parse_coverage(path):
    df = pd.read_csv(path, sep="\t")
    df.columns = [c.lstrip("#") for c in df.columns]
    mean_depth = (df["meandepth"] * df["endpos"]).sum() / df["endpos"].sum()
    mean_breadth = (df["coverage"] * df["endpos"]).sum() / df["endpos"].sum()
    return {"mean_depth": mean_depth, "mean_breadth_pct": mean_breadth}


def parse_variant_summary(path):
    text = path.read_text()
    out = {}
    patterns = {
        "total_raw": r"Total variants called \(pre-filter\):\s*(\d+)",
        "total_filtered": r"Total variants \(QUAL>=20\):\s*(\d+)",
        "snps": r"SNPs \(QUAL>=20\):\s*(\d+)",
        "indels": r"INDELs \(QUAL>=20\):\s*(\d+)",
    }
    for key, pattern in patterns.items():
        m = re.search(pattern, text)
        if not m:
            raise ValueError(f"Could not find '{key}' in {path}")
        out[key] = int(m.group(1))
    return out


def plot_alignment_pie(flagstat):
    fig, ax = plt.subplots(figsize=(6, 6))
    sizes = [flagstat["mapped"], flagstat["unmapped"]]
    labels = [f"Mapped ({flagstat['mapped_pct']:.2f}%)", "Unmapped"]
    ax.pie(sizes, labels=labels, colors=["#2ecc71", "#e74c3c"], autopct=lambda p: f"{p:.2f}%", startangle=90)
    ax.set_title("Read Alignment Outcome")
    fig.tight_layout()
    fig.savefig(FIGURES_DIR / "alignment_pie.png", dpi=300)
    plt.close(fig)
    print(f"Saved {FIGURES_DIR / 'alignment_pie.png'}")


def plot_coverage_histogram(depth_path, mean_depth):
    depths = pd.read_csv(depth_path, sep="\t", header=None, names=["contig", "pos", "depth"], usecols=["depth"])["depth"]
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.hist(depths, bins=50, color="#3498db", edgecolor="black", alpha=0.8)
    ax.axvline(mean_depth, color="red", linestyle="--", label=f"Mean depth = {mean_depth:.1f}x")
    ax.set_xlabel("Depth of coverage")
    ax.set_ylabel("Number of positions")
    ax.set_title("Per-Base Coverage Depth Distribution")
    ax.legend()
    fig.tight_layout()
    fig.savefig(FIGURES_DIR / "coverage_histogram.png", dpi=300)
    plt.close(fig)
    print(f"Saved {FIGURES_DIR / 'coverage_histogram.png'}")


def plot_variant_breakdown(variants):
    fig, ax = plt.subplots(figsize=(6, 5))
    categories = ["SNPs", "INDELs"]
    counts = [variants["snps"], variants["indels"]]
    bars = ax.bar(categories, counts, color=["#9b59b6", "#f39c12"])
    for bar, count in zip(bars, counts):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.5, str(count), ha="center", va="bottom")
    ax.set_ylabel("Count")
    ax.set_title(f"Variant Type Breakdown (Total filtered: {variants['total_filtered']})")
    fig.tight_layout()
    fig.savefig(FIGURES_DIR / "variant_breakdown.png", dpi=300)
    plt.close(fig)
    print(f"Saved {FIGURES_DIR / 'variant_breakdown.png'}")


def write_summary_report(flagstat, coverage, variants):
    report = f"""WGS PIPELINE SUMMARY REPORT
{'=' * 50}

ALIGNMENT
  Total reads:           {flagstat['total']:,}
  Mapped reads:          {flagstat['mapped']:,}
  Alignment rate:        {flagstat['mapped_pct']:.2f}%

COVERAGE
  Mean depth:            {coverage['mean_depth']:.1f}x
  Genome breadth covered:{coverage['mean_breadth_pct']:.3f}%

VARIANTS
  Total called (raw):    {variants['total_raw']}
  Total (QUAL>=20):      {variants['total_filtered']}
  SNPs:                  {variants['snps']}
  INDELs:                {variants['indels']}
"""
    (RESULTS_DIR / "summary_report.txt").write_text(report)
    print(report)


def main():
    flagstat_path = RESULTS_DIR / "flagstat.txt"
    coverage_path = RESULTS_DIR / "coverage_summary.txt"
    depth_path = RESULTS_DIR / "per_base_depth.txt"
    variant_path = RESULTS_DIR / "variant_summary.txt"

    for p in [flagstat_path, coverage_path, depth_path, variant_path]:
        if not p.exists():
            sys.exit(f"ERROR: missing {p}. Run scripts 05 and 06 first.")

    flagstat = parse_flagstat(flagstat_path)
    coverage = parse_coverage(coverage_path)
    variants = parse_variant_summary(variant_path)

    plot_alignment_pie(flagstat)
    plot_coverage_histogram(depth_path, coverage["mean_depth"])
    plot_variant_breakdown(variants)
    write_summary_report(flagstat, coverage, variants)


if __name__ == "__main__":
    main()
