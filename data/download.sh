wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_35/gencode.v35.annotation.gtf.gz

gunzip -c gencode.v35.annotation.gtf.gz \
    | grep -v '^#' | sort -k1,1 -k4,4n | bgzip -c > gencode.v35.annotation.gtf.bgz

tabix -p gff gencode.v35.annotation.gtf.bgz
