#############################################################################
#####                               MLST7                               #####
#############################################################################

rule mlst7:
    input:
        r1 = lambda wildcards: SAMPLES[wildcards.sample]["R1"],
        r2 = lambda wildcards: SAMPLES[wildcards.sample]["R2"],
        db = MLST7_DB + "/senterica/senterica.length.b",
        species = OUT + "/identify_species/{sample}/data.json"
    output:
        OUT + "/mlst7/{sample}/results_tab.tsv"
    conda:
        "../../envs/mlst7.yaml"
    log:
        OUT + "/log/mlst7/{sample}.log"
    benchmark:
        OUT + "/log/benchmark/mlst7_{sample}.txt"
    threads: config["threads"]["cgemlst"]
    resources: mem_mb=config["mem_mb"]["cgemlst"]
    params:
        species = lambda wildcards: SAMPLES[wildcards.sample]["species-mlst7"],
        mlst7_db = MLST7_DB
    shell:
        """
if [ {params.species} == "NotProvided" ]; then
    SPECIES=$(python bin/get_mlst7_db_name.py {input.species}) 2> {log}
else
    SPECIES={params.species}
fi

python bin/cge-mlst/mlst.py -i {input.r1} {input.r2} \
-o $(dirname {output}) \
-s $SPECIES \
--database {params.mlst7_db} \
-mp kma \
-x 2> {log}
        """




