gitx-track --dry-run

---
[empty-line]
[bold][brblack]{icon} [/brblack][/bold]Files tracked: [bold][brblack]{number}[/brblack][/bold]
    [bold][brblack]{filepath1}
    {filepath2}
    {filepathN}[/brblack][/bold]
[empty-line]
  Next: [cyan]gitx-commit[/cyan] [bold][brblack]test[/brblack][/bold] [-m "Message"] # Message is optional
[empty-line]
---

conditions:

1. the following block only appears if number > 0

```
[empty-line]
  Next: [cyan]gitx-commit[/cyan] [bold][brblack]test[/brblack][/bold] [-m "Message"] # Message is optional
```

2. icon is the same neutral icon from gitx-init

____________________________________________________________

gitx-track

---
[empty-line]
[result-color]{icon} [/result-color]Files tracked: [bold][result-color]{number}[/result-color][/bold]
    [bold][result-color]{filepath1}
    {filepath2}
    {filepathN}[/result-color][/bold]
[empty-line]
  Next: [cyan]gitx-commit[/cyan] [bold][result-color]test[/result-color][/bold] [-m "Message"] # Message is optional
[empty-line]
---

conditions:

1. the following block only appears if number > 0

```
[empty-line]
  Next: [cyan]gitx-commit[/cyan] [bold][result-color]test[/result-color][/bold] [-m "Message"] # Message is optional
```

2. result-color is green if number > 0, else red

3. icon is a checkmark if number > 0, else an X
