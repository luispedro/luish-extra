# Completion TODO

Tools to support, from `docs/completion.md`.

A ticked tool has a spec and a test, and the version after it is the one its options were checked against, from
the tool's own `--help`. Versions are Bioconda packages, run in a temporary pixi environment, so anyone can
repeat the check:

```sh
scripts/optcheck.sh samtools=1.22.1 samtools sort view     # PACKAGE=VERSION PROG [SUB]...
pixi exec -c conda-forge -c bioconda -s bcftools=1.24 -- bcftools --version
```

`scripts/optdiff.py` lists the options the help mentions that the spec lacks (`missing`) and the reverse
(`extra`); what it prints for a ticked tool is only noise from the help text (option names in prose, `-Ou`
in examples) or options the help leaves out on purpose. `scripts/help2opts.py` drafts an option table from a
help text. The first ticks (samtools, bedtools, tabix, bgzip, htsfile, ngless, SemiBin2, macrel, argnorm) were
made before versions were recorded: they were checked again on 2026-09-30, which found samtools and bedtools
subcommands without options, fixed at the same time.


## Programs built with Click

Python programs built with Click complete themselves, and std's `completion` plugin has a bridge for them
(`bridges::click`), so `extension.rhai` registers them with no spec. A tick with `(Click)` means the program
answers `_PROG_COMPLETE=fish_complete` and takes under a second to do it (`scripts/clickcheck.sh PACKAGE PROG
[WORD]...` measures it, in a temporary pixi environment). Tab runs the program each time, so those that import
too much at startup (cooltools, bigscape, iphop, genomad, pyprophet, easypqp, ms2rescore, velocyto: 1.4 to 5 s)
are not registered, and stay unticked with their time. A user who accepts the delay can add one with `complete-click PROG`. Typer programs (binette, taxpasta, wisecondorx) don't answer the same
protocol. `nf-core` and `planemo` (Click, 0.1 and 1.4 s) belong to the `science` plugin (`nf-core` is registered there, see
below), and `proksee` (Click, 0.3 s) to `gui`.

Go programs built with Cobra answer `PROG __complete WORDS...`, and std's Cobra bridge (`bridges::cobra`) asks
them in the same way. A tick with `(Cobra)` means the program answers with its subcommands and flags, in about
10 ms (seqkit, csvtk, taxonkit).

## `bio`: bioinformatics


### Alignment files, variants and intervals

- [x] `samtools`: samtools 1.22.1 (htslib 1.22.1)
- [x] `bcftools`: bcftools 1.24 (htslib 1.24)
- [x] `bedtools`: bedtools 2.31.1
- [x] `tabix`: htslib 1.22.1
- [x] `bgzip`: htslib 1.22.1
- [x] `htsfile`: htslib 1.22.1
- [x] `vcftools`: vcftools 0.1.17 (options from its man page)
- [x] `bamtools`: bamtools 2.5.3
- [x] `sambamba`: sambamba 1.0.1
- [x] `samblaster`: samblaster 0.1.26
- [x] `mosdepth`: mosdepth 0.3.14
- [ ] `picard`
- [ ] `gatk`
- [ ] `bamutil`
- [ ] `bam-readcount`
- [ ] `bamhash`
- [x] `cramino`: cramino 2.0.0
- [ ] `deeptools`
- [ ] `bamCoverage`
- [ ] `bamCompare`
- [ ] `computeMatrix`
- [ ] `plotHeatmap`
- [ ] `plotProfile`
- [ ] `bedops`
- [ ] `vcflib`
- [ ] `vt`
- [ ] `snpEff`
- [ ] `SnpSift`
- [ ] `vep`
- [ ] `plink`
- [ ] `plink2`
- [ ] `admixture`
- [ ] `whatshap`
- [ ] `freebayes`
- [ ] `lofreq`
- [ ] `varscan`
- [ ] `octopus`
- [ ] `bcbio-variation`
- [ ] `delly`
- [ ] `manta`
- [ ] `lumpy`
- [ ] `smoove`
- [ ] `sniffles`
- [ ] `cuteSV`
- [ ] `svim`
- [ ] `pindel`
- [ ] `survivor`
- [ ] `truvari`
- [ ] `hap.py`
- [ ] `rtg`
- [ ] `fgbio`
- [ ] `bwameth.py`
- [ ] `bismark`
- [ ] `MethylDackel`
- [ ] `wiggletools`
- [ ] `mummer`
- [ ] `nucmer`
- [ ] `alfred`
- [ ] `gridss`
- [ ] `varlociraptor`
- [ ] `vardict`
- [ ] `strelka`
- [ ] `somaticseq`
- [ ] `deepvariant`
- [ ] `clair3`
- [ ] `svtyper`
- [ ] `svtools`
- [ ] `duphold`
- [ ] `samplot`
- [ ] `annotsv`
- [ ] `paragraph`
- [ ] `graphtyper`
- [ ] `vg`
- [ ] `expansionhunter`
- [ ] `trgt`
- [ ] `hiphase`
- [ ] `sawfish`
- [ ] `gangstr`
- [ ] `slivar`
- [ ] `vcfanno`
- [x] `peddy`: peddy 0.4.8 (Click)
- [ ] `somalier`
- [ ] `verifybamid2`
- [ ] `vembrane`
- [ ] `vcf2maf`
- [ ] `gemini`
- [x] `genmod`: genmod 3.12.0 (Click)
- [ ] `ascat`
- [ ] `control-freec`
- [ ] `sequenza-utils`
- [ ] `cnvpytor`
- [ ] `wisecondorx`: Typer: no `fish_complete`, no completion
- [ ] `snp-sites`
- [ ] `snp-dists`
- [ ] `gofasta`
- [ ] `ivar`
- [ ] `nextalign`
- [ ] `vadr`
- [ ] `tn93`
- [ ] `pyfaidx`
- [ ] `bx-python`
- [ ] `gffutils-cli`
- [ ] `pyfastx`
- [ ] `crossmap`
- [ ] `bedGraphToBigWig`
- [ ] `bedToBigBed`
- [ ] `bigWigToWig`
- [ ] `bigWigToBedGraph`
- [ ] `bigWigInfo`
- [ ] `bigBedToBed`
- [ ] `bigBedInfo`
- [ ] `wigToBigWig`
- [ ] `faToTwoBit`
- [ ] `twoBitToFa`
- [ ] `twoBitInfo`
- [ ] `faSize`
- [ ] `faFrag`
- [ ] `faSomeRecords`
- [ ] `liftOver`
- [ ] `gtfToGenePred`
- [ ] `genePredToBed`
- [ ] `genePredToGtf`
- [ ] `gff3ToGenePred`
- [ ] `blat`
- [ ] `pslCDnaFilter`
- [ ] `pslSort`
- [ ] `bedSort`
- [ ] `bedClip`
- [ ] `bedIntersect`
- [ ] `fetchChromSizes`
- [ ] `chainNet`
- [ ] `axtChain`
- [ ] `ucsc-*`

### Mapping and quantification

- [x] `bwa`: bwa 0.7.19
- [x] `bwa-mem2`: bwa-mem2 2.2.1
- [ ] `bowtie`
- [x] `bowtie2`: bowtie2 2.5.5
- [x] `bowtie2-build`: bowtie2 2.5.5
- [x] `minimap2`: minimap2 2.30
- [x] `hisat2`: hisat2 2.2.3
- [x] `hisat2-build`: hisat2 2.2.3
- [x] `STAR`: star 2.7.11b
- [ ] `gmap`
- [ ] `lastal`
- [ ] `lastdb`
- [ ] `last-train`
- [x] `kallisto`: kallisto 0.52.0
- [ ] `bustools`
- [ ] `salmon`
- [ ] `stringtie`
- [ ] `htseq-count`
- [x] `featureCounts`: subread 2.1.1
- [ ] `rsem-calculate-expression`
- [ ] `cufflinks`
- [ ] `regtools`
- [ ] `tophat`
- [ ] `chromap`
- [ ] `strobealign`
- [ ] `ngmlr`
- [ ] `segemehl`
- [ ] `graphmap`
- [ ] `snap-aligner`
- [ ] `novoalign`
- [ ] `yara_mapper`
- [ ] `mash`
- [ ] `sourmash`
- [ ] `fastANI`
- [ ] `skani`
- [ ] `sylph`
- [ ] `STAR-Fusion`
- [ ] `arriba`
- [ ] `fusioncatcher`
- [ ] `qualimap`
- [ ] `umi_tools`
- [ ] `preseq`
- [ ] `rmats`
- [ ] `suppa`
- [ ] `portcullis`
- [ ] `mikado`
- [ ] `rnaquast`
- [ ] `trinotate`
- [ ] `corset`
- [ ] `scallop`
- [ ] `psiclass`
- [ ] `flair`
- [ ] `isoquant`
- [ ] `oarfish`
- [ ] `alevin-fry`
- [ ] `simpleaf`
- [ ] `kb`
- [ ] `velocyto`: Click, 5 s: `complete-click velocyto`
- [ ] `kma`
- [ ] `rseqc`

### Sequence search

- [x] `blastn`: blast 2.17.0
- [x] `blastp`: blast 2.17.0
- [x] `blastx`: blast 2.17.0
- [x] `tblastn`: blast 2.17.0
- [x] `tblastx`: blast 2.17.0
- [x] `makeblastdb`: blast 2.17.0
- [x] `blastdbcmd`: blast 2.17.0
- [x] `rpsblast`: blast 2.17.0
- [x] `diamond`: diamond 2.2.8
- [x] `mmseqs`: mmseqs2 18.8cc5c (options read from the installed `mmseqs`)
- [ ] `foldseek`
- [ ] `hhblits`
- [ ] `hhsearch`
- [ ] `vsearch`
- [ ] `swarm`
- [ ] `cd-hit`
- [ ] `sortmerna`
- [ ] `exonerate`
- [ ] `lastz`
- [ ] `fasta36`
- [ ] `mcl`
- [ ] `interproscan.sh`
- [ ] `kofamscan`
- [ ] `usearch`
- [x] `psiblast`: blast 2.17.0
- [x] `deltablast`: blast 2.17.0
- [x] `dustmasker`: blast 2.17.0
- [x] `segmasker`: blast 2.17.0
- [x] `windowmasker`: blast 2.17.0
- [x] `makeprofiledb`: blast 2.17.0
- [x] `blastdb_aliastool`: blast 2.17.0
- [x] `update_blastdb.pl`: blast 2.17.0
- [ ] `cas-offinder`
- [x] `hmmsearch`: hmmer 3.4
- [x] `hmmscan`: hmmer 3.4
- [x] `phmmer`: hmmer 3.4
- [x] `jackhmmer`: hmmer 3.4
- [x] `nhmmer`: hmmer 3.4
- [x] `nhmmscan`: hmmer 3.4
- [x] `hmmbuild`: hmmer 3.4
- [x] `hmmalign`: hmmer 3.4
- [x] `hmmpress`: hmmer 3.4
- [x] `hmmfetch`: hmmer 3.4
- [x] `hmmemit`: hmmer 3.4
- [x] `hmmconvert`: hmmer 3.4
- [x] `hmmstat`: hmmer 3.4

### Read QC, trimming and sequence utilities

- [x] `fastp`: fastp 1.3.7
- [x] `fastqc`: fastqc 0.12.1
- [x] `falco`: falco 2.0.2
- [x] `multiqc`: multiqc 1.35 (Click)
- [x] `cutadapt`: cutadapt 5.2
- [x] `trimmomatic`: trimmomatic 0.41 (its usage, and the steps of its `TrimmerFactory`)
- [x] `trim_galore`: trim-galore 2.3.0 (the Rust rewrite; 0.6.x's options are nearly the same)
- [ ] `AdapterRemoval`
- [ ] `atropos`
- [ ] `flexbar`
- [ ] `fastx_*`
- [ ] `bbduk.sh`
- [x] `seqkit`: seqkit 2.14.0 (Cobra)
- [x] `seqtk`: seqtk 1.5
- [x] `csvtk`: csvtk 0.38.0 (Cobra)
- [ ] `seqfu`
- [ ] `seqmagick`
- [ ] `bioawk`
- [x] `filtlong`: filtlong 0.3.1
- [x] `chopper`: chopper 0.14.1
- [x] `nanoq`: nanoq 0.10.0
- [x] `rasusa`: rasusa 5.1.0
- [x] `NanoPlot`: nanoplot 1.48.0
- [x] `NanoFilt`: nanofilt 2.8.0
- [x] `NanoStat`: nanostat 1.6.0
- [x] `porechop`: porechop 0.2.4
- [x] `fastq_screen`: fastq-screen 0.16.0
- [x] `fastq-dl`: fastq-dl 4.0.1 (Click)
- [ ] `kmc`
- [ ] `jellyfish`
- [ ] `meryl`
- [ ] `khmer`
- [ ] `pear`
- [ ] `flash`
- [ ] `sickle`
- [ ] `lighter`
- [ ] `pigz`
- [ ] `pixz`
- [x] `taxonkit`: taxonkit 0.20.0 (Cobra)
- [ ] `sga`
- [ ] `kat`
- [ ] `genomescope2`
- [ ] `smudgeplot`
- [ ] `nanocomp`
- [ ] `pycoqc`
- [ ] `toulligqc`
- [ ] `pomoxis`

### Assembly, annotation and polishing

- [x] `spades.py`: spades 4.3.0
- [x] `metaspades.py`: spades 4.3.0
- [x] `megahit`: megahit 1.2.9
- [ ] `abyss-pe`
- [ ] `velveth`
- [ ] `velvetg`
- [ ] `unicycler`
- [ ] `shovill`
- [ ] `skesa`
- [x] `flye`: flye 2.9.6
- [ ] `canu`
- [ ] `hifiasm`
- [ ] `miniasm`
- [ ] `wtdbg2`
- [ ] `raven`
- [ ] `verkko`
- [ ] `racon`
- [ ] `medaka`
- [ ] `pilon`
- [ ] `polypolish`
- [x] `quast`: quast 5.3.0 (also `quast.py`, `metaquast` and `metaquast.py`)
- [x] `busco`: busco 6.1.0
- [ ] `merqury`
- [x] `prodigal`: prodigal 2.6.3
- [x] `prokka`: prokka 1.15.6
- [x] `bakta`: bakta 1.12.1
- [ ] `pharokka`
- [x] `barrnap`: barrnap 1.10.6 (which says 1.10.5)
- [ ] `tRNAscan-SE`
- [ ] `aragorn`
- [ ] `augustus`
- [ ] `braker.pl`
- [ ] `TransDecoder.LongOrfs`
- [ ] `gffread`
- [ ] `gffcompare`
- [ ] `agat_*`
- [ ] `RepeatMasker`
- [ ] `RepeatModeler`
- [ ] `trf`
- [ ] `maker`
- [ ] `Trinity`
- [ ] `funannotate`
- [ ] `liftoff`
- [ ] `ragtag.py`
- [ ] `masurca`
- [ ] `soapdenovo2`
- [ ] `minia`
- [ ] `idba`
- [ ] `velvet`
- [ ] `gfastats`
- [ ] `compleasm`
- [ ] `edta`
- [ ] `earlgrey`
- [ ] `ltr_retriever`
- [ ] `tesorter`
- [ ] `evidencemodeler`
- [ ] `pasa`
- [ ] `gemoma`
- [ ] `miniprot`
- [ ] `spaln`
- [ ] `glimmerhmm`
- [ ] `snap`
- [ ] `codingquarry`
- [ ] `shasta`
- [ ] `nextdenovo`
- [ ] `nextpolish`
- [ ] `purge_dups`
- [ ] `yahs`
- [ ] `trycycler`
- [ ] `dragonflye`
- [x] `plassembler`: plassembler 1.8.5 (Click)
- [ ] `hybracter`: Click, but prints its banner: no completion
- [ ] `metamdbg`
- [ ] `jcvi`

### Long reads

- [ ] `f5c`
- [ ] `slow5tools`
- [ ] `pod5`
- [ ] `nanopolish`
- [ ] `megalodon`
- [ ] `modkit`
- [ ] `pbmm2`
- [ ] `ccs`
- [ ] `lima`
- [ ] `isoseq3`
- [ ] `pbsv`
- [ ] `longshot`
- [ ] `winnowmap`
- [ ] `savana`
- [ ] `dorado`
- [ ] `guppy_basecaller`
- [ ] `guppy_barcoder`
- [ ] `smrtlink`

### Comparative genomics, pangenomes and population genetics

- [ ] `orthofinder`
- [ ] `proteinortho`
- [ ] `sonicparanoid`
- [ ] `pantools`
- [ ] `anchorwave`
- [ ] `wgd`
- [ ] `cactus`
- [ ] `minigraph`
- [ ] `wfmash`
- [ ] `pggb`
- [ ] `odgi`
- [ ] `seqwish`
- [ ] `mashmap`
- [ ] `syri`
- [ ] `plotsr`
- [ ] `stacks`
- [ ] `ipyrad`
- [ ] `ddocent`
- [ ] `angsd`
- [ ] `admixtools`
- [ ] `smartpca`
- [ ] `treemix`
- [ ] `gcta`
- [ ] `regenie`
- [ ] `shapeit4`
- [ ] `beagle`
- [ ] `king`
- [ ] `selscan`
- [ ] `bolt`
- [ ] `impute2`
- [ ] `glimpse`
- [ ] `rfmix`

### Hi-C and epigenomics

- [ ] `hicexplorer`
- [x] `cooler`: cooler 0.10.4 (Click)
- [ ] `cooltools`: Click, 1.6 s: `complete-click cooltools`
- [x] `pairtools`: pairtools 1.1.3 (Click)
- [ ] `pairix`
- [ ] `chromosight`
- [ ] `hictk`
- [ ] `epic2`
- [ ] `genrich`
- [ ] `chromhmm`
- [ ] `idr`
- [ ] `phantompeakqualtools`
- [ ] `ataqv`
- [ ] `dnmtools`
- [ ] `biscuit`
- [ ] `methylpy`
- [ ] `moabs`
- [ ] `bsmap`
- [ ] `methylartist`

### Alignment and phylogenetics

- [ ] `mafft`
- [ ] `muscle`
- [ ] `clustalw`
- [ ] `clustalo`
- [ ] `t_coffee`
- [ ] `kalign`
- [ ] `probcons`
- [ ] `trimal`
- [ ] `clipkit`
- [ ] `FastTree`
- [ ] `iqtree`
- [ ] `iqtree2`
- [ ] `raxml-ng`
- [ ] `raxmlHPC`
- [ ] `phyml`
- [ ] `mrbayes`
- [ ] `beast`
- [ ] `hyphy`
- [ ] `paml`
- [ ] `gappa`
- [ ] `epa-ng`
- [ ] `pplacer`
- [ ] `treetime`
- [ ] `gotree`
- [ ] `goalign`
- [ ] `ete3`
- [ ] `quicktree`
- [ ] `rapidnj`
- [ ] `sepp`
- [ ] `phylip`
- [ ] `prank`
- [ ] `pasta`
- [ ] `poa`
- [ ] `famsa`
- [ ] `pal2nal`
- [ ] `gblocks`
- [ ] `macse`
- [ ] `generax`
- [ ] `modeltest-ng`
- [ ] `veryfasttree`
- [ ] `aster`
- [ ] `figtree`
- [ ] `tracer`
- [ ] `beast2`
- [ ] `revbayes`
- [ ] `bali-phy`
- [ ] `fastme`
- [ ] `newick_utils`
- [ ] `phykit`
- [ ] `sumtrees.py`
- [ ] `emboss`

### Metagenomics and microbial genomics

- [x] `kraken2`: kraken2 2.17.2
- [x] `kraken2-build`: kraken2 2.17.2
- [x] `kraken2-inspect`: kraken2 2.17.2
- [x] `k2`: kraken2 2.17.2
- [x] `bracken`: bracken 3.1
- [x] `bracken-build`: bracken 3.1
- [x] `combine_bracken_outputs.py`: bracken 3.1
- [x] `krakenuniq`: krakenuniq 1.0.4
- [x] `krakenuniq-build`: krakenuniq 1.0.4
- [x] `krakenuniq-report`: krakenuniq 1.0.4
- [x] `krakenuniq-download`: krakenuniq 1.0.4
- [x] `centrifuge`: centrifuge 1.0.4.2
- [x] `centrifuge-build`: centrifuge 1.0.4.2
- [x] `centrifuge-inspect`: centrifuge 1.0.4.2
- [x] `centrifuge-kreport`: centrifuge 1.0.4.2
- [x] `kaiju`: kaiju 1.10.3
- [x] `kaiju-multi`: kaiju 1.10.3
- [x] `kaiju2table`: kaiju 1.10.3
- [x] `kaiju2krona`: kaiju 1.10.3
- [x] `kaiju-addTaxonNames`: kaiju 1.10.3
- [x] `kaiju-mergeOutputs`: kaiju 1.10.3
- [x] `kaiju-makedb`: kaiju 1.10.3
- [x] `kaiju-mkbwt`: kaiju 1.10.3
- [x] `kaiju-mkfmi`: kaiju 1.10.3
- [x] `metaphlan`: metaphlan 4.2.6
- [x] `merge_metaphlan_tables.py`: metaphlan 4.2.6
- [x] `strainphlan`: metaphlan 4.2.6
- [x] `sample2markers.py`: metaphlan 4.2.6
- [x] `extract_markers.py`: metaphlan 4.2.6
- [x] `humann`: humann 3.9
- [x] `humann_databases`: humann 3.9
- [x] `humann_config`: humann 3.9
- [x] `humann_join_tables`: humann 3.9
- [x] `humann_renorm_table`: humann 3.9
- [x] `humann_regroup_table`: humann 3.9
- [x] `humann_split_stratified_table`: humann 3.9
- [x] `humann_rename_table`: humann 3.9
- [x] `humann_split_table`: humann 3.9
- [x] `humann_reduce_table`: humann 3.9
- [x] `humann_unpack_pathways`: humann 3.9
- [x] `humann_barplot`: humann 3.9
- [x] `motus`: motus 4.1.0
- [x] `checkm`: checkm-genome 1.2.5
- [x] `checkm2`: checkm2 1.1.0
- [x] `checkv`: checkv 1.1.1 (Click)
- [x] `gunc`: gunc 1.1.1
- [ ] `singlem`
- [x] `gtdbtk`: gtdbtk 2.7.2
- [x] `metabat2`: metabat2 2.18_23_gc869c52
- [x] `jgi_summarize_bam_contig_depths`: metabat2 2.18_23_gc869c52
- [x] `concoct`: concoct 1.1.0
- [x] `concoct_coverage_table.py`: concoct 1.1.0
- [x] `cut_up_fasta.py`: concoct 1.1.0
- [x] `merge_cutup_clustering.py`: concoct 1.1.0
- [x] `extract_fasta_bins.py`: concoct 1.1.0
- [x] `run_MaxBin.pl`: maxbin2 2.2.7
- [x] `DAS_Tool`: das_tool 1.1.7
- [x] `Fasta_to_Contig2Bin.sh`: das_tool 1.1.7
- [x] `dRep`: drep 3.7.1
- [x] `coverm`: coverm 0.8.0
- [x] `vamb`: vamb 5.0.4
- [ ] `genomad`: Click, 1.4 s: `complete-click genomad`
- [ ] `emapper.py`
- [ ] `mothur`
- [ ] `qiime`
- [ ] `picrust2`
- [ ] `krona`
- [ ] `abricate`
- [ ] `amrfinder`
- [x] `rgi`: rgi 6.0.8
- [ ] `mlst`
- [ ] `snippy`
- [ ] `roary`
- [ ] `panaroo`
- [ ] `ppanggolin`
- [ ] `gubbins`
- [x] `prokka`: prokka 1.15.6
- [ ] `srst2`
- [ ] `sistr`
- [ ] `ectyper`
- [ ] `seqsero2`
- [ ] `kleborate`
- [ ] `ariba`
- [ ] `staramr`
- [ ] `mykrobe`
- [ ] `tb-profiler`
- [ ] `bactopia`: no completion by the program
- [ ] `anvi-*`
- [ ] `phispy`
- [ ] `antismash`
- [ ] `metawrap`
- [ ] `phyloflash`
- [ ] `graftm`
- [ ] `dram`
- [ ] `vibrant`
- [x] `virsorter`: virsorter 2.2.4 (Click)
- [ ] `vcontact2`
- [ ] `iphop`: Click, 1.5 s: `complete-click iphop`
- [ ] `phabox`
- [ ] `instrain`
- [ ] `binsanity`
- [ ] `comebin`
- [x] `metacoag`: metacoag 1.3.0 (Click)
- [ ] `binette`: Typer: no `fish_complete`, no completion
- [ ] `kmcp`
- [ ] `ganon`
- [ ] `metacache`
- [ ] `krakentools`
- [ ] `kraken-biom`
- [ ] `taxpasta`: Typer: no `fish_complete`, no completion
- [ ] `metaeuk`
- [ ] `insilicoseq`
- [ ] `unifrac`
- [ ] `deblur`: Click, but no environment solves (conda)
- [ ] `gneiss`
- [ ] `emperor`
- [ ] `lefse`
- [ ] `maaslin2`
- [ ] `thapbi-pict`
- [x] `harpy`: harpy 4.2 (Click)
- [ ] `resfinder`
- [ ] `plasmidfinder`
- [ ] `mob_suite`
- [ ] `hamronization`
- [x] `defense-finder`: defense-finder 3.0.0 (Click)
- [ ] `macsyfinder`
- [ ] `integron_finder`
- [ ] `islandpath`
- [ ] `bigscape`: Click, 1.6 s: `complete-click bigscape`
- [ ] `deepbgc`
- [ ] `gecco`
- [ ] `kaptive`
- [ ] `pyani`
- [ ] `parsnp`
- [ ] `mashtree`
- [ ] `poppunk`
- [ ] `pyseer`
- [ ] `scoary`
- [ ] `pirate`
- [ ] `chewbbaca`
- [ ] `ska2`
- [ ] `mentalist`
- [ ] `ntm-profiler`
- [ ] `nullarbor`
- [x] `dnaapler`: dnaapler 1.4.0 (Click)
- [ ] `pyrodigal`
- [ ] `phanotate`
- [ ] `minced`
- [ ] `platon`
- [ ] `plasmidid`

### Data access

- [ ] `esearch`
- [ ] `efetch`
- [ ] `elink`
- [ ] `esummary`
- [ ] `xtract`
- [ ] `entrez-direct`
- [ ] `prefetch`
- [ ] `fasterq-dump`
- [ ] `fastq-dump`
- [ ] `vdb-validate`
- [ ] `sra-tools`
- [ ] `datasets`
- [ ] `dataformat`
- [ ] `ncbi-genome-download`
- [ ] `genome_updater`
- [ ] `gdc-client`
- [ ] `aria2c`
- [ ] `dx`
- [ ] `ascp`
- [ ] `ena-webin-cli`
- [ ] `ena-upload-cli`
- [ ] `pyega3`
- [ ] `kingfisher`
- [ ] `pysradb`: argparse, not Click
- [ ] `geofetch`
- [ ] `ffq`
- [ ] `parallel-fastq-dump`
- [ ] `refgenie`
- [x] `genomepy`: genomepy 0.16.4 (Click)
- [ ] `bioconvert`: rich-click, but no completion
- [ ] `pygenometracks`
- [ ] `igv-reports`
- [ ] `igvtools`
- [ ] `gw`
- [ ] `jbrowse2`
- [ ] `asciigenome`
- [ ] `goatools`
- [ ] `gseapy`
- [x] `biom`: biom-format 2.1.17 (Click)

### Proteomics and mass spectrometry

- [ ] `comet`
- [ ] `peptide-shaker`
- [ ] `searchgui`
- [ ] `openms`
- [ ] `maxquant`
- [ ] `msgf_plus`
- [ ] `percolator`
- [ ] `ThermoRawFileParser`
- [ ] `msconvert`
- [ ] `crux`
- [ ] `sage`
- [ ] `flashlfq`
- [ ] `msstitch`
- [ ] `pyprophet`: Click, 2 s: `complete-click pyprophet`
- [ ] `easypqp`: Click, 2.5 s: `complete-click easypqp`
- [ ] `ms2rescore`: Click, 4 s: `complete-click ms2rescore`
- [ ] `sirius`
- [ ] `metfrag`
- [ ] `mzmine`

### Structure, immunology and CRISPR

- [ ] `TMalign`
- [ ] `USalign`
- [ ] `openstructure`
- [ ] `anarci`
- [ ] `abnumber`
- [ ] `igblast`
- [ ] `changeo`
- [ ] `presto`
- [ ] `igdiscover`
- [ ] `trust4`
- [ ] `optitype`
- [ ] `hla-la`
- [ ] `arcas-hla`
- [ ] `seq2hla`
- [ ] `mhcflurry`
- [ ] `crisprme`
- [ ] `crispresso2`
- [ ] `crispritz`
- [ ] `coot`
- [ ] `relion`
- [ ] `smina`
- [ ] `rxdock`
- [ ] `obabel`
- [ ] `mgltools`
- [ ] `colabfold_batch`
- [ ] `run_alphafold.py`
- [ ] `boltz`
- [ ] `chai`

### Other

- [x] `ngless`: ngless 1.6.1
- [x] `SemiBin2`: semibin 2.3.0 and 2.5.0
- [x] `SemiBin`: no `SemiBin` executable in semibin 2.x: the spec is SemiBin2's (2.3.0, 2.5.0)
- [x] `macrel`: macrel 1.6.0
- [x] `argnorm`: argnorm 1.1.0
- [ ] `gmsc-mapper`
- [ ] `nextclade`
- [ ] `pangolin`
- [ ] `augur`
- [ ] `auspice`
- [ ] `usher`
- [x] `freyja`: freyja 2.0.5 (Click)
- [ ] `artic`
- [ ] `primer3_core`
- [ ] `RNAfold`
- [ ] `meme`
- [ ] `fimo`
- [ ] `homer`
- [ ] `macs2`
- [ ] `macs3`
- [ ] `sicer`
- [ ] `mageck`
- [ ] `cnvkit.py`
- [ ] `circos`
- [ ] `igv`
- [ ] `jbrowse`
- [ ] `bandage`
- [ ] `weblogo`
- [ ] `cellranger`
- [ ] `cellsnp-lite`
- [ ] `cellranger-atac`
- [ ] `spaceranger`
- [ ] `bcl2fastq`
- [ ] `bcl-convert`
- [ ] `dragen`
- [ ] `pbrun`
- [ ] `table_annovar.pl`
- [ ] `gmes_petap.pl`
- [ ] `signalp6`
- [ ] `tmhmm`
- [ ] `netMHCpan`
- [ ] `ldsc.py`
- [ ] `PRSice`
- [ ] `saige`
- [ ] `shapeit5`
- [ ] `eagle`
- [ ] `stitch`
- [ ] `pixy`
- [ ] `flashpca`
- [ ] `cellbender`
- [ ] `vireo`
- [ ] `souporcell`

## `science`: general scientific computing

Versions are what the options were checked against. Those of the tools that `scripts/gen/mk_*.py` generate (snakemake,
pandoc, aria2c, parallel, mlr, cwltool, ipython and jupyter) are pinned in the generator. `xsv` and `qsv` are read
from the program's own help when Tab is pressed (`dynamic.rhai`), so the version is that of the real help the test
stand-ins in `tests/bin` were cut from.

- [x] `jug`: jug 2.5.0
- [x] `snakemake`: snakemake 9.27.0 (rules and included files of the Snakefile as targets)
- [x] `nextflow`: nextflow 26.04.6.12646 (profiles, runs and projects; parameters of an nf-core pipeline)
- [x] `nf-core` (Click): nf-core 4.1.0, 0.1 s
- [x] `nf-test`: nf-test 0.9.5
- [x] `cwltool`: cwltool 3.3.20260925135507
- [ ] `cromwell`
- [ ] `toil`
- [ ] `planemo` (Click, 1.4 s: not registered, `complete-click planemo`)
- [x] `quarto`: quarto 1.9.38 (`--to` formats, `publish` providers and `install` tools are from its documentation)
- [x] `latexmk`: latexmk 4.87 (TeX Live 2026)
- [x] `pdflatex`: pdfTeX 3.141592653-2.6-1.40.29 (TeX Live 2026), also `pdftex`
- [x] `xelatex`: XeTeX (TeX Live 2026), also `xetex`
- [x] `bibtex`: TeX Live 2026
- [ ] `biber` (not packaged in conda-forge or Bioconda: no help to check against)
- [x] `pandoc`: pandoc 3.11 (descriptions from its man page; formats and extensions are asked of the installed pandoc)
- [x] `ipython`: ipython 9.9.0
- [x] `jupyter`: jupyterlab 4.5.2, notebook 7.5.2, nbconvert 7.16.6, jupyter_client 8.8.0, jupyter_server 2.17.0, jupyter_core 5.9.1
  (`jupyter-lab`, `jupyter-nbconvert` and the other `jupyter-*` programs too)
- [x] `Rscript`: R 4.6.1 (and `R`, which takes the same options)
- [x] `gnuplot`: gnuplot 6.0 patchlevel 5
- [ ] `glpk`
- [x] `datamash`: datamash 1.9
- [ ] `tsv-utils`
- [x] `mlr`: Miller 6.22.0
- [x] `xsv`: xsv 0.13.0
- [x] `qsv`: qsv 14.0.0
- [x] `duckdb`: duckdb 1.5.6 (`duckdb-cli`)
- [ ] `gromacs`
- [ ] `autodock-vina`
- [ ] `namd`
- [ ] `lmp`
- [x] `parallel`: GNU parallel 20260922
- [x] `aria2c`: aria2 1.37.0
- [x] `pigz`: pigz 2.8
- [x] `apptainer` (Cobra): apptainer 1.5.4, 10 ms
- [ ] `singularity` (Cobra): registered on the same bridge as `apptainer`, but not run: it is not in conda-forge
- [x] `awscli`: AWS CLI 2.36.47, through its `aws_completer` (50 ms)

## `gui`: desktop programs

- [x] `firefox`: Firefox 156.0.1 (profiles from `profiles.ini`, also those of the Snap, the Flatpak and
  `$XDG_CONFIG_HOME/mozilla`)
- [x] `chromium`: Chrome 154 (its manual page and the stable switches used most; the same spec as `google-chrome`)
- [x] `google-chrome`: Google Chrome 154.0.8037.92 (also `google-chrome-stable`; profiles from `Local State`)
- [x] `thunderbird`: Thunderbird 156.0.1
- [x] `libreoffice`: LibreOffice 24.2.7.2 (Ubuntu's; the formats of `--convert-to` are read from the installation's
  filter registry)
- [x] `soffice`: LibreOffice 24.2.7.2 (the same program as `libreoffice`)
- [x] `evince`: evince 46.3.1 (Ubuntu's)
- [x] `okular`: okular 23.08.5 (Ubuntu's; with Qt 5's and KDE's own options)
- [x] `zathura`: zathura 2026.07.18 (from its source, `zathura/main.c`: not in conda-forge)
- [x] `xdg-open`: xdg-utils 1.1.3
- [x] `code`: Visual Studio Code 1.140.0 (extensions from `extensions.json`; `tunnel`, `serve-web` and `agent` read from
  their `-h`)
- [x] `meld`: meld 3.24.0 (from its source, `meld/meldapp.py`)
- [x] `gedit`: gedit 50.0 (from its source, `gedit/gedit-app.c`)
- [x] `kate`: kate 23.08.5 (Ubuntu's; sessions from `~/.local/share/kate/sessions`)
- [x] `vlc`: VLC 3.0.24 (the core's options used most, from `src/libvlc-module.c`; also `cvlc`)
- [x] `mpv`: read from the installed mpv's `--list-options` (0.37.0 and 0.41.0 checked; the tests' stand-in is
  0.41.0's)
- [x] `gimp`: GIMP 3.0.4 (from its source, `app/main.c`), and 2.10.36 (Ubuntu's), which lacks `--quit`
- [x] `inkscape`: Inkscape 1.4.2 (from its source and manual page; 1.2.2, Ubuntu's, has `--pdf-page` where 1.4 has
  `--pages`); actions from `inkscape --action-list`
- [x] `krita`: Krita 6.0.4 (from its source, `libs/ui/KisApplicationArguments.cpp`)
- [x] `blender`: Blender 5.2.2 (from its source, `source/creator/creator_args.cc`)
- [x] `obs`: OBS Studio 32.2.2 (from its source, `frontend/obs-main.cpp`: not in conda-forge)
- [x] `audacity`: Audacity 4.0.1 (from its source, `src/app/commandlineparser.cpp`), and the options of 3.7.5 that
  4 dropped (`-b`, `-j`, `-t`)
- [x] `eog`: eog 45.3 (Ubuntu's)
- [x] `cytoscape`: Cytoscape 3.10.4 (Bioconda's `cytoscape.sh`; also `Cytoscape`, the installer's launcher)
- [x] `jalview`: jalview 2.11.5.1 (its arguments of 2.11.3 and later, `--help-all`)
- [x] `artemis`: Artemis 18.2.0 (`art`, `act`, `bamview`, `dnaplotter`)
- [x] `tablet`: tablet 1.17.08.17 (its launcher only takes `--version`)
- [x] `bandage_ng`: BandageNG 2026.9.1 (`BandageNG`; generated by `scripts/gen/mk_bandage.py`)
- [x] `proksee`: (Click) proksee 1.0.0a6, 207 ms
- [x] `pymol`: PyMOL 3.1.0 (pymol-open-source)
- [x] `chimerax`: ChimeraX 1.11.1 (from its manual page source, `src/apps/ChimeraX/ChimeraX.rst`; also `ChimeraX`)
- [x] `vmd`: VMD 1.9.3
- [x] `xrandr`: xrandr 1.5.2 (outputs and modes from `xrandr --query`)
- [x] `gsettings`: GLib 2.80.0 (schemas, keys and values from gsettings)
- [x] `dconf`: dconf 0.40.0 (paths from `dconf list`)
- [x] `notify-send`: libnotify 0.8.3
- [x] `wmctrl`: wmctrl 1.07 (Debian's git snapshot of 2024-02-28, from its source; windows from `wmctrl -l`)
- [x] `xdotool`: xdotool 4.20260303.1 (and 3.20160805.1, Ubuntu's, which lacks `search --role`)
- [x] `swaymsg`: sway 1.12 (from its source, `swaymsg/main.c`)
- [x] `hyprctl`: Hyprland 0.56.2 (from its source, `hyprctl/src/Strings.hpp` and `hyprctl/hyprctl.usage`)

## `dev`: development and deployment

Versions are what the options were checked against, from conda-forge. `scripts/gen/mk_*.py` generate pytest's, mypy's
and poetry's tables from their parsers (pytest's with the pytest-xdist and pytest-cov that are pinned with it). ruff's
options, linters and rules are read from the installed ruff when Tab is pressed (`dynamic.rhai`), so the version is that
of the output the test stand-in in `tests/bin` was cut from.

- [x] `poetry`: poetry 2.5.1
- [x] `twine`: twine 7.0.0
- [x] `pytest`: pytest 9.1.1, pytest-xdist 3.8.0, pytest-cov 7.1.0 (also `py.test`)
- [x] `ruff`: ruff 0.16.9 (options, linters and rules read from the installed `ruff`)
- [x] `mypy`: mypy 2.3.1
- [x] `fzf`: fzf 0.74
- [x] `bat`: bat 0.26.1 (also `batcat`; languages and themes read from the installed `bat`)
- [ ] `svn`
- [ ] `netlify`
- [ ] `adb`

## `system`: system administration

- [x] `borg`: borgbackup 1.2.8 (not in conda-forge: generated from the installed borg, Debian's package)
- [x] `fusermount`: fuse 3.14.0 (also `fusermount3`)

## Possible later plugins

- [ ] `hpc`
- [ ] `sbatch`
- [ ] `squeue`
- [ ] `scancel`
- [ ] `sacct`
- [ ] `srun`
- [ ] `sinfo`
- [ ] `qsub`
- [ ] `bsub`
- [ ] `module`
- [ ] `s5cmd`
- [ ] `globus`
- [ ] `cloud`
- [ ] `aws`
- [ ] `gcloud`
- [ ] `az`
- [ ] `media`
- [ ] `ffmpeg`
- [ ] `magick`
- [ ] `convert`
- [ ] `yt-dlp`
