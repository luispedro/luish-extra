// HMMER 3.4, from `PROGRAM -h`.

fn k(name) { "@extra-complete/bio/kinds:" + name }

fn hmmsearch() {
    #{
        opts: `
            -h                show brief help on version and usage
            -o <f>            direct output to file <f>, not stdout
            -A <f>            save multiple alignment of all hits to file <f>
            --tblout <f>      save parseable table of per-sequence hits to file <f>
            --domtblout <f>   save parseable table of per-domain hits to file <f>
            --pfamtblout <f>  save table of hits and domains to file, in Pfam format <f>
            --acc             prefer accessions over names in output
            --noali           don't output alignments, so output is smaller
            --notextw         unlimit ASCII text output line width
            --textw <n>       set max width of ASCII text output lines
            -E <x>            report sequences <= this E-value threshold in output
            -T <x>            report sequences >= this score threshold in output
            --domE <x>        report domains <= this E-value threshold in output
            --domT <x>        report domains >= this score cutoff in output
            --incE <x>        consider sequences <= this E-value threshold as significant
            --incT <x>        consider sequences >= this score threshold as significant
            --incdomE <x>     consider domains <= this E-value threshold as significant
            --incdomT <x>     consider domains >= this score threshold as significant
            --cut_ga          use profile's GA gathering cutoffs to set all thresholding
            --cut_nc          use profile's NC noise cutoffs to set all thresholding
            --cut_tc          use profile's TC trusted cutoffs to set all thresholding
            --max             turn all heuristic filters off (less speed, more power)
            --F1 <x>          stage 1 (MSV) threshold: promote hits w/ P <= F1
            --F2 <x>          stage 2 (Vit) threshold: promote hits w/ P <= F2
            --F3 <x>          stage 3 (Fwd) threshold: promote hits w/ P <= F3
            --nobias          turn off composition bias filter
            --nonull2         turn off biased composition score corrections
            -Z <x>            set # of comparisons done, for E-value calculation
            --domZ <x>        set # of significant seqs, for domain E-value calculation
            --seed <n>        set RNG seed to <n> (if 0: one-time arbitrary seed)
            --tformat <s>     assert target <seqfile> is in format <s>: no autodetection
            --cpu <n>         number of parallel CPU workers to use for multithreads
            --stall           arrest after start: for debugging MPI under gdb
            --mpi             run as an MPI parallel program
        `,
        values: #{
            "-o": "files", "-A": "files", "--tblout": "files", "--domtblout": "files", "--pfamtblout": "files",
            "--textw": "none", "-E": "none", "-T": "none", "--domE": "none", "--domT": "none", "--incE": "none",
            "--incT": "none", "--incdomE": "none", "--incdomT": "none", "--F1": "none", "--F2": "none",
            "--F3": "none", "-Z": "none", "--domZ": "none", "--seed": "none",
            "--tformat": ["fasta", "embl", "genbank", "ddbj", "uniprot", "ncbi", "daemon", "hmmpgmd"],
            "--cpu": "none",
        },
        args: [k("hmm"), k("sequences")],
    }
}

fn hmmscan() {
    #{
        opts: `
            -h                show brief help on version and usage
            -o <f>            direct output to file <f>, not stdout
            --tblout <f>      save parseable table of per-sequence hits to file <f>
            --domtblout <f>   save parseable table of per-domain hits to file <f>
            --pfamtblout <f>  save table of hits and domains to file, in Pfam format <f>
            --acc             prefer accessions over names in output
            --noali           don't output alignments, so output is smaller
            --notextw         unlimit ASCII text output line width
            --textw <n>       set max width of ASCII text output lines
            -E <x>            report models <= this E-value threshold in output
            -T <x>            report models >= this score threshold in output
            --domE <x>        report domains <= this E-value threshold in output
            --domT <x>        report domains >= this score cutoff in output
            --incE <x>        consider models <= this E-value threshold as significant
            --incT <x>        consider models >= this score threshold as significant
            --incdomE <x>     consider domains <= this E-value threshold as significant
            --incdomT <x>     consider domains >= this score threshold as significant
            --cut_ga          use profile's GA gathering cutoffs to set all thresholding
            --cut_nc          use profile's NC noise cutoffs to set all thresholding
            --cut_tc          use profile's TC trusted cutoffs to set all thresholding
            --max             turn all heuristic filters off (less speed, more power)
            --F1 <x>          MSV threshold: promote hits w/ P <= F1
            --F2 <x>          vit threshold: promote hits w/ P <= F2
            --F3 <x>          fwd threshold: promote hits w/ P <= F3
            --nobias          turn off composition bias filter
            --nonull2         turn off biased composition score corrections
            -Z <x>            set # of comparisons done, for E-value calculation
            --domZ <x>        set # of significant seqs, for domain E-value calculation
            --seed <n>        set RNG seed to <n> (if 0: one-time arbitrary seed)
            --qformat <s>     assert input <seqfile> is in format <s>: no autodetection
            --cpu <n>         number of parallel CPU workers to use for multithreads
            --stall           arrest after start: for debugging MPI under gdb
            --mpi             run as an MPI parallel program
        `,
        values: #{
            "-o": "files", "--tblout": "files", "--domtblout": "files", "--pfamtblout": "files", "--textw": "none",
            "-E": "none", "-T": "none", "--domE": "none", "--domT": "none", "--incE": "none", "--incT": "none",
            "--incdomE": "none", "--incdomT": "none", "--F1": "none", "--F2": "none", "--F3": "none", "-Z": "none",
            "--domZ": "none", "--seed": "none", "--qformat": "none", "--cpu": "none",
            "--tformat": ["fasta", "embl", "genbank", "ddbj", "uniprot", "ncbi", "daemon", "hmmpgmd"],
        },
        args: [k("hmm"), k("sequences")],
    }
}

fn phmmer() {
    #{
        opts: `
            -h                show brief help on version and usage
            -o <f>            direct output to file <f>, not stdout
            -A <f>            save multiple alignment of hits to file <f>
            --tblout <f>      save parseable table of per-sequence hits to file <f>
            --domtblout <f>   save parseable table of per-domain hits to file <f>
            --pfamtblout <f>  save table of hits and domains to file, in Pfam format <f>
            --acc             prefer accessions over names in output
            --noali           don't output alignments, so output is smaller
            --notextw         unlimit ASCII text output line width
            --textw <n>       set max width of ASCII text output lines
            --popen <x>       gap open probability
            --pextend <x>     gap extend probability
            --mx <s>          substitution score matrix choice (of some built-in matrices)
            --mxfile <f>      read substitution score matrix from file <f>
            -E <x>            report sequences <= this E-value threshold in output
            -T <x>            report sequences >= this score threshold in output
            --domE <x>        report domains <= this E-value threshold in output
            --domT <x>        report domains >= this score cutoff in output
            --incE <x>        consider sequences <= this E-value threshold as significant
            --incT <x>        consider sequences >= this score threshold as significant
            --incdomE <x>     consider domains <= this E-value threshold as significant
            --incdomT <x>     consider domains >= this score threshold as significant
            --max             turn all heuristic filters off (less speed, more power)
            --F1 <x>          stage 1 (MSV) threshold: promote hits w/ P <= F1
            --F2 <x>          stage 2 (Vit) threshold: promote hits w/ P <= F2
            --F3 <x>          stage 3 (Fwd) threshold: promote hits w/ P <= F3
            --nobias          turn off composition bias filter
            --EmL <n>         length of sequences for MSV Gumbel mu fit
            --EmN <n>         number of sequences for MSV Gumbel mu fit
            --EvL <n>         length of sequences for Viterbi Gumbel mu fit
            --EvN <n>         number of sequences for Viterbi Gumbel mu fit
            --EfL <n>         length of sequences for Forward exp tail tau fit
            --EfN <n>         number of sequences for Forward exp tail tau fit
            --Eft <x>         tail mass for Forward exponential tail tau fit
            --nonull2         turn off biased composition score corrections
            -Z <x>            set # of comparisons done, for E-value calculation
            --domZ <x>        set # of significant seqs, for domain E-value calculation
            --seed <n>        set RNG seed to <n> (if 0: one-time arbitrary seed)
            --qformat <s>     assert query <seqfile> is in format <s>: no autodetection
            --tformat <s>     assert target <seqdb> is in format <s>>: no autodetection
            --cpu <n>         number of parallel CPU workers to use for multithreads
            --stall           arrest after start: for debugging MPI under gdb
            --mpi             run as an MPI parallel program
        `,
        values: #{
            "-o": "files", "-A": "files", "--tblout": "files", "--domtblout": "files", "--pfamtblout": "files",
            "--textw": "none", "--popen": "none", "--pextend": "none",
            "--mx": ["PAM30", "PAM70", "PAM120", "PAM240", "BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90"],
            "--mxfile": "files", "-E": "none", "-T": "none", "--domE": "none", "--domT": "none", "--incE": "none",
            "--incT": "none", "--incdomE": "none", "--incdomT": "none", "--F1": "none", "--F2": "none",
            "--F3": "none", "--EmL": "none", "--EmN": "none", "--EvL": "none", "--EvN": "none", "--EfL": "none",
            "--EfN": "none", "--Eft": "none", "-Z": "none", "--domZ": "none", "--seed": "none",
            "--qformat": ["fasta", "embl", "genbank", "ddbj", "uniprot", "ncbi", "daemon", "hmmpgmd"],
            "--tformat": ["fasta", "embl", "genbank", "ddbj", "uniprot", "ncbi", "daemon", "hmmpgmd"],
            "--cpu": "none",
        },
        args: [k("sequences"), k("sequences")],
    }
}

fn jackhmmer() {
    #{
        opts: `
            -h                show brief help on version and usage
            -N <n>            set maximum number of iterations to <n>
            -o <f>            direct output to file <f>, not stdout
            -A <f>            save multiple alignment of hits to file <f>
            --tblout <f>      save parseable table of per-sequence hits to file <f>
            --domtblout <f>   save parseable table of per-domain hits to file <f>
            --chkhmm <f>      save HMM checkpoints to files <f>-<iteration>.hmm
            --chkali <f>      save alignment checkpoints to files <f>-<iteration>.sto
            --acc             prefer accessions over names in output
            --noali           don't output alignments, so output is smaller
            --notextw         unlimit ASCII text output line width
            --textw <n>       set max width of ASCII text output lines
            --popen <x>       gap open probability
            --pextend <x>     gap extend probability
            --mx <s>          substitution score matrix choice (of some built-in matrices)
            --mxfile <f>      read substitution score matrix from file <f>
            -E <x>            report sequences <= this E-value threshold in output
            -T <x>            report sequences >= this score threshold in output
            --domE <x>        report domains <= this E-value threshold in output
            --domT <x>        report domains >= this score cutoff in output
            --incE <x>        consider sequences <= this E-value threshold as significant
            --incT <x>        consider sequences >= this score threshold as significant
            --incdomE <x>     consider domains <= this E-value threshold as significant
            --incdomT <x>     consider domains >= this score threshold as significant
            --max             turn all heuristic filters off (less speed, more power)
            --F1 <x>          stage 1 (MSV) threshold: promote hits w/ P <= F1
            --F2 <x>          stage 2 (Vit) threshold: promote hits w/ P <= F2
            --F3 <x>          stage 3 (Fwd) threshold: promote hits w/ P <= F3
            --nobias          turn off composition bias filter
            --fragthresh <x>  if L <= x*alen, tag sequence as a fragment
            --wpb             henikoff position-based weights
            --wgsc            gerstein/Sonnhammer/Chothia tree weights
            --wblosum         henikoff simple filter weights
            --wnone           don't do any relative weighting; set all to 1
            --wid <x>         for --wblosum: set identity cutoff
            --eent            adjust eff seq # to achieve relative entropy target
            --eentexp         adjust eff seq # to reach rel
            --eclust          eff seq # is # of single linkage clusters
            --enone           no effective seq # weighting: just use nseq
            --eset <x>        set eff seq # for all models to <x>
            --ere <x>         for --eent[exp]: set minimum rel entropy/position to <x>
            --esigma <x>      for --eent[exp]: set sigma param to <x>
            --eid <x>         for --eclust: set fractional identity cutoff to <x>
            --pnone           don't use any prior; parameters are frequencies
            --plaplace        use a Laplace +1 prior
            --EmL <n>         length of sequences for MSV Gumbel mu fit
            --EmN <n>         number of sequences for MSV Gumbel mu fit
            --EvL <n>         length of sequences for Viterbi Gumbel mu fit
            --EvN <n>         number of sequences for Viterbi Gumbel mu fit
            --EfL <n>         length of sequences for Forward exp tail tau fit
            --EfN <n>         number of sequences for Forward exp tail tau fit
            --Eft <x>         tail mass for Forward exponential tail tau fit
            --nonull2         turn off biased composition score corrections
            -Z <x>            set # of comparisons done, for E-value calculation
            --domZ <x>        set # of significant seqs, for domain E-value calculation
            --seed <n>        set RNG seed to <n> (if 0: one-time arbitrary seed)
            --qformat <s>     assert query <seqfile> is in format <s>: no autodetection
            --tformat <s>     assert target <seqdb> is in format <s>>: no autodetection
            --cpu <n>         number of parallel CPU workers to use for multithreads
            --stall           arrest after start: for debugging MPI under gdb
            --mpi             run as an MPI parallel program
        `,
        values: #{
            "-N": "none", "-o": "files", "-A": "files", "--tblout": "files", "--domtblout": "files",
            "--chkhmm": "files", "--chkali": "files", "--textw": "none", "--popen": "none", "--pextend": "none",
            "--mx": ["PAM30", "PAM70", "PAM120", "PAM240", "BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90"],
            "--mxfile": "files", "-E": "none", "-T": "none", "--domE": "none", "--domT": "none", "--incE": "none",
            "--incT": "none", "--incdomE": "none", "--incdomT": "none", "--F1": "none", "--F2": "none",
            "--F3": "none", "--fragthresh": "none", "--wid": "none", "--eset": "none", "--ere": "none",
            "--esigma": "none", "--eid": "none", "--EmL": "none", "--EmN": "none", "--EvL": "none",
            "--EvN": "none", "--EfL": "none", "--EfN": "none", "--Eft": "none", "-Z": "none", "--domZ": "none",
            "--seed": "none",
            "--qformat": ["fasta", "embl", "genbank", "ddbj", "uniprot", "ncbi", "daemon", "hmmpgmd"],
            "--tformat": ["fasta", "embl", "genbank", "ddbj", "uniprot", "ncbi", "daemon", "hmmpgmd"],
            "--cpu": "none",
        },
        args: [k("sequences"), k("sequences")],
    }
}

fn nhmmer() {
    #{
        opts: `
            -h                        show brief help on version and usage
            -o <f>                    direct output to file <f>, not stdout
            -A <f>                    save multiple alignment of all hits to file <f>
            --tblout <f>              save parseable table of hits to file <f>
            --dfamtblout <f>          save table of hits to file, in Dfam format <f>
            --aliscoresout <f>        save scores for each position in each alignment to <f>
            --hmmout <f>              if input is alignment(s), write produced hmms to file <f>
            --acc                     prefer accessions over names in output
            --noali                   don't output alignments, so output is smaller
            --notextw                 unlimit ASCII text output line width
            --textw <n>               set max width of ASCII text output lines
            --singlemx                use substitution score matrix w/ single-sequence MSA-format inputs
            --popen <x>               gap open probability
            --pextend <x>             gap extend probability
            --mxfile <f>              read substitution score matrix from file <f>
            -E <x>                    report sequences <= this E-value threshold in output
            -T <x>                    report sequences >= this score threshold in output
            --incE <x>                consider sequences <= this E-value threshold as significant
            --incT <x>                consider sequences >= this score threshold as significant
            --cut_ga                  use profile's GA gathering cutoffs to set all thresholding
            --cut_nc                  use profile's NC noise cutoffs to set all thresholding
            --cut_tc                  use profile's TC trusted cutoffs to set all thresholding
            --max                     turn all heuristic filters off (less speed, more power)
            --F1 <x>                  stage 1 (SSV) threshold: promote hits w/ P <= F1
            --F2 <x>                  stage 2 (Vit) threshold: promote hits w/ P <= F2
            --F3 <x>                  stage 3 (Fwd) threshold: promote hits w/ P <= F3
            --nobias                  turn off composition bias filter
            --dna                     input alignment is DNA sequence data
            --rna                     input alignment is RNA sequence data
            --seed_max_depth <n>      seed length at which bit threshold must be met
            --seed_sc_thresh <x>      default req
            --seed_sc_density <x>     seed must maintain this bit density from one of two ends
            --seed_drop_max_len <n>   maximum run length with score under (max - [fm_drop_lim])
            --seed_drop_lim <x>       in seed, max drop in a run of length [fm_drop_max_len]
            --seed_req_pos <n>        minimum number consecutive positive scores in seed
            --seed_consens_match <n>  <n> consecutive matches to consensus will override score threshold
            --seed_ssv_length <n>     length of window around FM seed to get full SSV diagonal
            --qformat <s>             assert query is in format <s> (can be seq or msa format)
            --qsingle_seqs            force query to be read as individual sequences, even if in an msa format
            --tformat <s>             assert target <seqdb> is in format <s>
            --nonull2                 turn off biased composition score corrections
            -Z <x>                    set database size (Megabases) to <x> for E-value calculations
            --seed <n>                set RNG seed to <n> (if 0: one-time arbitrary seed)
            --w_beta <x>              tail mass at which window length is determined
            --w_length <n>            window length - essentially max expected hit length
            --block_length <n>        length of blocks read from target database (threaded)
            --watson                  only search the top strand
            --crick                   only search the bottom strand
            --cpu <n>                 number of parallel CPU workers to use for multithreads
        `,
        values: #{
            "-o": "files", "-A": "files", "--tblout": "files", "--dfamtblout": "files", "--aliscoresout": "files",
            "--hmmout": "files", "--textw": "none", "--popen": "none", "--pextend": "none", "--mxfile": "files",
            "-E": "none", "-T": "none", "--incE": "none", "--incT": "none", "--F1": "none", "--F2": "none",
            "--F3": "none", "--seed_max_depth": "none", "--seed_sc_thresh": "none", "--seed_sc_density": "none",
            "--seed_drop_max_len": "none", "--seed_drop_lim": "none", "--seed_req_pos": "none",
            "--seed_consens_match": "none", "--seed_ssv_length": "none",
            "--qformat": ["fasta", "embl", "genbank", "ddbj", "uniprot", "ncbi", "daemon", "hmmpgmd"],
            "--tformat": ["fasta", "embl", "genbank", "ddbj", "uniprot", "ncbi", "daemon", "hmmpgmd"],
            "-Z": "none", "--seed": "none", "--w_beta": "none", "--w_length": "none", "--block_length": "none",
            "--cpu": "none",
        },
        args: [k("hmm"), k("sequences")],
    }
}

fn nhmmscan() {
    #{
        opts: `
            -h                show brief help on version and usage
            -o <f>            direct output to file <f>, not stdout
            --tblout <f>      save parseable table of per-sequence hits to file <f>
            --dfamtblout <f>  save table of hits to file, in Dfam format <f>
            --acc             prefer accessions over names in output
            --noali           don't output alignments, so output is smaller
            --notextw         unlimit ASCII text output line width
            --textw <n>       set max width of ASCII text output lines
            -E <x>            report models <= this E-value threshold in output
            -T <x>            report models >= this score threshold in output
            --incE <x>        consider models <= this E-value threshold as significant
            --incT <x>        consider models >= this score threshold as significant
            --cut_ga          use profile's GA gathering cutoffs to set all thresholding
            --cut_nc          use profile's NC noise cutoffs to set all thresholding
            --cut_tc          use profile's TC trusted cutoffs to set all thresholding
            --max             turn all heuristic filters off (less speed, more power)
            --F1 <x>          MSV threshold: promote hits w/ P <= F1
            --F2 <x>          vit threshold: promote hits w/ P <= F2
            --F3 <x>          fwd threshold: promote hits w/ P <= F3
            --nobias          turn off composition bias filter
            --qformat <s>     assert input <seqfile> is in format <s>
            --nonull2         turn off biased composition score corrections
            -Z <x>            set # of comparisons done, for E-value calculation
            --seed <n>        set RNG seed to <n> (if 0: one-time arbitrary seed)
            --w_beta <x>      tail mass at which window length is determined
            --w_length <n>    window length - essentially max expected hit length
            --watson          only search the top strand
            --crick           only search the bottom strand
            --cpu <n>         number of parallel CPU workers to use for multithreads
        `,
        values: #{
            "-o": "files", "--tblout": "files", "--dfamtblout": "files", "--textw": "none", "-E": "none",
            "-T": "none", "--incE": "none", "--incT": "none", "--F1": "none", "--F2": "none", "--F3": "none",
            "--qformat": ["fasta", "embl", "genbank", "ddbj", "uniprot", "ncbi", "daemon", "hmmpgmd"],
            "-Z": "none", "--seed": "none", "--w_beta": "none", "--w_length": "none", "--cpu": "none",
            "--tformat": ["fasta", "embl", "genbank", "ddbj", "uniprot", "ncbi", "daemon", "hmmpgmd"],
        },
        args: [k("hmm"), k("sequences")],
    }
}

fn hmmbuild() {
    #{
        opts: `
            -h                  show brief help on version and usage
            -n <s>              name the HMM <s>
            -o <f>              direct summary output to file <f>, not stdout
            -O <f>              resave annotated, possibly modified MSA to file <f>
            --amino             input alignment is protein sequence data
            --dna               input alignment is DNA sequence data
            --rna               input alignment is RNA sequence data
            --fast              assign cols w/ >= symfrac residues as consensus
            --hand              manual construction (requires reference annotation)
            --symfrac <x>       sets sym fraction controlling --fast construction
            --fragthresh <x>    if L <= x*alen, tag sequence as a fragment
            --wpb               henikoff position-based weights
            --wgsc              gerstein/Sonnhammer/Chothia tree weights
            --wblosum           henikoff simple filter weights
            --wnone             don't do any relative weighting; set all to 1
            --wgiven            use weights as given in MSA file
            --wid <x>           for --wblosum: set identity cutoff
            --eent              adjust eff seq # to achieve relative entropy target
            --eclust            eff seq # is # of single linkage clusters
            --enone             no effective seq # weighting: just use nseq
            --eset <x>          set eff seq # for all models to <x>
            --ere <x>           for --eent: set minimum rel entropy/position to <x>
            --esigma <x>        for --eent: set sigma param to <x>
            --eid <x>           for --eclust: set fractional identity cutoff to <x>
            --pnone             don't use any prior; parameters are frequencies
            --plaplace          use a Laplace +1 prior
            --singlemx          use substitution score matrix for single-sequence inputs
            --mx <s>            substitution score matrix (built-in matrices, with --singlemx)
            --mxfile <f>        read substitution score matrix from file <f> (with --singlemx)
            --popen <x>         force gap open prob
            --pextend <x>       force gap extend prob
            --EmL <n>           length of sequences for MSV Gumbel mu fit
            --EmN <n>           number of sequences for MSV Gumbel mu fit
            --EvL <n>           length of sequences for Viterbi Gumbel mu fit
            --EvN <n>           number of sequences for Viterbi Gumbel mu fit
            --EfL <n>           length of sequences for Forward exp tail tau fit
            --EfN <n>           number of sequences for Forward exp tail tau fit
            --Eft <x>           tail mass for Forward exponential tail tau fit
            --cpu <n>           number of parallel CPU workers for multithreads
            --mpi               run as an MPI parallel program
            --stall             arrest after start: for attaching debugger to process
            --informat <s>      assert input alifile is in format <s> (no autodetect)
            --seed <n>          set RNG seed to <n> (if 0: one-time arbitrary seed)
            --w_beta <x>        tail mass at which window length is determined
            --w_length <n>      window length
            --maxinsertlen <n>  pretend all inserts are length <= <n>
        `,
        values: #{
            "-n": "none", "-o": "files", "-O": "files", "--symfrac": "none", "--fragthresh": "none",
            "--wid": "none", "--eset": "none", "--ere": "none", "--esigma": "none", "--eid": "none",
            "--mx": ["PAM30", "PAM70", "PAM120", "PAM240", "BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90"],
            "--mxfile": "files", "--popen": "none", "--pextend": "none", "--EmL": "none", "--EmN": "none",
            "--EvL": "none", "--EvN": "none", "--EfL": "none", "--EfN": "none", "--Eft": "none", "--cpu": "none",
            "--informat": ["stockholm", "pfam", "a2m", "psiblast", "selex", "afa", "clustal", "clustallike", "phylip", "phylips"],
            "--seed": "none", "--w_beta": "none", "--w_length": "none", "--maxinsertlen": "none",
        },
        args: ["files", k("msa")],
    }
}

fn hmmalign() {
    #{
        opts: `
            -h               show brief help on version and usage
            -o <f>           output alignment to file <f>, not stdout
            --mapali <f>     include alignment in file <f> (same ali that HMM came from)
            --trim           trim terminal tails of nonaligned residues from alignment
            --amino          assert <seqfile>, <hmmfile> both protein: no autodetection
            --dna            assert <seqfile>, <hmmfile> both DNA: no autodetection
            --rna            assert <seqfile>, <hmmfile> both RNA: no autodetection
            --informat <s>   assert <seqfile> is in format <s>: no autodetection
            --outformat <s>  output alignment in format <s>
        `,
        values: #{
            "-o": "files", "--mapali": "files",
            "--informat": ["stockholm", "pfam", "a2m", "psiblast", "selex", "afa", "clustal", "clustallike", "phylip", "phylips"],
            "--outformat": ["stockholm", "pfam", "a2m", "psiblast", "selex", "afa", "clustal", "clustallike", "phylip", "phylips"],
        },
        args: [k("hmm"), k("sequences")],
    }
}

fn hmmpress() {
    #{
        opts: `
            -h  show brief help on version and usage
            -f  force: overwrite any previous pressed files
        `,
        args: [k("hmm")],
    }
}

fn hmmfetch() {
    #{
        opts: `
            -h       show brief help on version and usage
            -f       second cmdline arg is a file of names to retrieve
            -o <f>   output HMM to file <f> instead of stdout
            -O       output HMM to file named <key>
            --index  index the <hmmfile>, creating <hmmfile>.ssi
        `,
        values: #{
            "-o": "files",
        },
        args: [k("hmm"), "none"],
    }
}

fn hmmemit() {
    #{
        opts: `
            -h           show brief help on version and usage
            -o <f>       send sequence output to file <f>, not stdout
            -N <n>       number of seqs to sample
            -a           emit alignment
            -c           emit simple majority-rule consensus sequence
            -C           emit fancier consensus sequence (req's --minl, --minu)
            -p           sample sequences from profile, not core model
            -L <n>       set expected length from profile to <n>
            --local      configure profile in multihit local mode
            --unilocal   configure profile in unilocal mode
            --glocal     configure profile in multihit glocal mode
            --uniglocal  configure profile in unihit glocal mode
            --minl <x>   show consensus as 'any' (X/N) unless >= this fraction
            --minu <x>   show consensus as upper case if >= this fraction
            --seed <n>   set RNG seed to <n>
        `,
        values: #{
            "-o": "files", "-N": "none", "-L": "none", "--minl": "none", "--minu": "none", "--seed": "none",
        },
        args: [k("hmm")],
    }
}

fn hmmconvert() {
    #{
        opts: `
            -h            show brief help on version and usage
            -a            ascii: output models in HMMER3 ASCII format
            -b            binary: output models in HMMER3 binary format
            -2            HMMER2: output backward compatible HMMER2 ASCII format (ls mode)
            --outfmt <s>  choose output legacy 3.x file formats by name, such as '3/a'
        `,
        values: #{
            "--outfmt": "none",
        },
        args: [k("hmm")],
    }
}

fn hmmstat() {
    #{
        opts: `
            -h  show brief help on version and usage
        `,
        args: [k("hmm")],
    }
}

fn spec(cmd) {
    switch cmd {
        "hmmsearch" => hmmsearch(),
        "hmmscan" => hmmscan(),
        "phmmer" => phmmer(),
        "jackhmmer" => jackhmmer(),
        "nhmmer" => nhmmer(),
        "nhmmscan" => nhmmscan(),
        "hmmbuild" => hmmbuild(),
        "hmmalign" => hmmalign(),
        "hmmpress" => hmmpress(),
        "hmmfetch" => hmmfetch(),
        "hmmemit" => hmmemit(),
        "hmmconvert" => hmmconvert(),
        "hmmstat" => hmmstat(),
        _ => #{},
    }
}
