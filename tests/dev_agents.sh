# claude (Commander) and codex (clap), whose help is asked of tests/bin/claude and tests/bin/codex, stand-ins
# with their real help cut short, and opencode, whose spec is a table. The agents of claude's --agent are the
# files of the nearest .claude/agents and of ~/.claude/agents; the profiles of codex's -p are those of $CODEX_HOME.
__luish_internal plugin load "$EXTRA/completion/dev"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p proj/src .claude/agents .codex proj/.claude/agents
touch .claude/agents/planner.md .claude/agents/notes.txt proj/.claude/agents/reviewer.md proj/prompt.md proj/src/main.py
touch .codex/work.config.toml .codex/auth.json
printf '[profiles.old]\nmodel = "o3"\n\n[profiles."dotted.name"]\n' >.codex/config.toml
cd proj
echo "=== claude"
c 'claude --perm'
c 'claude --permission-mode '
c 'claude --permission-mode=p'
c 'claude --output-format='
c 'claude --input-format '
c 'claude --effort '
c 'claude --model '
c 'claude --agent '
c 'claude --add-dir '
c 'claude --settings '
c 'claude -p --'
c 'claude mc'
c 'claude mcp '
c 'claude mcp add --'
c 'claude mcp add --scope '
c 'claude mcp add -t '
c 'claude mcp add --transport=h'
c 'claude mcp get '
c 'claude plugin'
c 'claude stop'
c 'claude kill'
c 'claude fix the bug --perm'
c 'claude "fix it" --effort '
echo "=== codex"
c 'codex --sand'
c 'codex --sandbox '
c 'codex -a '
c 'codex ex'
c 'codex exec --'
c 'codex exec -s '
c 'codex mcp '
c 'codex -p '
c 'codex --profile=w'
c 'codex -C '
c 'codex exec nosuch --'
echo "=== opencode"
c 'opencode --log-'
c 'opencode --log-level '
c 'opencode r'
c 'opencode run --'
c 'opencode run --format '
c 'opencode run -f '
c 'opencode run --dir '
c 'opencode session '
c 'opencode session list --'
c 'opencode session list --format '
c 'opencode mcp '
c 'opencode mcp add --'
c 'opencode auth '
c 'opencode providers login --'
c 'opencode agent create --mode '
c 'opencode upgrade --method '
c 'opencode db '
c 'opencode import '
c 'opencode '
