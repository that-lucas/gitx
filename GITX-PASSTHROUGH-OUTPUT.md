# GITX Passthrough Output Specification

The `gitx` command (passthrough to git) follows the same presenter standard as other gitx commands but simplified for direct git command output.

## Success Case

```
[empty line]
[green]{check icon}[/green] Output:
    [green]{git-output-line-1}
    {git-output-line-2}
    ...[/green]
[empty line]
```

**Example:**
```
$ gitx demo-repo status --short

✓ Output:
    A  tmp/test1.txt
    A  tmp/test2.txt
    A  tmp/test3.txt

```

---

## Failure Case

```
[empty line]
[red]{X icon}[/red] Output:
    [red]{git-output-line-1}
    {git-output-line-2}
    ...[/red]
[empty line]
```

**Example:**
```
$ gitx demo-repo invalid-command

✗ Output:
    git: 'invalid-command' is not a git command. See 'git --help'.

```

---

## Key Features

- **No dry-run mode**: Passthrough is always "actual" command execution
- **Simple output**: Just icon + "Output:" label with indented git output
- **Color coding**: Green for success (exit code 0), red for failure (non-zero exit code)
- **Indentation**: All output lines indented with 4 spaces and in bold result color
- **Spacing**: Empty line before and after output (consistent with all other presenters)

## Icon Reference

- `✓` (checkmark, green) - Command succeeded (exit code 0)
- `✗` (X, red) - Command failed (non-zero exit code)

## Comparison with Other Commands

All gitx commands now follow the same basic pattern:

**init, track, untrack, commit:**
```
  Dry-run          ← Only in dry-run mode
◉/✓ Action: N     ← Icon + action label
    details...     ← Indented details
  Message: ...     ← Additional info (commit only)
  Next: ...        ← Suggestion
```

**gitx (passthrough):**
```
✓/✗ Output:       ← Icon + simple label
    output...      ← Indented git output
```

The passthrough is simpler because:
- No dry-run mode
- No action counts or file lists
- Just displays raw git output
- No "Next" suggestions (user chose the command)
