#############################################################################
#####                          Identify species                         #####
#############################################################################

rule identify_species:
    input:
        r1 = lambda wildcards: SAMPLES[wildcards.sample]["R1"],
        r2 = lambda wildcards: SAMPLES[wildcards.sample]["R2"],
        db = KMERFINDER_DB + "/bacteria/bacteria.ATG.length.b"
    output:
        OUT + "/identify_species/{sample}/data.json"
    log:
        OUT + "/log/identify_species/{sample}.log"
    benchmark:
        OUT + "/log/benchmark/identify_species_{sample}.txt"
    threads: config["threads"]["kmerfinder"]
    resources: mem_mb=config["mem_mb"]["kmerfinder"]
    shell:
        """
DB_DIR=$(dirname {input.db})

python bin/kmerfinder/kmerfinder.py -i "{input.r1}" "{input.r2}" \
-o "$(dirname {output})" \
-db "${{DB_DIR}}/bacteria.ATG" \
-tax "${{DB_DIR}}/bacteria.tax" \
-x

if `cat {output} | grep -q "species_hits': {{}}"`; then
    rm -f {output}
fi
        """

# KmerFinder often makes errors in which it finds no hits. 
# These errors cause a problem in the following steps of the pipeline.
# However, often just re-running KmerFinder fixes it.
# TODO: Find and fix the reason why it fails instead of just doing this quick fix.