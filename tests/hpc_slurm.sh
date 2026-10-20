# Slurm's commands. The cluster is stood in for by tests/bin/sinfo, squeue, sacct, sacctmgr and scontrol: partitions
# debug and gpu, the nodes n01, n02, g01 and g02, the user's jobs 4242, 4243 and the array 4250, ... The commands
# that srun and salloc run are bin/zzrun's, after PATH is set.
__luish_internal plugin load "$EXTRA/completion/hpc"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
USER=alice
mkdir bin
touch job.sh data.txt bin/zzrun
chmod +x bin/zzrun
PATH=$PWD/bin:$PATH
echo "=== sbatch"
c 'sbatch --part'
c 'sbatch -p '
c 'sbatch --partition=g'
c 'sbatch -p debug,'
c 'sbatch -A '
c 'sbatch --qos='
c 'sbatch --mail-type=BEGIN,E'
c 'sbatch -d '
c 'sbatch -d afterok:'
c 'sbatch --dependency=afterok:4242:'
c 'sbatch --dependency=afterok:4242,sing'
c "sbatch -C 'avx2&i"
c 'sbatch --constraint=a'
c 'sbatch --gres='
c 'sbatch -w n0'
c 'sbatch --reservation '
c 'sbatch -L '
c 'sbatch -M '
c 'sbatch --open-mode '
c 'sbatch --test-o'
c 'sbatch -o '
c 'sbatch -p debug jo'
c 'sbatch job.sh --part'
echo "=== srun"
c 'srun --mpi='
c 'srun --cpu-bind=verbose,'
c 'srun --jobid '
c 'srun -n 4 --pty zzr'
c 'srun -n 4 zzrun d'
c 'srun -p gpu sbatch --te'
echo "=== salloc"
c 'salloc --x11='
c 'salloc -N 2 zzr'
echo "=== squeue"
c 'squeue -t '
c 'squeue --states=PENDING,R'
c 'squeue -O JobId,Na'
c 'squeue -j '
c 'squeue --jobs=4242,'
c 'squeue -u roo'
c 'squeue -u daemon,ro'
c 'squeue x'
echo "=== scancel"
c 'scancel '
c 'scancel 4242 '
c 'scancel -s '
c 'scancel --state='
echo "=== sinfo"
c 'sinfo -t '
c 'sinfo -O Node'
c 'sinfo -n '
echo "=== sacct"
c 'sacct -j '
c 'sacct --format=JobID,Max'
c 'sacct -s '
c 'sacct --units '
