// The NCBI BLAST+ programs, from `PROGRAM -help` (BLAST+ 2.17.0): the options
// of blastn, blastp, blastx, tblastn, tblastx, psiblast, rpsblast, rpstblastn,
// deltablast, makeblastdb, blastdbcmd, blast_formatter, blastdb_aliastool,
// the maskers, makeprofiledb and blastdbcheck.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

fn blastn() {
    #{
        opts: `
            -h                            print USAGE and DESCRIPTION; ignore all other parameters
            -help                         print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version                      print version number; ignore other arguments
            -query FILE                   input file name
            -query_loc STR                location on the query sequence in 1-based offsets (Format: start-stop)
            -strand STR                   query strand(s) to search against database/subject
            -task STR                     task to execute
            -db STR                       BLAST database name
            -out FILE                     output file name
            -evalue FLOAT                 expectation value (E) threshold for saving hits
            -word_size INT                word size for wordfinder algorithm (length of best perfect match)
            -gapopen INT                  cost to open a gap
            -gapextend INT                cost to extend a gap
            -penalty INT                  penalty for a nucleotide mismatch
            -reward INT                   reward for a nucleotide match
            -use_index BOOL               use MegaBLAST database index
            -index_name STR               megaBLAST database index name (deprecated; use only for old style indices)
            -subject FILE                 subject sequence(s) to search
            -subject_loc STR              location on the subject sequence in 1-based offsets (Format: start-stop)
            -outfmt STR                   alignment view options (6 is tabular)
            -show_gis                     show NCBI GIs in deflines?
            -num_descriptions INT         number of database sequences to show one-line descriptions for Not applicable for outfmt
            -num_alignments INT           number of database sequences to show alignments for
            -line_length INT              line length for formatting alignments Not applicable for outfmt > 4
            -html                         produce HTML output?
            -sorthits INT                 sorting option for hits: alignment view options: 0 = Sort by evalue, 1 = Sort by bit
            -sorthsps INT                 sorting option for hps: 0 = Sort by hsp evalue, 1 = Sort by hsp score, 2 = Sort by hsp
            -dust STR                     filter query sequence with DUST
            -filtering_db STR             BLAST database containing filtering elements (i.e.: repeats)
            -window_masker_taxid INT      enable WindowMasker filtering using a Taxonomic ID
            -window_masker_db STR         enable WindowMasker filtering using this repeats database
            -soft_masking BOOL            apply filtering locations as soft masks
            -lcase_masking                use lower case filtering in query and subject sequence(s)?
            -gilist STR                   restrict search of database to list of GIs
            -seqidlist STR                restrict search of database to list of SeqIDs
            -negative_gilist STR          restrict search of database to everything except the specified GIs
            -negative_seqidlist STR       restrict search of database to everything except the specified SeqIDs
            -taxids STR                   restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxids STR          restrict search of database to everything except the specified taxonomy IDs and their
            -taxidlist STR                restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxidlist STR       restrict search of database to everything except the specified taxonomy IDs and their
            -no_taxid_expansion           do not expand the taxonomy IDs provided to their descendant taxonomy IDs
            -entrez_query STR             restrict search with the given Entrez query
            -db_soft_mask STR             filtering algorithm ID to apply to the BLAST database as soft masking
            -db_hard_mask STR             filtering algorithm ID to apply to the BLAST database as hard masking
            -perc_identity FLOAT          percent identity
            -qcov_hsp_perc FLOAT          percent query coverage per hsp
            -max_hsps INT                 set maximum number of HSPs per subject sequence to save for each query
            -culling_limit INT            if the query range of a hit is enveloped by that of at least this many higher-scoring
            -best_hit_overhang FLOAT      best Hit algorithm overhang value (recommended value: 0.1)
            -best_hit_score_edge FLOAT    best Hit algorithm score edge value (recommended value: 0.1)
            -subject_besthit              return only the best HSP for each non overlapping query region
            -max_target_seqs INT          maximum number of aligned sequences to keep (value of 5 or more is recommended)
            -template_type STR            discontiguous MegaBLAST template type
            -template_length INT          discontiguous MegaBLAST template length
            -dbsize INT                   effective length of the database
            -searchsp INT                 effective length of the search space
            -import_search_strategy FILE  search strategy to use
            -export_search_strategy FILE  file name to record the search strategy used
            -xdrop_ungap FLOAT            x-dropoff value (in bits) for ungapped extensions
            -xdrop_gap FLOAT              x-dropoff value (in bits) for preliminary gapped extensions
            -xdrop_gap_final FLOAT        x-dropoff value (in bits) for final gapped alignment
            -no_greedy                    use non-greedy dynamic programming extension
            -min_raw_gapped_score INT     minimum raw gapped score to keep an alignment in the preliminary gapped and traceback
            -ungapped                     perform ungapped alignment only?
            -window_size INT              multiple hits window size, use 0 to specify 1-hit algorithm
            -off_diagonal_range INT       number of off-diagonals to search for the 2nd hit, use 0 to turn off
            -parse_deflines               should the query and subject defline(s) be parsed?
            -num_threads INT              number of threads (CPUs) to use in the BLAST search
            -mt_mode INT                  multi-thread mode to use in BLAST search: 0 auto split by database or queries 1 split by
            -remote                       execute search remotely?
        `,
        values: #{
            "-query": k("fasta"), "-query_loc": "none", "-strand": ["both", "minus", "plus"],
            "-task": ["blastn", "blastn-short", "dc-megablast", "megablast", "rmblastn"], "-db": k("blast_db"),
            "-out": "files", "-evalue": "none", "-word_size": "none", "-gapopen": "none", "-gapextend": "none",
            "-penalty": "none", "-reward": "none", "-use_index": ["true", "false"], "-index_name": "none",
            "-subject": k("fasta"), "-subject_loc": "none",
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
            "-num_descriptions": "none", "-num_alignments": "none", "-line_length": "none", "-sorthits": "none",
            "-sorthsps": "none", "-dust": "none", "-filtering_db": "none", "-window_masker_taxid": "none",
            "-window_masker_db": "none", "-soft_masking": ["true", "false"], "-gilist": "files",
            "-seqidlist": "files", "-negative_gilist": "files", "-negative_seqidlist": "files", "-taxids": "none",
            "-negative_taxids": "none", "-taxidlist": "files", "-negative_taxidlist": "files",
            "-entrez_query": "none", "-db_soft_mask": "none", "-db_hard_mask": "none", "-perc_identity": "none",
            "-qcov_hsp_perc": "none", "-max_hsps": "none", "-culling_limit": "none", "-best_hit_overhang": "none",
            "-best_hit_score_edge": "none", "-max_target_seqs": "none",
            "-template_type": ["coding", "coding_and_optimal", "optimal"], "-template_length": ["16", "18", "21"],
            "-dbsize": "none", "-searchsp": "none", "-import_search_strategy": "files",
            "-export_search_strategy": "files", "-xdrop_ungap": "none", "-xdrop_gap": "none",
            "-xdrop_gap_final": "none", "-min_raw_gapped_score": "none", "-window_size": "none",
            "-off_diagonal_range": "none", "-num_threads": "none", "-mt_mode": "none",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn blastp() {
    #{
        opts: `
            -h                            print USAGE and DESCRIPTION; ignore all other parameters
            -help                         print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version                      print version number; ignore other arguments
            -query FILE                   input file name
            -query_loc STR                location on the query sequence in 1-based offsets (Format: start-stop)
            -task STR                     task to execute
            -db STR                       BLAST database name
            -out FILE                     output file name
            -evalue FLOAT                 expectation value (E) threshold for saving hits
            -word_size INT                word size for wordfinder algorithm
            -gapopen INT                  cost to open a gap
            -gapextend INT                cost to extend a gap
            -matrix STR                   scoring matrix name (normally BLOSUM62)
            -threshold FLOAT              minimum word score such that the word is added to the BLAST lookup table
            -comp_based_stats STR         use composition-based statistics: D or d: default (equivalent to 2 ) 0 or F or f: No
            -subject FILE                 subject sequence(s) to search
            -subject_loc STR              location on the subject sequence in 1-based offsets (Format: start-stop)
            -outfmt STR                   alignment view options (6 is tabular)
            -show_gis                     show NCBI GIs in deflines?
            -num_descriptions INT         number of database sequences to show one-line descriptions for Not applicable for outfmt
            -num_alignments INT           number of database sequences to show alignments for
            -line_length INT              line length for formatting alignments Not applicable for outfmt > 4
            -html                         produce HTML output?
            -sorthits INT                 sorting option for hits: alignment view options: 0 = Sort by evalue, 1 = Sort by bit
            -sorthsps INT                 sorting option for hps: 0 = Sort by hsp evalue, 1 = Sort by hsp score, 2 = Sort by hsp
            -seg STR                      filter query sequence with SEG (Format: 'yes', 'window locut hicut', or 'no' to disable)
            -soft_masking BOOL            apply filtering locations as soft masks
            -lcase_masking                use lower case filtering in query and subject sequence(s)?
            -gilist STR                   restrict search of database to list of GIs
            -seqidlist STR                restrict search of database to list of SeqIDs
            -negative_gilist STR          restrict search of database to everything except the specified GIs
            -negative_seqidlist STR       restrict search of database to everything except the specified SeqIDs
            -taxids STR                   restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxids STR          restrict search of database to everything except the specified taxonomy IDs and their
            -taxidlist STR                restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxidlist STR       restrict search of database to everything except the specified taxonomy IDs and their
            -no_taxid_expansion           do not expand the taxonomy IDs provided to their descendant taxonomy IDs
            -ipglist STR                  restrict search of database to list of IPGs
            -negative_ipglist STR         restrict search of database to everything except the specified IPGs
            -entrez_query STR             restrict search with the given Entrez query
            -db_soft_mask STR             filtering algorithm ID to apply to the BLAST database as soft masking
            -db_hard_mask STR             filtering algorithm ID to apply to the BLAST database as hard masking
            -qcov_hsp_perc FLOAT          percent query coverage per hsp
            -max_hsps INT                 set maximum number of HSPs per subject sequence to save for each query
            -culling_limit INT            if the query range of a hit is enveloped by that of at least this many higher-scoring
            -best_hit_overhang FLOAT      best Hit algorithm overhang value (recommended value: 0.1)
            -best_hit_score_edge FLOAT    best Hit algorithm score edge value (recommended value: 0.1)
            -subject_besthit              return only the best HSP for each non overlapping query region
            -max_target_seqs INT          maximum number of aligned sequences to keep (value of 5 or more is recommended)
            -dbsize INT                   effective length of the database
            -searchsp INT                 effective length of the search space
            -import_search_strategy FILE  search strategy to use
            -export_search_strategy FILE  file name to record the search strategy used
            -xdrop_ungap FLOAT            x-dropoff value (in bits) for ungapped extensions
            -xdrop_gap FLOAT              x-dropoff value (in bits) for preliminary gapped extensions
            -xdrop_gap_final FLOAT        x-dropoff value (in bits) for final gapped alignment
            -window_size INT              multiple hits window size, use 0 to specify 1-hit algorithm
            -ungapped                     perform ungapped alignment only?
            -parse_deflines               should the query and subject defline(s) be parsed?
            -num_threads INT              number of threads (CPUs) to use in the BLAST search
            -mt_mode INT                  multi-thread mode to use in BLAST search: 0 auto split by database or queries 1 split by
            -remote                       execute search remotely?
            -use_sw_tback                 compute locally optimal Smith-Waterman alignments?
        `,
        values: #{
            "-query": k("fasta"), "-query_loc": "none", "-task": ["blastp", "blastp-fast", "blastp-short"],
            "-db": k("blast_db"), "-out": "files", "-evalue": "none", "-word_size": "none", "-gapopen": "none",
            "-gapextend": "none",
            "-matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM30", "PAM70"],
            "-threshold": "none", "-comp_based_stats": ["0", "1", "2", "3", "D", "F", "T"], "-subject": k("fasta"),
            "-subject_loc": "none",
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
            "-num_descriptions": "none", "-num_alignments": "none", "-line_length": "none", "-sorthits": "none",
            "-sorthsps": "none", "-seg": "none", "-soft_masking": ["true", "false"], "-gilist": "files",
            "-seqidlist": "files", "-negative_gilist": "files", "-negative_seqidlist": "files", "-taxids": "none",
            "-negative_taxids": "none", "-taxidlist": "files", "-negative_taxidlist": "files", "-ipglist": "none",
            "-negative_ipglist": "none", "-entrez_query": "none", "-db_soft_mask": "none", "-db_hard_mask": "none",
            "-qcov_hsp_perc": "none", "-max_hsps": "none", "-culling_limit": "none", "-best_hit_overhang": "none",
            "-best_hit_score_edge": "none", "-max_target_seqs": "none", "-dbsize": "none", "-searchsp": "none",
            "-import_search_strategy": "files", "-export_search_strategy": "files", "-xdrop_ungap": "none",
            "-xdrop_gap": "none", "-xdrop_gap_final": "none", "-window_size": "none", "-num_threads": "none",
            "-mt_mode": "none",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn blastx() {
    #{
        opts: `
            -h                            print USAGE and DESCRIPTION; ignore all other parameters
            -help                         print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version                      print version number; ignore other arguments
            -query FILE                   input file name
            -query_loc STR                location on the query sequence in 1-based offsets (Format: start-stop)
            -strand STR                   query strand(s) to search against database/subject
            -query_gencode INT            genetic code to use to translate query
            -task STR                     task to execute
            -db STR                       BLAST database name
            -out FILE                     output file name
            -evalue FLOAT                 expectation value (E) threshold for saving hits
            -word_size INT                word size for wordfinder algorithm
            -gapopen INT                  cost to open a gap
            -gapextend INT                cost to extend a gap
            -max_intron_length INT        length of the largest intron allowed in a translated nucleotide sequence when linking
            -matrix STR                   scoring matrix name (normally BLOSUM62)
            -threshold FLOAT              minimum word score such that the word is added to the BLAST lookup table
            -comp_based_stats STR         use composition-based statistics: D or d: default (equivalent to 2 ) 0 or F or f: No
            -subject FILE                 subject sequence(s) to search
            -subject_loc STR              location on the subject sequence in 1-based offsets (Format: start-stop)
            -outfmt STR                   alignment view options (6 is tabular)
            -show_gis                     show NCBI GIs in deflines?
            -num_descriptions INT         number of database sequences to show one-line descriptions for Not applicable for outfmt
            -num_alignments INT           number of database sequences to show alignments for
            -line_length INT              line length for formatting alignments Not applicable for outfmt > 4
            -html                         produce HTML output?
            -sorthits INT                 sorting option for hits: alignment view options: 0 = Sort by evalue, 1 = Sort by bit
            -sorthsps INT                 sorting option for hps: 0 = Sort by hsp evalue, 1 = Sort by hsp score, 2 = Sort by hsp
            -seg STR                      filter query sequence with SEG (Format: 'yes', 'window locut hicut', or 'no' to disable)
            -soft_masking BOOL            apply filtering locations as soft masks
            -lcase_masking                use lower case filtering in query and subject sequence(s)?
            -gilist STR                   restrict search of database to list of GIs
            -seqidlist STR                restrict search of database to list of SeqIDs
            -negative_gilist STR          restrict search of database to everything except the specified GIs
            -negative_seqidlist STR       restrict search of database to everything except the specified SeqIDs
            -taxids STR                   restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxids STR          restrict search of database to everything except the specified taxonomy IDs and their
            -taxidlist STR                restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxidlist STR       restrict search of database to everything except the specified taxonomy IDs and their
            -no_taxid_expansion           do not expand the taxonomy IDs provided to their descendant taxonomy IDs
            -ipglist STR                  restrict search of database to list of IPGs
            -negative_ipglist STR         restrict search of database to everything except the specified IPGs
            -entrez_query STR             restrict search with the given Entrez query
            -db_soft_mask STR             filtering algorithm ID to apply to the BLAST database as soft masking
            -db_hard_mask STR             filtering algorithm ID to apply to the BLAST database as hard masking
            -qcov_hsp_perc FLOAT          percent query coverage per hsp
            -max_hsps INT                 set maximum number of HSPs per subject sequence to save for each query
            -culling_limit INT            if the query range of a hit is enveloped by that of at least this many higher-scoring
            -best_hit_overhang FLOAT      best Hit algorithm overhang value (recommended value: 0.1)
            -best_hit_score_edge FLOAT    best Hit algorithm score edge value (recommended value: 0.1)
            -subject_besthit              return only the best HSP for each non overlapping query region
            -max_target_seqs INT          maximum number of aligned sequences to keep (value of 5 or more is recommended)
            -dbsize INT                   effective length of the database
            -searchsp INT                 effective length of the search space
            -sum_stats BOOL               use sum statistics
            -import_search_strategy FILE  search strategy to use
            -export_search_strategy FILE  file name to record the search strategy used
            -xdrop_ungap FLOAT            x-dropoff value (in bits) for ungapped extensions
            -xdrop_gap FLOAT              x-dropoff value (in bits) for preliminary gapped extensions
            -xdrop_gap_final FLOAT        x-dropoff value (in bits) for final gapped alignment
            -window_size INT              multiple hits window size, use 0 to specify 1-hit algorithm
            -ungapped                     perform ungapped alignment only?
            -parse_deflines               should the query and subject defline(s) be parsed?
            -num_threads INT              number of threads (CPUs) to use in the BLAST search
            -mt_mode INT                  multi-thread mode to use in BLAST search: 0 auto split by database or queries 1 split by
            -remote                       execute search remotely?
            -use_sw_tback                 compute locally optimal Smith-Waterman alignments?
        `,
        values: #{
            "-query": k("fasta"), "-query_loc": "none", "-strand": ["both", "minus", "plus"],
            "-query_gencode": "none", "-task": ["blastx", "blastx-fast"], "-db": k("blast_db"), "-out": "files",
            "-evalue": "none", "-word_size": "none", "-gapopen": "none", "-gapextend": "none",
            "-max_intron_length": "none",
            "-matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM30", "PAM70"],
            "-threshold": "none", "-comp_based_stats": ["0", "1", "2", "3", "D", "F", "T"], "-subject": k("fasta"),
            "-subject_loc": "none",
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
            "-num_descriptions": "none", "-num_alignments": "none", "-line_length": "none", "-sorthits": "none",
            "-sorthsps": "none", "-seg": "none", "-soft_masking": ["true", "false"], "-gilist": "files",
            "-seqidlist": "files", "-negative_gilist": "files", "-negative_seqidlist": "files", "-taxids": "none",
            "-negative_taxids": "none", "-taxidlist": "files", "-negative_taxidlist": "files", "-ipglist": "none",
            "-negative_ipglist": "none", "-entrez_query": "none", "-db_soft_mask": "none", "-db_hard_mask": "none",
            "-qcov_hsp_perc": "none", "-max_hsps": "none", "-culling_limit": "none", "-best_hit_overhang": "none",
            "-best_hit_score_edge": "none", "-max_target_seqs": "none", "-dbsize": "none", "-searchsp": "none",
            "-sum_stats": ["true", "false"], "-import_search_strategy": "files", "-export_search_strategy": "files",
            "-xdrop_ungap": "none", "-xdrop_gap": "none", "-xdrop_gap_final": "none", "-window_size": "none",
            "-num_threads": "none", "-mt_mode": "none",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn tblastn() {
    #{
        opts: `
            -h                            print USAGE and DESCRIPTION; ignore all other parameters
            -help                         print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version                      print version number; ignore other arguments
            -query FILE                   input file name
            -query_loc STR                location on the query sequence in 1-based offsets (Format: start-stop)
            -task STR                     task to execute
            -db STR                       BLAST database name
            -out FILE                     output file name
            -evalue FLOAT                 expectation value (E) threshold for saving hits
            -word_size INT                word size for wordfinder algorithm
            -gapopen INT                  cost to open a gap
            -gapextend INT                cost to extend a gap
            -db_gencode INT               genetic code to use to translate database/subjects (see user manual for details)
            -max_intron_length INT        length of the largest intron allowed in a translated nucleotide sequence when linking
            -matrix STR                   scoring matrix name (normally BLOSUM62)
            -threshold FLOAT              minimum word score such that the word is added to the BLAST lookup table
            -comp_based_stats STR         use composition-based statistics: D or d: default (equivalent to 2 ) 0 or F or f: No
            -subject FILE                 subject sequence(s) to search
            -subject_loc STR              location on the subject sequence in 1-based offsets (Format: start-stop)
            -outfmt STR                   alignment view options (6 is tabular)
            -show_gis                     show NCBI GIs in deflines?
            -num_descriptions INT         number of database sequences to show one-line descriptions for Not applicable for outfmt
            -num_alignments INT           number of database sequences to show alignments for
            -line_length INT              line length for formatting alignments Not applicable for outfmt > 4
            -html                         produce HTML output?
            -sorthits INT                 sorting option for hits: alignment view options: 0 = Sort by evalue, 1 = Sort by bit
            -sorthsps INT                 sorting option for hps: 0 = Sort by hsp evalue, 1 = Sort by hsp score, 2 = Sort by hsp
            -seg STR                      filter query sequence with SEG (Format: 'yes', 'window locut hicut', or 'no' to disable)
            -soft_masking BOOL            apply filtering locations as soft masks
            -lcase_masking                use lower case filtering in query and subject sequence(s)?
            -gilist STR                   restrict search of database to list of GIs
            -seqidlist STR                restrict search of database to list of SeqIDs
            -negative_gilist STR          restrict search of database to everything except the specified GIs
            -negative_seqidlist STR       restrict search of database to everything except the specified SeqIDs
            -taxids STR                   restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxids STR          restrict search of database to everything except the specified taxonomy IDs and their
            -taxidlist STR                restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxidlist STR       restrict search of database to everything except the specified taxonomy IDs and their
            -no_taxid_expansion           do not expand the taxonomy IDs provided to their descendant taxonomy IDs
            -entrez_query STR             restrict search with the given Entrez query
            -db_soft_mask STR             filtering algorithm ID to apply to the BLAST database as soft masking
            -db_hard_mask STR             filtering algorithm ID to apply to the BLAST database as hard masking
            -qcov_hsp_perc FLOAT          percent query coverage per hsp
            -max_hsps INT                 set maximum number of HSPs per subject sequence to save for each query
            -culling_limit INT            if the query range of a hit is enveloped by that of at least this many higher-scoring
            -best_hit_overhang FLOAT      best Hit algorithm overhang value (recommended value: 0.1)
            -best_hit_score_edge FLOAT    best Hit algorithm score edge value (recommended value: 0.1)
            -subject_besthit              return only the best HSP for each non overlapping query region
            -max_target_seqs INT          maximum number of aligned sequences to keep (value of 5 or more is recommended)
            -dbsize INT                   effective length of the database
            -searchsp INT                 effective length of the search space
            -sum_stats BOOL               use sum statistics
            -import_search_strategy FILE  search strategy to use
            -export_search_strategy FILE  file name to record the search strategy used
            -xdrop_ungap FLOAT            x-dropoff value (in bits) for ungapped extensions
            -xdrop_gap FLOAT              x-dropoff value (in bits) for preliminary gapped extensions
            -xdrop_gap_final FLOAT        x-dropoff value (in bits) for final gapped alignment
            -ungapped                     perform ungapped alignment only?
            -window_size INT              multiple hits window size, use 0 to specify 1-hit algorithm
            -parse_deflines               should the query and subject defline(s) be parsed?
            -num_threads INT              number of threads (CPUs) to use in the BLAST search
            -mt_mode INT                  multi-thread mode to use in BLAST search: 0 auto split by database or queries 1 split by
            -remote                       execute search remotely?
            -use_sw_tback                 compute locally optimal Smith-Waterman alignments?
            -in_pssm FILE                 PSI-TBLASTN checkpoint file
        `,
        values: #{
            "-query": k("fasta"), "-query_loc": "none", "-task": ["tblastn", "tblastn-fast"], "-db": k("blast_db"),
            "-out": "files", "-evalue": "none", "-word_size": "none", "-gapopen": "none", "-gapextend": "none",
            "-db_gencode": "none", "-max_intron_length": "none",
            "-matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM30", "PAM70"],
            "-threshold": "none", "-comp_based_stats": ["0", "1", "2", "3", "D", "F", "T"], "-subject": k("fasta"),
            "-subject_loc": "none",
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
            "-num_descriptions": "none", "-num_alignments": "none", "-line_length": "none", "-sorthits": "none",
            "-sorthsps": "none", "-seg": "none", "-soft_masking": ["true", "false"], "-gilist": "files",
            "-seqidlist": "files", "-negative_gilist": "files", "-negative_seqidlist": "files", "-taxids": "none",
            "-negative_taxids": "none", "-taxidlist": "files", "-negative_taxidlist": "files",
            "-entrez_query": "none", "-db_soft_mask": "none", "-db_hard_mask": "none", "-qcov_hsp_perc": "none",
            "-max_hsps": "none", "-culling_limit": "none", "-best_hit_overhang": "none",
            "-best_hit_score_edge": "none", "-max_target_seqs": "none", "-dbsize": "none", "-searchsp": "none",
            "-sum_stats": ["true", "false"], "-import_search_strategy": "files", "-export_search_strategy": "files",
            "-xdrop_ungap": "none", "-xdrop_gap": "none", "-xdrop_gap_final": "none", "-window_size": "none",
            "-num_threads": "none", "-mt_mode": "none", "-in_pssm": "files",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn tblastx() {
    #{
        opts: `
            -h                            print USAGE and DESCRIPTION; ignore all other parameters
            -help                         print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version                      print version number; ignore other arguments
            -query FILE                   input file name
            -query_loc STR                location on the query sequence in 1-based offsets (Format: start-stop)
            -strand STR                   query strand(s) to search against database/subject
            -query_gencode INT            genetic code to use to translate query
            -db STR                       BLAST database name
            -out FILE                     output file name
            -evalue FLOAT                 expectation value (E) threshold for saving hits
            -word_size INT                word size for wordfinder algorithm
            -max_intron_length INT        length of the largest intron allowed in a translated nucleotide sequence when linking
            -matrix STR                   scoring matrix name (normally BLOSUM62)
            -threshold FLOAT              minimum word score such that the word is added to the BLAST lookup table
            -db_gencode INT               genetic code to use to translate database/subjects (see user manual for details)
            -subject FILE                 subject sequence(s) to search
            -subject_loc STR              location on the subject sequence in 1-based offsets (Format: start-stop)
            -outfmt STR                   alignment view options (6 is tabular)
            -show_gis                     show NCBI GIs in deflines?
            -num_descriptions INT         number of database sequences to show one-line descriptions for Not applicable for outfmt
            -num_alignments INT           number of database sequences to show alignments for
            -line_length INT              line length for formatting alignments Not applicable for outfmt > 4
            -html                         produce HTML output?
            -sorthits INT                 sorting option for hits: alignment view options: 0 = Sort by evalue, 1 = Sort by bit
            -sorthsps INT                 sorting option for hps: 0 = Sort by hsp evalue, 1 = Sort by hsp score, 2 = Sort by hsp
            -seg STR                      filter query sequence with SEG (Format: 'yes', 'window locut hicut', or 'no' to disable)
            -soft_masking BOOL            apply filtering locations as soft masks
            -lcase_masking                use lower case filtering in query and subject sequence(s)?
            -gilist STR                   restrict search of database to list of GIs
            -seqidlist STR                restrict search of database to list of SeqIDs
            -negative_gilist STR          restrict search of database to everything except the specified GIs
            -negative_seqidlist STR       restrict search of database to everything except the specified SeqIDs
            -taxids STR                   restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxids STR          restrict search of database to everything except the specified taxonomy IDs and their
            -taxidlist STR                restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxidlist STR       restrict search of database to everything except the specified taxonomy IDs and their
            -no_taxid_expansion           do not expand the taxonomy IDs provided to their descendant taxonomy IDs
            -entrez_query STR             restrict search with the given Entrez query
            -db_soft_mask STR             filtering algorithm ID to apply to the BLAST database as soft masking
            -db_hard_mask STR             filtering algorithm ID to apply to the BLAST database as hard masking
            -qcov_hsp_perc FLOAT          percent query coverage per hsp
            -max_hsps INT                 set maximum number of HSPs per subject sequence to save for each query
            -culling_limit INT            if the query range of a hit is enveloped by that of at least this many higher-scoring
            -best_hit_overhang FLOAT      best Hit algorithm overhang value (recommended value: 0.1)
            -best_hit_score_edge FLOAT    best Hit algorithm score edge value (recommended value: 0.1)
            -subject_besthit              return only the best HSP for each non overlapping query region
            -max_target_seqs INT          maximum number of aligned sequences to keep (value of 5 or more is recommended)
            -dbsize INT                   effective length of the database
            -searchsp INT                 effective length of the search space
            -sum_stats BOOL               use sum statistics
            -import_search_strategy FILE  search strategy to use
            -export_search_strategy FILE  file name to record the search strategy used
            -xdrop_ungap FLOAT            x-dropoff value (in bits) for ungapped extensions
            -window_size INT              multiple hits window size, use 0 to specify 1-hit algorithm
            -parse_deflines               should the query and subject defline(s) be parsed?
            -num_threads INT              number of threads (CPUs) to use in the BLAST search
            -remote                       execute search remotely?
        `,
        values: #{
            "-query": k("fasta"), "-query_loc": "none", "-strand": ["both", "minus", "plus"],
            "-query_gencode": "none", "-db": k("blast_db"), "-out": "files", "-evalue": "none", "-word_size": "none",
            "-max_intron_length": "none",
            "-matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM30", "PAM70"],
            "-threshold": "none", "-db_gencode": "none", "-subject": k("fasta"), "-subject_loc": "none",
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
            "-num_descriptions": "none", "-num_alignments": "none", "-line_length": "none", "-sorthits": "none",
            "-sorthsps": "none", "-seg": "none", "-soft_masking": ["true", "false"], "-gilist": "files",
            "-seqidlist": "files", "-negative_gilist": "files", "-negative_seqidlist": "files", "-taxids": "none",
            "-negative_taxids": "none", "-taxidlist": "files", "-negative_taxidlist": "files",
            "-entrez_query": "none", "-db_soft_mask": "none", "-db_hard_mask": "none", "-qcov_hsp_perc": "none",
            "-max_hsps": "none", "-culling_limit": "none", "-best_hit_overhang": "none",
            "-best_hit_score_edge": "none", "-max_target_seqs": "none", "-dbsize": "none", "-searchsp": "none",
            "-sum_stats": ["true", "false"], "-import_search_strategy": "files", "-export_search_strategy": "files",
            "-xdrop_ungap": "none", "-window_size": "none", "-num_threads": "none",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn psiblast() {
    #{
        opts: `
            -h                            print USAGE and DESCRIPTION; ignore all other parameters
            -help                         print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version                      print version number; ignore other arguments
            -query FILE                   input file name
            -query_loc STR                location on the query sequence in 1-based offsets (Format: start-stop)
            -db STR                       BLAST database name
            -out FILE                     output file name
            -evalue FLOAT                 expectation value (E) threshold for saving hits
            -word_size INT                word size for wordfinder algorithm
            -gapopen INT                  cost to open a gap
            -gapextend INT                cost to extend a gap
            -matrix STR                   scoring matrix name (normally BLOSUM62)
            -threshold FLOAT              minimum word score such that the word is added to the BLAST lookup table
            -comp_based_stats STR         use composition-based statistics: D or d: default (equivalent to 2 ) 0 or F or f: No
            -subject FILE                 subject sequence(s) to search
            -subject_loc STR              location on the subject sequence in 1-based offsets (Format: start-stop)
            -outfmt STR                   alignment view options (6 is tabular)
            -show_gis                     show NCBI GIs in deflines?
            -num_descriptions INT         number of database sequences to show one-line descriptions for Not applicable for outfmt
            -num_alignments INT           number of database sequences to show alignments for
            -line_length INT              line length for formatting alignments Not applicable for outfmt > 4
            -html                         produce HTML output?
            -sorthits INT                 sorting option for hits: alignment view options: 0 = Sort by evalue, 1 = Sort by bit
            -sorthsps INT                 sorting option for hps: 0 = Sort by hsp evalue, 1 = Sort by hsp score, 2 = Sort by hsp
            -seg STR                      filter query sequence with SEG (Format: 'yes', 'window locut hicut', or 'no' to disable)
            -soft_masking BOOL            apply filtering locations as soft masks
            -lcase_masking                use lower case filtering in query and subject sequence(s)?
            -gilist STR                   restrict search of database to list of GIs
            -seqidlist STR                restrict search of database to list of SeqIDs
            -negative_gilist STR          restrict search of database to everything except the specified GIs
            -negative_seqidlist STR       restrict search of database to everything except the specified SeqIDs
            -taxids STR                   restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxids STR          restrict search of database to everything except the specified taxonomy IDs and their
            -taxidlist STR                restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxidlist STR       restrict search of database to everything except the specified taxonomy IDs and their
            -no_taxid_expansion           do not expand the taxonomy IDs provided to their descendant taxonomy IDs
            -ipglist STR                  restrict search of database to list of IPGs
            -negative_ipglist STR         restrict search of database to everything except the specified IPGs
            -entrez_query STR             restrict search with the given Entrez query
            -qcov_hsp_perc FLOAT          percent query coverage per hsp
            -max_hsps INT                 set maximum number of HSPs per subject sequence to save for each query
            -culling_limit INT            if the query range of a hit is enveloped by that of at least this many higher-scoring
            -best_hit_overhang FLOAT      best Hit algorithm overhang value (recommended value: 0.1)
            -best_hit_score_edge FLOAT    best Hit algorithm score edge value (recommended value: 0.1)
            -subject_besthit              return only the best HSP for each non overlapping query region
            -max_target_seqs INT          maximum number of aligned sequences to keep (value of 5 or more is recommended)
            -dbsize INT                   effective length of the database
            -searchsp INT                 effective length of the search space
            -sum_stats BOOL               use sum statistics
            -import_search_strategy FILE  search strategy to use
            -export_search_strategy FILE  file name to record the search strategy used
            -xdrop_ungap FLOAT            x-dropoff value (in bits) for ungapped extensions
            -xdrop_gap FLOAT              x-dropoff value (in bits) for preliminary gapped extensions
            -xdrop_gap_final FLOAT        x-dropoff value (in bits) for final gapped alignment
            -window_size INT              multiple hits window size, use 0 to specify 1-hit algorithm
            -gap_trigger FLOAT            number of bits to trigger gapping
            -parse_deflines               should the query and subject defline(s) be parsed?
            -num_threads INT              number of threads (CPUs) to use in the BLAST search
            -remote                       execute search remotely?
            -use_sw_tback                 compute locally optimal Smith-Waterman alignments?
            -num_iterations INT           number of iterations to perform (0 means run until convergence)
            -out_pssm FILE                file name to store checkpoint file
            -out_ascii_pssm FILE          file name to store ASCII version of PSSM
            -save_pssm_after_last_round   save PSSM after the last database search
            -save_each_pssm               save PSSM after each iteration
            -in_msa FILE                  file name of multiple sequence alignment to restart PSI-BLAST
            -msa_master_idx INT           ordinal number (1-based index) of the sequence to use as a master in the multiple
            -ignore_msa_master            ignore the master sequence when creating PSSM
            -in_pssm FILE                 PSI-BLAST checkpoint file
            -pseudocount INT              pseudo-count value used when constructing PSSM
            -inclusion_ethresh FLOAT      e-value inclusion threshold for pairwise alignments
            -phi_pattern FILE             file name containing pattern to search
        `,
        values: #{
            "-query": k("fasta"), "-query_loc": "none", "-db": k("blast_db"), "-out": "files", "-evalue": "none",
            "-word_size": "none", "-gapopen": "none", "-gapextend": "none",
            "-matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM30", "PAM70"],
            "-threshold": "none", "-comp_based_stats": ["0", "1", "2", "3", "D", "F", "T"], "-subject": k("fasta"),
            "-subject_loc": "none",
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
            "-num_descriptions": "none", "-num_alignments": "none", "-line_length": "none", "-sorthits": "none",
            "-sorthsps": "none", "-seg": "none", "-soft_masking": ["true", "false"], "-gilist": "files",
            "-seqidlist": "files", "-negative_gilist": "files", "-negative_seqidlist": "files", "-taxids": "none",
            "-negative_taxids": "none", "-taxidlist": "files", "-negative_taxidlist": "files", "-ipglist": "none",
            "-negative_ipglist": "none", "-entrez_query": "none", "-qcov_hsp_perc": "none", "-max_hsps": "none",
            "-culling_limit": "none", "-best_hit_overhang": "none", "-best_hit_score_edge": "none",
            "-max_target_seqs": "none", "-dbsize": "none", "-searchsp": "none", "-sum_stats": ["true", "false"],
            "-import_search_strategy": "files", "-export_search_strategy": "files", "-xdrop_ungap": "none",
            "-xdrop_gap": "none", "-xdrop_gap_final": "none", "-window_size": "none", "-gap_trigger": "none",
            "-num_threads": "none", "-num_iterations": "none", "-out_pssm": "files", "-out_ascii_pssm": "files",
            "-in_msa": "files", "-msa_master_idx": "none", "-in_pssm": "files", "-pseudocount": "none",
            "-inclusion_ethresh": "none", "-phi_pattern": "files",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn rpsblast() {
    #{
        opts: `
            -h                            print USAGE and DESCRIPTION; ignore all other parameters
            -help                         print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version                      print version number; ignore other arguments
            -query FILE                   input file name
            -query_loc STR                location on the query sequence in 1-based offsets (Format: start-stop)
            -db STR                       BLAST database name
            -out FILE                     output file name
            -evalue FLOAT                 expectation value (E) threshold for saving hits
            -comp_based_stats STR         use composition-based statistics: D or d: default (equivalent to 1 ) 0 or F or f
            -outfmt STR                   alignment view options (6 is tabular)
            -show_gis                     show NCBI GIs in deflines?
            -num_descriptions INT         number of database sequences to show one-line descriptions for Not applicable for outfmt
            -num_alignments INT           number of database sequences to show alignments for
            -line_length INT              line length for formatting alignments Not applicable for outfmt > 4
            -html                         produce HTML output?
            -sorthits INT                 sorting option for hits: alignment view options: 0 = Sort by evalue, 1 = Sort by bit
            -sorthsps INT                 sorting option for hps: 0 = Sort by hsp evalue, 1 = Sort by hsp score, 2 = Sort by hsp
            -seg STR                      filter query sequence with SEG (Format: 'yes', 'window locut hicut', or 'no' to disable)
            -soft_masking BOOL            apply filtering locations as soft masks
            -lcase_masking                use lower case filtering in query and subject sequence(s)?
            -entrez_query STR             restrict search with the given Entrez query
            -qcov_hsp_perc FLOAT          percent query coverage per hsp
            -max_hsps INT                 set maximum number of HSPs per subject sequence to save for each query
            -max_target_seqs INT          maximum number of aligned sequences to keep (value of 5 or more is recommended)
            -dbsize INT                   effective length of the database
            -searchsp INT                 effective length of the search space
            -sum_stats BOOL               use sum statistics
            -import_search_strategy FILE  search strategy to use
            -export_search_strategy FILE  file name to record the search strategy used
            -xdrop_ungap FLOAT            x-dropoff value (in bits) for ungapped extensions
            -xdrop_gap FLOAT              x-dropoff value (in bits) for preliminary gapped extensions
            -xdrop_gap_final FLOAT        x-dropoff value (in bits) for final gapped alignment
            -window_size INT              multiple hits window size, use 0 to specify 1-hit algorithm
            -parse_deflines               should the query and subject defline(s) be parsed?
            -num_threads INT              number of threads to use in RPS BLAST search: 0 (auto = num of databases) 1 (disable) max
            -mt_mode INT                  multi-thread mode to use in RPS BLAST search: 0 (auto) split by database vols 1 split by
            -remote                       execute search remotely?
            -use_sw_tback                 compute locally optimal Smith-Waterman alignments?
        `,
        values: #{
            "-query": k("fasta"), "-query_loc": "none", "-db": k("blast_db"), "-out": "files", "-evalue": "none",
            "-comp_based_stats": ["0", "1", "2", "3", "D", "F", "T"],
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
            "-num_descriptions": "none", "-num_alignments": "none", "-line_length": "none", "-sorthits": "none",
            "-sorthsps": "none", "-seg": "none", "-soft_masking": ["true", "false"], "-entrez_query": "none",
            "-qcov_hsp_perc": "none", "-max_hsps": "none", "-max_target_seqs": "none", "-dbsize": "none",
            "-searchsp": "none", "-sum_stats": ["true", "false"], "-import_search_strategy": "files",
            "-export_search_strategy": "files", "-xdrop_ungap": "none", "-xdrop_gap": "none",
            "-xdrop_gap_final": "none", "-window_size": "none", "-num_threads": "none", "-mt_mode": "none",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn rpstblastn() {
    #{
        opts: `
            -h                            print USAGE and DESCRIPTION; ignore all other parameters
            -help                         print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version                      print version number; ignore other arguments
            -query FILE                   input file name
            -query_gencode INT            genetic code to use to translate query
            -query_loc STR                location on the query sequence in 1-based offsets (Format: start-stop)
            -strand STR                   query strand(s) to search against database/subject
            -db STR                       BLAST database name
            -out FILE                     output file name
            -evalue FLOAT                 expectation value (E) threshold for saving hits
            -comp_based_stats STR         use composition-based statistics: D or d: default (equivalent to 1 ) 0 or F or f: No
            -outfmt STR                   alignment view options (6 is tabular)
            -show_gis                     show NCBI GIs in deflines?
            -num_descriptions INT         number of database sequences to show one-line descriptions for Not applicable for outfmt
            -num_alignments INT           number of database sequences to show alignments for
            -line_length INT              line length for formatting alignments Not applicable for outfmt > 4
            -html                         produce HTML output?
            -sorthits INT                 sorting option for hits: alignment view options: 0 = Sort by evalue, 1 = Sort by bit
            -sorthsps INT                 sorting option for hps: 0 = Sort by hsp evalue, 1 = Sort by hsp score, 2 = Sort by hsp
            -seg STR                      filter query sequence with SEG (Format: 'yes', 'window locut hicut', or 'no' to disable)
            -soft_masking BOOL            apply filtering locations as soft masks
            -lcase_masking                use lower case filtering in query and subject sequence(s)?
            -entrez_query STR             restrict search with the given Entrez query
            -qcov_hsp_perc FLOAT          percent query coverage per hsp
            -max_hsps INT                 set maximum number of HSPs per subject sequence to save for each query
            -max_target_seqs INT          maximum number of aligned sequences to keep (value of 5 or more is recommended)
            -dbsize INT                   effective length of the database
            -searchsp INT                 effective length of the search space
            -sum_stats BOOL               use sum statistics
            -import_search_strategy FILE  search strategy to use
            -export_search_strategy FILE  file name to record the search strategy used
            -xdrop_ungap FLOAT            x-dropoff value (in bits) for ungapped extensions
            -xdrop_gap FLOAT              x-dropoff value (in bits) for preliminary gapped extensions
            -xdrop_gap_final FLOAT        x-dropoff value (in bits) for final gapped alignment
            -window_size INT              multiple hits window size, use 0 to specify 1-hit algorithm
            -ungapped                     perform ungapped alignment only?
            -parse_deflines               should the query and subject defline(s) be parsed?
            -num_threads INT              number of threads to use in RPS BLAST search: 0 (auto = num of databases) 1 (disable) max
            -mt_mode INT                  multi-thread mode to use in RPS BLAST search: 0 (auto) split by database vols 1 split by
            -remote                       execute search remotely?
            -use_sw_tback                 compute locally optimal Smith-Waterman alignments?
        `,
        values: #{
            "-query": k("fasta"), "-query_gencode": "none", "-query_loc": "none",
            "-strand": ["both", "minus", "plus"], "-db": k("blast_db"), "-out": "files", "-evalue": "none",
            "-comp_based_stats": ["0", "1", "2", "3", "D", "F", "T"],
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
            "-num_descriptions": "none", "-num_alignments": "none", "-line_length": "none", "-sorthits": "none",
            "-sorthsps": "none", "-seg": "none", "-soft_masking": ["true", "false"], "-entrez_query": "none",
            "-qcov_hsp_perc": "none", "-max_hsps": "none", "-max_target_seqs": "none", "-dbsize": "none",
            "-searchsp": "none", "-sum_stats": ["true", "false"], "-import_search_strategy": "files",
            "-export_search_strategy": "files", "-xdrop_ungap": "none", "-xdrop_gap": "none",
            "-xdrop_gap_final": "none", "-window_size": "none", "-num_threads": "none", "-mt_mode": "none",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn deltablast() {
    #{
        opts: `
            -h                               print USAGE and DESCRIPTION; ignore all other parameters
            -help                            print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version                         print version number; ignore other arguments
            -query FILE                      input file name
            -query_loc STR                   location on the query sequence in 1-based offsets (Format: start-stop)
            -db STR                          BLAST database name
            -out FILE                        output file name
            -evalue FLOAT                    expectation value (E) threshold for saving hits
            -word_size INT                   word size for wordfinder algorithm
            -gapopen INT                     cost to open a gap
            -gapextend INT                   cost to extend a gap
            -matrix STR                      scoring matrix name (normally BLOSUM62)
            -threshold FLOAT                 minimum word score such that the word is added to the BLAST lookup table
            -comp_based_stats STR            use composition-based statistics: D or d: default (equivalent to 1 ) 0 or F or f: No
            -subject FILE                    subject sequence(s) to search
            -subject_loc STR                 location on the subject sequence in 1-based offsets (Format: start-stop)
            -outfmt STR                      alignment view options (6 is tabular)
            -show_gis                        show NCBI GIs in deflines?
            -num_descriptions INT            number of database sequences to show one-line descriptions for Not applicable for outfmt
            -num_alignments INT              number of database sequences to show alignments for
            -line_length INT                 line length for formatting alignments Not applicable for outfmt > 4
            -html                            produce HTML output?
            -sorthits INT                    sorting option for hits: alignment view options: 0 = Sort by evalue, 1 = Sort by bit
            -sorthsps INT                    sorting option for hps: 0 = Sort by hsp evalue, 1 = Sort by hsp score, 2 = Sort by hsp
            -seg STR                         filter query sequence with SEG (Format: 'yes', 'window locut hicut', or 'no' to disable)
            -soft_masking BOOL               apply filtering locations as soft masks
            -lcase_masking                   use lower case filtering in query and subject sequence(s)?
            -gilist STR                      restrict search of database to list of GIs
            -seqidlist STR                   restrict search of database to list of SeqIDs
            -negative_gilist STR             restrict search of database to everything except the specified GIs
            -negative_seqidlist STR          restrict search of database to everything except the specified SeqIDs
            -taxids STR                      restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxids STR             restrict search of database to everything except the specified taxonomy IDs and their
            -taxidlist STR                   restrict search of database to include only the specified taxonomy IDs and their
            -negative_taxidlist STR          restrict search of database to everything except the specified taxonomy IDs and their
            -no_taxid_expansion              do not expand the taxonomy IDs provided to their descendant taxonomy IDs
            -entrez_query STR                restrict search with the given Entrez query
            -qcov_hsp_perc FLOAT             percent query coverage per hsp
            -max_hsps INT                    set maximum number of HSPs per subject sequence to save for each query
            -culling_limit INT               if the query range of a hit is enveloped by that of at least this many higher-scoring
            -best_hit_overhang FLOAT         best Hit algorithm overhang value (recommended value: 0.1)
            -best_hit_score_edge FLOAT       best Hit algorithm score edge value (recommended value: 0.1)
            -subject_besthit                 return only the best HSP for each non overlapping query region
            -max_target_seqs INT             maximum number of aligned sequences to keep (value of 5 or more is recommended)
            -dbsize INT                      effective length of the database
            -searchsp INT                    effective length of the search space
            -sum_stats BOOL                  use sum statistics
            -import_search_strategy FILE     search strategy to use
            -export_search_strategy FILE     file name to record the search strategy used
            -xdrop_ungap FLOAT               x-dropoff value (in bits) for ungapped extensions
            -xdrop_gap FLOAT                 x-dropoff value (in bits) for preliminary gapped extensions
            -xdrop_gap_final FLOAT           x-dropoff value (in bits) for final gapped alignment
            -window_size INT                 multiple hits window size, use 0 to specify 1-hit algorithm
            -gap_trigger FLOAT               number of bits to trigger gapping
            -parse_deflines                  should the query and subject defline(s) be parsed?
            -num_threads INT                 number of threads (CPUs) to use in the BLAST search
            -remote                          execute search remotely?
            -use_sw_tback                    compute locally optimal Smith-Waterman alignments?
            -num_iterations INT              number of iterations to perform (0 means run until convergence)
            -out_pssm FILE                   file name to store checkpoint file
            -out_ascii_pssm FILE             file name to store ASCII version of PSSM
            -save_pssm_after_last_round      save PSSM after the last database search
            -save_each_pssm                  save PSSM after each iteration
            -pseudocount INT                 pseudo-count value used when constructing PSSM
            -domain_inclusion_ethresh FLOAT  e-value inclusion threshold for alignments with conserved domains
            -inclusion_ethresh FLOAT         e-value inclusion threshold for pairwise alignments
            -rpsdb STR                       BLAST domain database name
            -show_domain_hits                show domain hits
        `,
        values: #{
            "-query": k("fasta"), "-query_loc": "none", "-db": k("blast_db"), "-out": "files", "-evalue": "none",
            "-word_size": "none", "-gapopen": "none", "-gapextend": "none",
            "-matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM30", "PAM70"],
            "-threshold": "none", "-comp_based_stats": ["0", "1", "2", "3", "D", "F", "T"], "-subject": k("fasta"),
            "-subject_loc": "none",
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
            "-num_descriptions": "none", "-num_alignments": "none", "-line_length": "none", "-sorthits": "none",
            "-sorthsps": "none", "-seg": "none", "-soft_masking": ["true", "false"], "-gilist": "files",
            "-seqidlist": "files", "-negative_gilist": "files", "-negative_seqidlist": "files", "-taxids": "none",
            "-negative_taxids": "none", "-taxidlist": "files", "-negative_taxidlist": "files",
            "-entrez_query": "none", "-qcov_hsp_perc": "none", "-max_hsps": "none", "-culling_limit": "none",
            "-best_hit_overhang": "none", "-best_hit_score_edge": "none", "-max_target_seqs": "none",
            "-dbsize": "none", "-searchsp": "none", "-sum_stats": ["true", "false"],
            "-import_search_strategy": "files", "-export_search_strategy": "files", "-xdrop_ungap": "none",
            "-xdrop_gap": "none", "-xdrop_gap_final": "none", "-window_size": "none", "-gap_trigger": "none",
            "-num_threads": "none", "-num_iterations": "none", "-out_pssm": "files", "-out_ascii_pssm": "files",
            "-pseudocount": "none", "-domain_inclusion_ethresh": "none", "-inclusion_ethresh": "none",
            "-rpsdb": "none",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn makeblastdb() {
    #{
        opts: `
            -dbtype STR                  molecule type of target db
            -h                           print USAGE and DESCRIPTION; ignore all other parameters
            -help                        print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -help-full                   print USAGE, DESCRIPTION and ARGUMENTS, including hidden ones; ignore all other parameters
            -version                     print version number; ignore other arguments
            -in FILE                     input file/database name
            -input_type STR              type of the data specified in input_file
            -title STR                   title for BLAST database
            -parse_seqids                option to parse seqid for FASTA input if set, for all other input types seqids are parsed
            -hash_index                  create index of sequence hash values
            -mask_data STR               comma-separated list of input files containing masking data as produced by NCBI masking
            -mask_id STR                 comma-separated list of strings to uniquely identify the masking algorithm
            -mask_desc STR               comma-separated list of free form strings to describe the masking algorithm details
            -gi_mask                     create GI indexed masking data
            -gi_mask_name STR            comma-separated list of masking data output files
            -out STR                     name of BLAST database to be created
            -blastdb_version INT         version of BLAST database to be created
            -max_file_sz STR             maximum file size for BLAST database files
            -metadata_output_prefix STR  path prefix for location of database files in metadata
            -logfile FILE                file to which the program log should be redirected
            -taxid INT                   taxonomy ID to assign to all sequences
            -taxid_map FILE              text file mapping sequence IDs to taxonomy IDs
            -oid_masks INT               0x01 Exclude Model
        `,
        values: #{
            "-dbtype": ["nucl", "prot"], "-in": k("fasta"),
            "-input_type": ["fasta", "blastdb", "asn1_bin", "asn1_txt"], "-title": "none", "-mask_data": "files",
            "-mask_id": "none", "-mask_desc": "none", "-gi_mask_name": "none", "-out": "files",
            "-blastdb_version": "none", "-max_file_sz": "none", "-metadata_output_prefix": "none",
            "-logfile": "files", "-taxid": "none", "-taxid_map": "files", "-oid_masks": "none",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn blastdbcmd() {
    #{
        opts: `
            -h                           print USAGE and DESCRIPTION; ignore all other parameters
            -help                        print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version                     print version number; ignore other arguments
            -db STR                      BLAST database name
            -dbtype STR                  molecule type stored in BLAST database
            -entry STR                   comma-delimited search string(s) of sequence identifiers: e.g.: 555, AC147927
            -entry_batch FILE            input file for batch processing
            -ipg INT                     IPG to retrieve
            -ipg_batch FILE              input file for batch processing
            -info                        print BLAST database information
            -metadata                    generate BLAST database metadata
            -metadata_output_prefix STR  path prefix for location of database files in metadata
            -tax_info                    print taxonomic information contained in this BLAST database
            -range STR                   range of sequence to extract in 1-based offsets
            -strand STR                  strand of nucleotide sequence to extract
            -mask_sequence_with STR      produce lower-case masked FASTA using the algorithm ID specified
            -taxids STR                  comma-delimited taxonomy identifiers
            -taxidlist FILE              input file for taxonomy identifiers
            -no_taxid_expansion          do not expand the taxonomy IDs provided to their descendant taxonomy IDs
            -out FILE                    output file name
            -outfmt STR                  output format, where the available format specifiers are: %f means sequence in FASTA
            -target_only                 definition line should contain target entry only
            -get_dups                    retrieve duplicate accessions
            -line_length INT             line length for output
            -ctrl_a                      use Ctrl-A as the non-redundant defline separator
            -show_blastdb_search_path    displays the default BLAST database search paths
            -list STR                    list BLAST databases in the specified directory
            -remove_redundant_dbs        remove the databases that are referenced by another alias file in the directory in
            -recursive                   recursively traverse the directory structure to list available BLAST databases
            -list_outfmt STR             output format for the list option, where the available format specifiers are: %f means
            -exact_length                get exact length for db info
            -long_seqids                 use long seq id for fasta deflines
            -logfile FILE                file to which the program log should be redirected
        `,
        values: #{
            "-db": k("blast_db"), "-dbtype": ["nucl", "prot"], "-entry": "none", "-entry_batch": "files",
            "-ipg": "none", "-ipg_batch": "files", "-metadata_output_prefix": "none", "-range": "none",
            "-strand": ["minus", "plus"], "-mask_sequence_with": "none", "-taxids": "none", "-taxidlist": "files",
            "-out": "files", "-outfmt": "none", "-line_length": "none", "-list": "none", "-list_outfmt": "none",
            "-logfile": "files",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn blast_formatter() {
    #{
        opts: `
            -h                     print USAGE and DESCRIPTION; ignore all other parameters
            -help                  print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version               print version number; ignore other arguments
            -rid STR               BLAST Request ID (RID)
            -archive FILE          file containing BLAST Archive format in ASN.1 (i.e.: output format 11)
            -outfmt STR            alignment view options (6 is tabular)
            -show_gis              show NCBI GIs in deflines?
            -num_descriptions INT  number of database sequences to show one-line descriptions for Not applicable for outfmt
            -num_alignments INT    number of database sequences to show alignments for
            -line_length INT       line length for formatting alignments Not applicable for outfmt > 4
            -html                  produce HTML output?
            -sorthits INT          sorting option for hits: alignment view options: 0 = Sort by evalue, 1 = Sort by bit
            -sorthsps INT          sorting option for hps: 0 = Sort by hsp evalue, 1 = Sort by hsp score, 2 = Sort by hsp
            -max_target_seqs INT   maximum number of aligned sequences to keep (value of 5 or more is recommended)
            -out FILE              output file name
            -parse_deflines        should the query and subject defline(s) be parsed?
        `,
        values: #{
            "-rid": "none", "-archive": "files",
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
            "-num_descriptions": "none", "-num_alignments": "none", "-line_length": "none", "-sorthits": "none",
            "-sorthsps": "none", "-max_target_seqs": "none", "-out": "files",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn blastdb_aliastool() {
    #{
        opts: `
            -h                    print USAGE and DESCRIPTION; ignore all other parameters
            -help                 print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version              print version number; ignore other arguments
            -gi_file_in FILE      text file to convert, should contain one GI per line
            -gi_file_out FILE     file name of converted GI file
            -db STR               BLAST database name
            -dbtype STR           molecule type stored in BLAST database
            -title STR            title for BLAST database
            -gilist FILE          text or binary gi file to restrict the BLAST database provided in -db argument If text
            -seqidlist FILE       text sequence id or accession file to restrict the BLAST database provided in -db argument
            -taxidlist FILE       text taxonomy id file to restrict the BLAST database provided in -db argument
            -oid_masks INT        create alias db with pre-built oid masks 0x01 Exclude Model
            -out STR              name of BLAST database alias to be created
            -dblist STR           a space separated list of BLAST database names to aggregate
            -dblist_file FILE     a file containing a list of BLAST database names to aggregate, one per line
            -vdblist STR          a space separated list of VDB names to aggregate
            -vdblist_file FILE    a file containing a list of vdb names to aggregate, one per line
            -num_volumes INT      number of volumes to aggregate, in which case the basename for the database is extracted
            -seqid_file_in FILE   text file to convert, should contain one seq id per line
            -seqid_title STR      title for seqid list
            -seqid_file_out STR   file name of converted seq id file
            -seqid_db STR         BLAST database for seqidlist
            -seqid_dbtype STR     molecule type BLAST database
            -seqid_file_info STR  display seqidlist file info
            -logfile FILE         file to which the program log should be redirected
        `,
        values: #{
            "-gi_file_in": "files", "-gi_file_out": "files", "-db": k("blast_db"), "-dbtype": ["nucl", "prot"],
            "-title": "none", "-gilist": "files", "-seqidlist": "files", "-taxidlist": "files", "-oid_masks": "none",
            "-out": "files", "-dblist": "none", "-dblist_file": "files", "-vdblist": "none",
            "-vdblist_file": "files", "-num_volumes": "none", "-seqid_file_in": "files", "-seqid_title": "none",
            "-seqid_file_out": "none", "-seqid_db": "none", "-seqid_dbtype": ["nucl", "prot"],
            "-seqid_file_info": "none", "-logfile": "files",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn dustmasker() {
    #{
        opts: `
            -h                   print USAGE and DESCRIPTION; ignore all other parameters
            -help                print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -xmlhelp             print USAGE, DESCRIPTION and ARGUMENTS in XML format; ignore all other parameters
            -in FILE             input file name
            -out FILE            output file name
            -window INT          DUST window length
            -level INT           DUST level (score threshold for subwindows)
            -linker INT          DUST linker (how close masked intervals should be to get merged together)
            -infmt STR           input format (possible values: fasta, blastdb)
            -outfmt STR          alignment view options (6 is tabular)
            -parse_seqids        parse Seq-ids in FASTA input
            -hard_masking        use hard masking for fasta outfmt
            -version-full        print extended version data; ignore other arguments
            -version-full-xml    print extended version data in XML format; ignore other arguments
            -version-full-json   print extended version data in JSON format; ignore other arguments
        `,
        values: #{
            "-in": k("fasta"), "-out": "files", "-window": "none", "-level": "none", "-linker": "none",
            "-infmt": "none",
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
        },
        single_dash: true,
        args: ["none"],
    }
}

fn segmasker() {
    #{
        opts: `
            -h                   print USAGE and DESCRIPTION; ignore all other parameters
            -help                print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -xmlhelp             print USAGE, DESCRIPTION and ARGUMENTS in XML format; ignore all other parameters
            -version-full        print extended version data; ignore other arguments
            -version-full-xml    print extended version data in XML format; ignore other arguments
            -version-full-json   print extended version data in JSON format; ignore other arguments
            -in FILE             input file name
            -out FILE            output file name
            -infmt STR           controls the format of the masker input
            -parse_seqids        parse Seq-ids in FASTA input
            -outfmt STR          alignment view options (6 is tabular)
            -window INT          SEG window
            -locut FLOAT         SEG locut
            -hicut FLOAT         SEG hicut
        `,
        values: #{
            "-in": k("fasta"), "-out": "files", "-infmt": ["blastdb", "fasta"],
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
            "-window": "none", "-locut": "none", "-hicut": "none",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn windowmasker() {
    #{
        opts: `
            -h                   print USAGE and DESCRIPTION; ignore all other parameters
            -help                print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -xmlhelp             print USAGE, DESCRIPTION and ARGUMENTS in XML format; ignore all other parameters
            -version-full        print extended version data; ignore other arguments
            -version-full-xml    print extended version data in XML format; ignore other arguments
            -version-full-json   print extended version data in JSON format; ignore other arguments
            -ustat STR           file with unit counts
            -in FILE             input file name (not optional if used with -mk_counts or -convert options)
            -out FILE            output file name
            -checkdup BOOL       check for duplicate sequences
            -fa_list BOOL        indicates that -input represents a file containing a list of names of fasta files to
            -mem INT             memory available for mk_counts option in megabytes
            -meta STR            add metadata to the counts file
            -unit INT            number of bases in a unit
            -genome_size INT     total size of the genome
            -window INT          window size
            -t_extend INT        window score above which it is allowed to extend masking
            -t_thres INT         window score threshold used to trigger masking
            -set_t_high INT      alternative high score for a unit if theoriginal unit score is more than highscore
            -set_t_low INT       alternative low score for a unit if theoriginal unit score is lower than lowscore
            -parse_seqids        parse Seq-ids in FASTA input
            -outfmt STR          alignment view options (6 is tabular)
            -t_high INT          maximum useful unit score
            -t_high_pct FLOAT    maximum useful unit score as percentage
            -t_thres_pct FLOAT   window score threshold used to trigger masking as percentage
            -t_extend_pct FLOAT  window score above which it is allowed to extend masking as percentage
            -t_low INT           minimum useful unit score
            -t_low_pct FLOAT     minimum useful unit score as percentage
            -infmt STR           controls the format of the masker input
            -exclude_ids STR     file containing the list of ids to exclude from processing
            -ids STR             file containing the list of ids to process
            -text_match BOOL     match ids as strings
            -sformat STR         controls the format of the output file containing the unit counts
            -smem INT            target size of the output file containing the unit counts
            -dust BOOL           combine window masking with dusting
            -dust_level INT      dust minimum level
            -mk_counts           generate frequency counts for a database
            -convert             convert counts between different formats
        `,
        values: #{
            "-ustat": "none", "-in": k("fasta"), "-out": "files", "-checkdup": ["true", "false"],
            "-fa_list": ["true", "false"], "-mem": "none", "-meta": "none", "-unit": "none", "-genome_size": "none",
            "-window": "none", "-t_extend": "none", "-t_thres": "none", "-set_t_high": "none", "-set_t_low": "none",
            "-outfmt": [#{value: "0", desc: "pairwise"}, #{value: "1", desc: "query-anchored showing identities"}, #{value: "2", desc: "query-anchored, no identities"}, #{value: "3", desc: "flat query-anchored showing identities"}, #{value: "4", desc: "flat query-anchored, no identities"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "tabular"}, #{value: "7", desc: "tabular with comment lines"}, #{value: "8", desc: "seqalign (text ASN.1)"}, #{value: "9", desc: "seqalign (binary ASN.1)"}, #{value: "10", desc: "comma-separated values"}, #{value: "11", desc: "BLAST archive (ASN.1)"}, #{value: "12", desc: "seqalign (JSON)"}, #{value: "13", desc: "multiple-file BLAST JSON"}, #{value: "14", desc: "multiple-file BLAST XML2"}, #{value: "15", desc: "single-file BLAST JSON"}, #{value: "16", desc: "single-file BLAST XML2"}, #{value: "17", desc: "SAM"}, #{value: "18", desc: "organism report"}, #{value: "19", desc: "single-file BLAST tabular"}, #{value: "20", desc: "comma-separated values with header lines"}],
            "-t_high": "none", "-t_high_pct": "none", "-t_thres_pct": "none", "-t_extend_pct": "none",
            "-t_low": "none", "-t_low_pct": "none", "-infmt": ["blastdb", "fasta", "seqids"], "-exclude_ids": "none",
            "-ids": "none", "-text_match": ["true", "false"], "-sformat": ["ascii", "binary", "oascii", "obinary"],
            "-smem": "none", "-dust": ["true", "false"], "-dust_level": "none",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn makeprofiledb() {
    #{
        opts: `
            -in FILE               input file that contains a list of smp files (delimited by space, tab or newline)
            -h                     print USAGE and DESCRIPTION; ignore all other parameters
            -help                  print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version               print version number; ignore other arguments
            -binary                scoremats are in binary format
            -title STR             title for database
            -threshold FLOAT       minimum word score to add a word to the lookup table
            -force                 use cmdline threshold
            -out STR               name of database to be created
            -blastdb_version INT   version of BLAST database to be created
            -max_smp_vol INT       maximum number of SMP files per DB volume
            -dbtype STR            output database type: cobalt, delta, rps
            -index BOOL            create Index Files
            -gapopen INT           cost to open a gap
            -gapextend INT         cost to extend a gap,
            -scale FLOAT           pssm Scale factor
            -matrix STR            scoring matrix name
            -obsr_threshold FLOAT  exclude domains with with maximum number of independent observations below this threshold
            -exclude_invalid BOOL  exclude domains that do not pass validation test
            -taxid INT             taxonomy ID to assign to all sequences
            -taxid_map FILE        text file mapping sequence IDs to taxonomy IDs
            -logfile FILE          file to which the program log should be redirected
        `,
        values: #{
            "-in": k("fasta"), "-title": "none", "-threshold": "none", "-out": "files", "-blastdb_version": "none",
            "-max_smp_vol": "none", "-dbtype": ["nucl", "prot"], "-index": ["true", "false"], "-gapopen": "none",
            "-gapextend": "none", "-scale": "none",
            "-matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM30", "PAM70"],
            "-obsr_threshold": "none", "-exclude_invalid": ["true", "false"], "-taxid": "none",
            "-taxid_map": "files", "-logfile": "files",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn blastdbcheck() {
    #{
        opts: `
            -h                  print USAGE and DESCRIPTION; ignore all other parameters
            -help               print USAGE, DESCRIPTION and ARGUMENTS; ignore all other parameters
            -version            print version number; ignore other arguments
            -db STR             specify a database name
            -dbtype STR         molecule type of database
            -dir STR            specify a directory containing one or more databases
            -recursive          specify true to recurse through all dbs in directory tree
            -verbosity INT      0=Quiet, 1=Brief, 2=Summary, 3=Detailed, 4=Minutiae
            -full               if true, test every sequence (warning: may be slow)
            -stride INT         check integrity of every Nth sequence
            -random INT         check this many randomly selected sequences
            -ends INT           check this many sequences at each end of the database
            -no_isam            disable ISAM testing
            -legacy             enable check for existence of temporary files
            -must_have_taxids   require that all sequences in the database have taxid set
            -cdd_delta          do aditional tests for a CDD database for DELTA-BLAST
        `,
        values: #{
            "-db": k("blast_db"), "-dbtype": ["nucl", "prot"], "-dir": "none", "-verbosity": "none",
            "-stride": "none", "-random": "none", "-ends": "none",
        },
        single_dash: true,
        args: ["none"],
    }
}

fn update_blastdb() {
    #{
        opts: `
            --source LOCATION           where to download the databases from (ncbi, aws or gcp)
            --decompress                decompress the archives and delete them after downloading
            --showall[=FORMAT]          show all the available pre-formatted databases
            --blastdb_version N         the BLAST database version to download (4 or 5)
            --timeout SECONDS           timeout on the connection to NCBI
            --force                     download even if there is already an archive locally
            --verbose                   increase the verbosity
            --quiet                     produce no output
            --force_ftp                 use FTP instead of HTTPS
            --passive                   use passive FTP
            --num_threads N             number of threads to use for the download
            --legacy_exit_code          use the legacy exit codes
            --version                   print the version and exit
            --help                      print the help and exit
        `,
        values: #{
            "--source": ["ncbi", "aws", "gcp"], "--showall": ["tsv", "pretty"], "--blastdb_version": ["4", "5"],
        },
        args: ["none"],
    }
}

fn spec(cmd) {
    switch cmd {
        "blastn" => blastn(),
        "blastp" => blastp(),
        "blastx" => blastx(),
        "tblastn" => tblastn(),
        "tblastx" => tblastx(),
        "psiblast" => psiblast(),
        "rpsblast" => rpsblast(),
        "rpstblastn" => rpstblastn(),
        "deltablast" => deltablast(),
        "makeblastdb" => makeblastdb(),
        "blastdbcmd" => blastdbcmd(),
        "blast_formatter" => blast_formatter(),
        "blastdb_aliastool" => blastdb_aliastool(),
        "dustmasker" => dustmasker(),
        "segmasker" => segmasker(),
        "windowmasker" => windowmasker(),
        "makeprofiledb" => makeprofiledb(),
        "blastdbcheck" => blastdbcheck(),
        "update_blastdb.pl" => update_blastdb(),
        _ => #{},
    }
}
