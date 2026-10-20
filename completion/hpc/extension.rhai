// Completion for HPC tools, by the command's name.

// Slurm's commands: the values of their options are asked of the cluster, and srun and salloc hand the command they
// run over to its own completer, so they have a completer of their own (slurm.rhai).
for cmd in ["sbatch", "salloc", "srun", "squeue", "scancel", "sinfo", "sacct"] {
    sh::completer(cmd, |words, i| {
        import "slurm" as m;
        m::complete(words, i)
    });
}
