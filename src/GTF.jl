#----------------------------------------------------------------
#
# Representation of transcripts similar to GTF
#



export Transcript,
    Gene,
    iscoding,
    exons,
    cdss,
    GTFFile,
    transcripts,
    genes,
    tabix


#abstract type AbstractGenomicFeature end
abstract type AbstractGene <: AbstractGenomicFeature end

struct Transcript <: AbstractGenomicFeature
    chrom::AbstractString
    bpStart::Int64
    bpEnd::Int64
    strand::Char
    id::AbstractString
    name::AbstractString
    exons::Vector{Tuple{Int64, Int64}}
    cdss::Vector{Tuple{Int64, Int64}}
end

name(t::Transcript) = t.name
iscoding(t::Transcript) = length(t.cdss) > 0
exons(t::Transcript) = t.exons
cdss(t::Transcript) = t.cdss

struct Gene <: AbstractGene
    chrom::AbstractString
    bpStart::Int64
    bpEnd::Int64
    strand::Char
    id::AbstractString
    name::AbstractString
    transcripts::Vector{Transcript}
end    

name(g::Gene) = g.name
iscoding(g::Gene) = any(iscoding.(g.transcripts))
transcripts(g::Gene) = g.transcripts
exons(g::Gene) = union([exons(t) for t in transcripts(g)]...)
cdss(g::Gene) = union([cdss(t) for t in transcripts(g)]...)


Base.show(io::IO, g::Gene) = print(io, "Gene $(g.name) ($(g.chrom):$(g.bpStart)-$(g.bpEnd)) with $(length(g.transcripts)) transcripts")

struct GTFFile
    path::AbstractString
    io::IO
end

import GZip
GTFFile(filename::AbstractString) = GTFFile(filename, endswith(filename, ".gz") ? GZip.open(filename) : open(filename, "r"))
GTFFile(io::IO) = GTFFile("", io)



function genes(gtf::GTFFile)

    # genes, transcripts and exons might come in any order
    genes = Gene[]
    gene2transcripts = Dict{AbstractString, Vector{Transcript}}()
    transcript2exons = Dict{AbstractString, Vector{Tuple{Int64, Int64}}}()
    transcript2cdss = Dict{AbstractString, Vector{Tuple{Int64, Int64}}}()   
    count = 1
    for line in eachline(gtf.io)
        
        count += 1
        if startswith(line, "#")
            continue
        end

        chrom, source, feature, bpStart, bpEnd, score, strand, frame, attributes = split(chomp(line), "\t")
        attributes = parse_attributes(attributes)

        if feature == "gene"
            push!(genes, Gene(chrom, parse(Int64, bpStart), parse(Int64, bpEnd), strand[1],
                              attributes["gene_id"], attributes["gene_name"], Transcript[]))
        elseif feature == "transcript"
            t = Transcript(chrom, parse(Int64, bpStart), parse(Int64, bpEnd), strand[1],
                           attributes["transcript_id"], attributes["transcript_name"],
                           Tuple{Int64, Int64}[], Tuple{Int64, Int64}[])
            geneid = attributes["gene_id"]
            ~haskey(gene2transcripts, geneid) && (gene2transcripts[geneid] = Transcript[])
            push!(gene2transcripts[geneid], t)
        elseif feature == "exon" 
            e = (parse(Int64, bpStart), parse(Int64, bpEnd))
            transcriptid = attributes["transcript_id"]
            ~haskey(transcript2exons, transcriptid) && (transcript2exons[transcriptid] = Tuple{Int64, Int64}[])
            push!(transcript2exons[transcriptid], e)
        elseif feature == "CDS" || feature == "cds"
            c = (parse(Int64, bpStart), parse(Int64, bpEnd))
            transcriptid = attributes["transcript_id"]
            ~haskey(transcript2cdss, transcriptid) && (transcript2cdss[transcriptid] = Tuple{Int64, Int64}[])
            push!(transcript2cdss[transcriptid], c)
        end
    end
    close(gtf.io)
    #info("Parsed $count lines from $(gtf.path)")

    for g in genes
        for t in gene2transcripts[g.id]
            push!(g.transcripts, t)
            for e in transcript2exons[t.id]
                push!(t.exons, e)
            end
            for c in get(transcript2cdss, t.id, Tuple{Int64, Int64}[])
                push!(t.cdss, c)
            end
        end
    end
    genes
end


function transcripts(gtf::GTFFile)
    gs = genes(gtf)
    transcripts = Transcript[]
    for g in gs
        append!(transcripts, g.transcripts)
    end
    transcripts
end


function parse_attributes(attributes)
    res = Dict()
    for kv in split(attributes, ";", keepempty=false)
        k, v = split(kv, " ", keepempty=false)
        res[k] = replace(v, "\"" => "") 
    end
    res
end



# get file handle to tabix stream
function tabix(filename::AbstractString, chrom::AbstractString, bpStart::Int64, bpEnd::Int64)
    cmd = `tabix $filename $chrom:$bpStart-$bpEnd`
    process = open(cmd, "r")
    process
end
