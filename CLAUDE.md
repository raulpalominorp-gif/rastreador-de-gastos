# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Rastreador de Gastos ("Expense Tracker") is a single-file, dependency-free personal expense tracker web app in Spanish. There is no build system, package manager, server, or test suite — the entire application (HTML, CSS, JS) lives in `index.html`.

## Development

There is no build/lint/test tooling. To work on this app:
- Open `index.html` directly in a browser (or serve it with any static file server) to run it.
- Edit `index.html` in place; changes are visible on a page reload since there is no compilation step.
- Verify changes manually in the browser — add an expense, switch months, delete an expense, and toggle the theme button to confirm nothing broke.

`auto-push.ps1` is a standalone helper script (not part of the app) that polls the working directory every 5 seconds and auto-commits/pushes any changes to `origin main`. It is meant to be run manually by the user in a separate terminal; do not invoke it as part of normal edits. If it's running elsewhere, check `git status`/`git log` before committing yourself — it may have already committed and pushed the change.

## Version control

Commit and push to GitHub (`origin main`) regularly as work progresses, so there is always a saved version of the project — don't let multiple unrelated edits pile up in one commit. After a meaningful change (a fix, a feature, a tweak verified in the browser), stage the relevant files, commit with a clear, specific message describing the change, and push. Follow the repo-wide git safety rules (no force-push, no history rewrites, ask before anything destructive).

## Architecture

Everything is in one IIFE inside `<script>` in `index.html`:

- **State**: a single `state` object (`{ expenses, selectedMonth }`) held in memory. `expenses` is an array of `{ id, date, description, category, amount }`. All mutations go through `state.expenses`, followed by `saveExpenses()` and a full `renderAll()` call — there is no partial/reactive rendering.
- **Persistence**: `localStorage`, under key `gastos_v1` for expense data and `gastos_theme` for the light/dark theme preference. `loadExpenses`/`saveExpenses` are the only functions that touch storage.
- **Rendering**: `renderAll()` is the single render entry point, called after every state change (add/delete expense, month navigation). It rebuilds: the historical total header, month stats (total/count/average), the category breakdown bars, the 6-month trend chart, and the expense table — all via direct DOM manipulation (`innerHTML`/`createElement`), no framework or virtual DOM.
- **Categories**: a fixed `CATEGORIES` array (name + CSS variable for color) drives the category `<select>`, the category chart, category dots in the table, and colors. To add/rename a category, edit this array and the corresponding `--cat-N` CSS custom properties (defined three times: base `:root`, `prefers-color-scheme: dark`, and `[data-theme="dark"]`).
- **Theming**: CSS custom properties define light/dark palettes. Theme state is `data-theme` on `<html>`, toggled by the "Tema" button and persisted to `localStorage`; when unset, it falls back to `prefers-color-scheme`.
- **Currency/dates**: amounts are formatted with `Intl.NumberFormat("es-PE", { style: "currency", currency: "PEN" })` (Peruvian Soles); month labels use `Intl.DateTimeFormat("es-ES", ...)`. Dates are stored/compared as ISO strings; `monthKey()` derives a `YYYY-MM` key used for filtering and the month navigator.
- **XSS safety**: user-entered text (description) is inserted via `escapeHtml()` before being placed in `innerHTML` — preserve this pattern when adding new fields that render user input.
