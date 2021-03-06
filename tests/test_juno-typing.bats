#!/usr/bin/env bats

## General Juno tests

@test "Printing help" {
  printed_help=`bash juno-typing -h`
  [[ "${printed_help}" =~ "-i, --input [DIR]                 This is the folder containing your input" ]]
}

@test "Checking environment installation by printing Snakemake help" {
  printed_help=`bash juno-typing -sh -y`
  [[ "$status" -eq 0 ]]
}

@test "Make sample sheet from input directory that does not contain either fasta or fastq files" {
  python bin/generate_sample_sheet.py tests/ > tests/test_sample_sheet.yaml
  sample_sheet_errors=`diff --suppress-common-lines tests/test_sample_sheet.yaml tests/example_output/wrong_sample_sheet.yaml`
  [[ -z $sample_sheet_errors ]]
  rm -f tests/test_sample_sheet.yaml
}

@test "Make sample sheet from fastq input (if combined with fasta, this one overwrites)" {
  python bin/generate_sample_sheet.py tests/example_fastq_input/ > tests/test_sample_sheet.yaml
  sample_sheet_errors=`diff --suppress-common-lines tests/test_sample_sheet.yaml tests/example_output/fastq_sample_sheet.yaml`
  [[ -z $sample_sheet_errors ]]
  rm -f tests/test_sample_sheet.yaml
}

@test "Make sample sheet from fasta input" {
  python bin/generate_sample_sheet.py tests/example_fasta_input/ > tests/test_sample_sheet.yaml
  sample_sheet_errors=`diff --suppress-common-lines tests/test_sample_sheet.yaml tests/example_output/fasta_sample_sheet.yaml`
  [[ -z $sample_sheet_errors ]]
  rm -f tests/test_sample_sheet.yaml
}

# @test "Error if non-existing directory" {
#   bash juno-typing -i fake_dir
#   [[ ! "$status" -eq 0 ]]
# }

# @test "Error if metadata has wrong extension (no .csv)" {
#   bash juno-typing -i tests/example_fastq_input --metadata tests/files/testing_env.yaml 
#   [[ ! "$status" -eq 0 ]]
# }

## Specific for MLST7

@test "Making sample sheet fastq + metadata (species name)" {
  python bin/generate_sample_sheet.py tests/example_fastq_input --metadata tests/files/example_metadata.csv > tests/test_sample_sheet.yaml
  sample_sheet_errors=`diff --suppress-common-lines tests/test_sample_sheet.yaml tests/example_output/metadata_sample_sheet.yaml`
  [[ $(cat tests/test_sample_sheet.yaml) =~ "senterica" ]]
  [[ -z $sample_sheet_errors ]]
  rm -f tests/test_sample_sheet.yaml
}

@test "Downloading databases" {
  bash bin/download_dbs.sh "./db_test" "TRUE" "./db_test/versions.yaml"
  [[ -f "db_test/mlst7_db/senterica/senterica.length.b" ]]
  [[ -f "db_test/kmerfinder_db/bacteria/bacteria.ATG.length.b" ]]
  [[ -f "bin/kmerfinder/kmerfinder.py" ]]
  [[ -f "bin/cge-mlst/mlst.py" ]]
}

@test "Test full pipeline (dry run)" {
  bash juno-typing -i tests/example_fastq_input/ -o out-test --species Salmonella enterica --db "db_test" -y -n
  [[ "$status" -eq 0 ]]
  rm -rf db_test
  rm -rf out-test
}
