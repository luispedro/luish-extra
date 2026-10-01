// GNU parallel 20260922, from `parallel --shellcompletion bash` (the option names, without their aliases that
// are only spelled differently: `--keeporder`), with the descriptions and values of the common ones. The command
// is completed as a command, and after it come the arguments (`:::`, `::::`) and files.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn spec(cmd) {
    #{
        opts: `
            --debug
            -D
            --xargs
            -m                              multiple arguments without context replace
            -X                              multiple arguments with context replace
            -v
            --sql DBURL                     use a database as the job queue
            --sql-master
            --sql-worker
            --sql-and-worker
            --joblog FILE                   log the jobs to FILE
            --jl FILE                       log the jobs to FILE
            --results NAME                  save the output of each job in a directory or file
            --result
            --res
            --resume                        resume from the last unfinished job of --joblog
            --resume-failed                 resume, and rerun the failed jobs of --joblog
            --retry-failed                  rerun the failed jobs of --joblog
            --silent                        silence the output of the jobs
            --keep-order                    keep the same order as the input
            -k                              keep the same order as the input
            --no-keep-order
            --no-k
            --group                         group output: print the output of a job when it is done
            -g                              group output: print the output of a job when it is done
            --ungroup                       print the output at once, without grouping
            -u                              print the output at once, without grouping
            --latest-line
            --ll
            --line-buffer                   buffer output on line basis
            --line-buffered
            --lb
            --tmux                          run the jobs in tmux
            --tmux-pane
            --null                          use NUL as the delimiter
            -0                              use NUL as the delimiter
            --quote                         quote the command
            -q                              quote the command
            --parens STR                    use these characters around the perl expression
            --rpl "TAG PERL"                define a replacement string
            --plus                          add more replacement strings
            -I STR                          use STR as the replacement string
            --extensionreplace
            --er
            -U
            --basenamereplace
            --bnr
            --dirnamereplace
            --dnr
            --basenameextensionreplace
            --bner
            --seqreplace
            --slotreplace
            --delay SECONDS                 delay starting jobs by SECONDS
            --ssh-delay
            --load N                        only start jobs when the load is below this
            --noswap
            --max-line-length-allowed
            --number-of-cpus
            --number-of-sockets
            --number-of-cores
            --number-of-threads
            --use-sockets-instead-of-threads
            --use-cores-instead-of-threads
            --use-cpus-instead-of-cores
            --shell-quote                   quote the given string
            --nice N                        run the jobs with this niceness
            --tag                           tag lines with the arguments
            --tag-string
            --ctag
            --ctag-string
            --color                         colour the output by job
            --colour
            --color-failed
            --colour-failed
            --color-fail
            --colour-fail
            --cf
            --onall                         run the given command with each argument on all sshlogins
            --nonall                        run the given command with no arguments on all sshlogins
            --filter-hosts
            --filter-host
            --sshlogin SSHLOGIN             use these ssh logins
            -S SSHLOGIN                     use these ssh logins
            --sshloginfile FILE             use FILE as the list of sshlogins
            --slf FILE                      use FILE as the list of sshlogins
            --controlmaster
            -M
            --ssh
            --transfer-file
            --transfer-files
            --tf
            --return FILE                   transfer this file back from the remote host
            --trc FILE                      shorthand for --transfer --return FILE --cleanup
            --transfer                      transfer the files of the arguments to the remote host
            --cleanup                       remove the transferred files
            --basefile
            --bf
            --template
            --tmpl
            -B
            --ctrl-c
            --no-ctrl-c
            --no-ctrlc
            --work-dir
            --wd DIR                        run the jobs in this directory
            -W
            --rsync-opts
            --tmpdir DIR                    directory for temporary files
            --tempdir DIR                   directory for temporary files
            --use-compress-program PROG     the program to compress temporary files
            --compress-program
            --use-decompress-program
            --decompress-program
            --compress                      compress the temporary files
            --open-tty
            -o
            --tty
            -T
            -H
            --dry-run                       print the jobs instead of running them
            --dr
            --progress                      show progress of the computations
            --eta                           show the estimated time of arrival
            --bar                           show progress as a progress bar
            --total-jobs N                  the number of jobs, for the progress
            --total
            --shuf                          shuffle the jobs
            --milestone
            --ms
            --arg-sep STR                   the separator of arguments on the command line
            --arg-file-sep
            --trim MODE                     trim white space in the input
            --env NAME                      copy this environment variable to the jobs
            --record-env
            --session                       record the environment and use it in the jobs
            --plain                         ignore the profile files
            --profile
            -J
            --tollef
            --gnu
            --link                          link the input sources instead of a cartesian product
            --xapply                        link the input sources instead of a cartesian product
            --linkinputsource
            --xapplyinputsource
            --bibtex                        print the citation as bibtex
            --citation                      print the citation notice
            --will-cite                     silence the citation notice
            --nn
            --no-notice
            --halt-on-error WHEN            when to stop, and how
            --halt WHEN                     when to stop, and how
            --limit
            --memfree SIZE                  only start jobs when this much memory is free
            --memsuspend
            --retries N                     retry a failed job N times
            --timeout SECONDS               time out a job after this long
            --term-seq
            --max-procs N                   run N jobs in parallel
            -P N                            run N jobs in parallel
            --jobs N                        run N jobs in parallel
            -j N                            run N jobs in parallel
            --delimiter STR                 use STR as the delimiter
            -d STR                          use STR as the delimiter
            --max-chars
            -s
            --arg-file FILE                 read the arguments from FILE
            -a FILE                         read the arguments from FILE
            --no-run-if-empty               do not run with empty input
            -r                              do not run with empty input
            --replace STR                   replace this string with the argument
            -i STR                          replace {} with the argument (with this string)
            -E STR                          stop reading at this string
            --eof STR                       stop reading at this string
            -e
            --process-slot-var
            --max-args N                    use at most N arguments per command line
            -n N                            use at most N arguments per command line
            --max-replace-args N            use N arguments per job
            -N N                            use N arguments per job
            --col-sep REGEXP                split input on a regexp for positional replacements
            -C REGEXP                       split input on a regexp for positional replacements
            --match
            --csv
            --help                          print help
            -h                              print help
            -L N                            use at most N input lines per command line
            --max-lines N                   use at most N input lines per command line
            -l N                            use at most N input lines per command line
            --interactive                   ask before running each job
            -p                              ask before running each job
            --verbose                       print the command before running it
            -t                              print the command before running it
            --version                       print the version
            -V                              print the version
            --min-version
            --show-limits                   print the limits of the command line
            --exit
            -x                              exit if the command line is too long
            --semaphore                     work as a counting semaphore
            --semaphore-timeout
            --st
            --semaphore-name
            --id
            --fg                            run the command in the foreground
            --bg                            run the command in the background
            --wait                          wait for all the jobs started with --semaphore
            --shebang                       run as an interpreter in the #! line
            --hashbang
            -Y
            --skip-first-line               do not use the first line of input
            --unsafe
            --pipe                          split stdin to multiple jobs
            --spreadstdin                   split stdin to multiple jobs
            --round-robin
            --round
            --recstart STR                  record start separator for --pipe
            --recend STR                    record end separator for --pipe
            --regexp
            --regex
            --remove-rec-sep
            --rrs
            --output-as-files
            --files                         save the output of each job to a file, and print its name
            --output-as-files0
            --files0
            --block-size SIZE               size of the block for --pipe
            --block SIZE                    size of the block for --pipe
            --block-timeout
            --bt
            --header REGEXP                 use the first line as the column names
            --cat                           give each job a temporary file as its input
            --fifo                          give each job a fifo as its input
            --pipe-part
            --tee                           send the same input to all jobs
            --shard
            --bin
            --group-by COL                  group input by the value of a column
            --hgrp
            --hostgrp
            --hostgroup
            --hostgroups
            --embed
            --filter
            --combine-exec
            --combine-executable
            --fast
            --shell-completion
        `,
        values: #{
            "--sql": "none", "--joblog": "files", "--jl": "files", "--results": "files", "--parens": "none",
            "--rpl": "none", "-I": "none", "--delay": "none", "--load": "none", "--nice": "none",
            "--sshlogin": "none", "-S": "none", "--sshloginfile": "files", "--slf": "files", "--return": "none",
            "--trc": "none", "--wd": "dirs", "--tmpdir": "dirs", "--tempdir": "dirs",
            "--use-compress-program": "files", "--total-jobs": "none", "--arg-sep": "none",
            "--trim": ["n", "l", "r", "lr", "rl"], "--env": "none",
            "--halt-on-error": ["never", "soon,fail=1", "now,fail=1", "soon,done=1", "now,done=1"],
            "--halt": ["never", "soon,fail=1", "now,fail=1", "soon,done=1", "now,done=1"], "--memfree": "none",
            "--retries": "none", "--timeout": "none", "--max-procs": "none", "-P": "none", "--jobs": "none",
            "-j": "none", "--delimiter": "none", "-d": "none", "--arg-file": "files", "-a": "files",
            "--replace": "none", "-i": "none", "-E": "none", "--eof": "none", "--max-args": "none", "-n": "none",
            "--max-replace-args": "none", "-N": "none", "--col-sep": "none", "-C": "none", "-L": "none",
            "--max-lines": "none", "-l": "none", "--recstart": "none", "--recend": "none", "--block-size": "none",
            "--block": "none", "--header": "none", "--group-by": "none",
        },
        args: ["commands", own("kinds:parallel_args")],
    }
}
