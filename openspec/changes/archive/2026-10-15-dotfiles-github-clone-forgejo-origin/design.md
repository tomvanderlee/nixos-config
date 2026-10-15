## Context

`modules/home/dotfiles.nix` clones `cfg.repoUrl` to `~/dotfiles` in a home-manager activation script only when `~/dotfiles/.git` is missing, then stows packages. The `dotfiles-management` spec forbids modifying an existing checkout, so any remote setup must live inside that same "missing" branch.

## Goals / Non-Goals

**Goals:**
- Fresh clones bootstrap from GitHub and end with `origin` (Forgejo) as the branch upstream.
- Option is generic and opt-in so other users of the module are unaffected.

**Non-Goals:**
- Fixing up remotes on existing checkouts.
- Other git config (dotfiles repo owns it).

## Decisions

- **New option `home.dotfiles.originUrl` (str, default `""`)** rather than hardcoding Forgejo in the module. Keeps the module host-agnostic; `users/tom.nix` supplies the values. Alternative considered: a `pushUrl` on a single `origin` remote (`remote.origin.pushurl`). Rejected because the request names a `github` remote and an `origin` remote explicitly.
- **`git clone --origin github`** only when `originUrl != ""`, followed by `git -C "$DOTFILES_DIR" remote add origin <originUrl>`. Done in the same `if [ ! -d .git ]` block, after the clone succeeds, so existing checkouts are untouched.
- **Branch upstream set by config**: after adding `origin`, run `git config branch.<b>.remote origin` and `branch.<b>.merge refs/heads/<b>`, with `<b>` from `git symbolic-ref --short HEAD`. This avoids needing `origin/<b>` to exist. Alternative: `git branch -u origin/<b>` — rejected, it requires a fetch of unreachable Forgejo.
- **No `git fetch origin`**: Forgejo may be unreachable (off-LAN) and the remote is for pushing only; activation must not fail or hang on it.
- **Dry-run**: both commands are prefixed with `$DRY_RUN_CMD` like the existing clone. The `remote add` is guarded on the checkout existing so dry runs do not error.

## Risks / Trade-offs

- [Bare `git pull` fails until SSH to Forgejo works] → Expected; use `git pull github <branch>` meanwhile.
- [Machines that already cloned have no Forgejo remote] → Out of scope per the never-modify rule; add by hand with `git remote add`.
- [`ssh+git://` with port 2222 needs Forgejo host key and key access] → Surfaces only at push time, not during activation.
