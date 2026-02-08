# GITX-COMMIT Output Specification

This document defines all possible output formats for the `gitx-commit` command.

## Case 1: Dry-run with files to commit

```
[empty line]
[brblack]{neutral icon}[/brblack] Files to commit: [brblack]{number}[/brblack]
    [brblack]{file1-path}[/brblack]
    [brblack]{file2-path}[/brblack]
    ...
[empty line]
Message: {commit-message}
[empty line]
  Next: [cyan]gitx-commit [/cyan][brblack]{repo-name}[/brblack][cyan] [-m "Message"][/cyan]
[empty line]
```

**Example:**
```
[empty line]
◉ Files to commit: 3
    /home/user/.bashrc
    /home/user/.vimrc
    /home/user/.gitconfig
[empty line]
Message: Monday, Feb 8 10:30AM UTC-0800
[empty line]
  Next: gitx-commit my-configs [-m "Message"]
[empty line]
```

---

## Case 2: Dry-run with NO files to commit (noop case)

**Note:** This is a noop case - not an error. Uses green checkmark to show command didn't fail, but dry-run colors for content to indicate no action would be taken.

```
[empty line]
[green]{check icon}[/green] Files to commit: [brblack]0[/brblack]
[empty line]
Message: {commit-message}
[empty line]
```

**Example:**
```
[empty line]
✓ Files to commit: 0
[empty line]
Message: Nothing to commit
[empty line]
```

---

## Case 3: Actual commit with files (success)

```
[empty line]
[green]{check icon}[/green] Files committed: [green]{number}[/green]
    [green]{file1-path}[/green]
    [green]{file2-path}[/green]
    ...
[empty line]
Message: {commit-message}
[empty line]
  Next: [cyan]gitx [/cyan][green]{repo-name}[/green][cyan] push[/cyan]
[empty line]
```

**Example:**
```
[empty line]
✓ Files committed: 3
    /home/user/.bashrc
    /home/user/.vimrc
    /home/user/.gitconfig
[empty line]
Message: Monday, Feb 8 10:30AM UTC-0800
[empty line]
  Next: gitx my-configs push
[empty line]
```

---

## Case 4: Actual commit with NO files (noop case)

**Note:** This is a noop case - not an error. Uses green checkmark to show command didn't fail, but dry-run colors for content to indicate no action was taken.

```
[empty line]
[green]{check icon}[/green] Files committed: [brblack]0[/brblack]
[empty line]
Message: {commit-message}
[empty line]
```

**Example:**
```
[empty line]
✓ Files committed: 0
[empty line]
Message: Nothing to commit
[empty line]
```

---

## Icon Reference

- `◉` (neutral icon) - Dry-run mode
- `✓` (check icon) - Success (including noop cases with 0 files)
- `✗` (X icon) - Failure (NOT used for commit - 0 files is noop, not failure)

## Color Reference

- `[brblack]` or `[light grey]` - Dry-run content, inactive/noop values
- `[cyan]` - Command names in "Next:" suggestions
- `[green]` - Success indicators, active file counts/paths, repo names in success context
- `[red]` - NOT USED in commit (0 files is noop, not error)

## Key Behaviors

1. **Icon is always green checkmark (✓)** except for dry-run with files > 0 which uses neutral (◉)
2. **0 files is a NOOP, not an error** - uses green check icon but brblack color for the count
3. **File paths are shown** for cases with count > 0
4. **Message is always shown** on its own line
5. **Next step only shown** for actual commits with count > 0
6. **Consistent spacing:** empty line before, empty line after
