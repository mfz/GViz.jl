export AbstractGenomicFeature,
    name,
    chrom,
    bpStart,
    bpEnd,
    strand,
    length,
    overlaps,
    contains,
    iscontained,
    leftof,
    rightof

"""
AbstractGenomicFeature

type implementing methods:
- name
- chrom
- bpStart
- bpEnd
- strand
"""
abstract type AbstractGenomicFeature end
# name, chrom, bpStart, bpEnd, strand

name(x::AbstractGenomicFeature) = ""
chrom(x::AbstractGenomicFeature) = x.chrom
bpStart(x::AbstractGenomicFeature) = x.bpStart
bpEnd(x::AbstractGenomicFeature) = x.bpEnd
strand(x::AbstractGenomicFeature) = x.strand

# --- abstraction boundary ----------------------------

Base.isless(x::AbstractGenomicFeature, y::AbstractGenomicFeature) = 
    (chrom(x), bpStart(x), bpEnd(x)) < (chrom(y), bpStart(y), bpEnd(y))

Base.length(x::AbstractGenomicFeature)  = bpEnd(x) - bpStart(x) + 1

overlaps(x::AbstractGenomicFeature, y::AbstractGenomicFeature)  =
    (chrom(x) == chrom(y) && bpStart(x) <= bpEnd(y) && bpEnd(x) >= bpStart(y))

contains(x::AbstractGenomicFeature, y::AbstractGenomicFeature) =
    (chrom(x) == chrom(y) && bpStart(y) >= bpStart(x) && bpEnd(y) <= bpEnd(x))

iscontained(x::AbstractGenomicFeature, y::AbstractGenomicFeature) =
    contains(y, x)

leftof(x::AbstractGenomicFeature, y::AbstractGenomicFeature) =
    (chrom(x) < chrom(y))||(chrom(x) == chrom(y) && bpEnd(x) < bpStart(y))

rightof(x::AbstractGenomicFeature, y::AbstractGenomicFeature) =
    leftof(y, x)

