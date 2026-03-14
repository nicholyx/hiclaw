# Changelog (Unreleased)

Record image-affecting changes to `manager/`, `worker/`, `openclaw-base/` here before the next release.

---

- fix(worker): Remote->Local sync pulls Manager-managed files only (allowlist) to avoid overwriting Worker-generated content (e.g. .openclaw sessions, memory)
- fix(copaw): align sync ownership with OpenClaw worker (AGENTS.md/SOUL.md Worker-managed, push but never pull; allowlist for Remote->Local)

