#!/bin/python

"""Get species name (formated for CGE-MLST).

Usage:
    get_species.py </path/to/kmerfinder/results/data.json>
"""

import argparse
import pathlib
import json
import yaml
import pandas as pd

with open("files/dictionary_correct_species.yaml") as translation_yaml:
    translation_tbl = yaml.safe_load(translation_yaml)

def parse_kmerfinder(json_file):
    with open(json_file) as kmerfinder_json:
        kmerfinder_dic = json.load(kmerfinder_json)
        hits = kmerfinder_dic['kmerfinder']['results']['species_hits'].keys()
        sp_column = [col_name for col_name in hits if col_name.count(' sp. ') ]
        
        assert len(sp_column) < len(hits), "No unique species could be determined."
        
        for sp in sp_column:
            kmerfinder_dic['kmerfinder']['results']['species_hits'].pop(sp)
            
        species_df = pd.DataFrame.from_dict(kmerfinder_dic['kmerfinder']['results']['species_hits'])
        
        score = species_df.iloc[2,:].apply(lambda x: float(x))

        species = score.idxmax().split()[0][0] + score.idxmax().split()[1]

        return species.lower()

def choose_right_db(species, translation_tbl):
    if species in translation_tbl.keys():
        species = translation_tbl[species]
    return species

def main(args):
    assert args.kmerfinder_res.is_file(), "kmerfinder_res must be an existing file."
    species = parse_kmerfinder(args.kmerfinder_res)
    print(choose_right_db(species, translation_tbl))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("kmerfinder_res", type=pathlib.Path, 
                       help="json file containing the results of KmerFinder.")
    main(parser.parse_args())

