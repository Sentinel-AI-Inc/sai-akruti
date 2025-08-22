# Build & Release Wheel

This repository includes a GitHub Actions workflow that builds a Python wheel using [Poetry](https://python-poetry.org/) and attaches it to a GitHub Release.

## Prerequisites

- **Poetry** configured in your project (`pyproject.toml` with `tool.poetry`).
- Workflow saved at: `.github/workflows/build-release-wheel.yml`.
- Repo has **Actions** enabled.
- `GITHUB_TOKEN` is available by default in GitHub Actions; no extra setup needed.

---

## Triggers

### 1) Tag Push (automatic)
Pushing a tag like `v0.1.0` triggers the workflow and uploads the wheel to the Release for that tag.

```bash
git tag -a v0.1.0 -m "Release v0.1.0"
git push origin v0.1.0
```

### 2) Manual Run (Option 2 – “Run workflow” button)
You can run the workflow from the **Actions** tab with or without specifying a version.  
If you provide a version (e.g., `v0.1.1`), the job will create & push that tag inside the run, then build and upload the wheel.

---

## Workflow (with manual trigger support)

```yaml
name: Build & Release Wheel

on:
  push:
    tags:
      - "v*.*.*"
  workflow_dispatch:
    inputs:
      version:
        description: "Version to tag (e.g., v0.1.0). Leave blank to only build."
        required: false

jobs:
  build-and-release:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install Poetry
        run: pip install poetry

      - name: Install Dependencies
        run: poetry install --no-root

      - name: (Optional) Create Git Tag from Input
        if: ${{ github.event_name == 'workflow_dispatch' && inputs.version != '' }}
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git tag -a "${{ inputs.version }}" -m "Release ${{ inputs.version }}"
          git push origin "${{ inputs.version }}"

      - name: Build Wheel
        run: poetry build -f wheel

      - name: Upload Wheel to GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: dist/*.whl
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Manual Dispatch: Step-by-Step

1. **Open Actions tab**  
   - GitHub → your repository → **Actions**.

2. **Select the workflow**  
   - In the left sidebar, click **Build & Release Wheel**.

3. **Run workflow**  
   - Click the **Run workflow** button.  
   - In the dropdown:
     - **Branch:** choose your default branch (e.g., `main`).
     - **version (optional):** enter something like `v0.1.1`.

4. **Click the green Run workflow button**  
   - The run will start and appear in the **Workflow runs** list.

5. **Check progress & artifacts**  
   - Click into the job to watch logs.
   - When done, go to the **Releases** section.  
     - You should see a Release for the tag with the `.whl` attached.

---

## Using GitHub Releases via CLI (`gh release`)

You can also create releases from the CLI with [GitHub CLI](https://cli.github.com/):

```bash
# Create a tag + release (notes optional)
gh release create v0.1.2 --notes "Release v0.1.2"

# (Optional) If you already built locally and want to upload a wheel:
gh release upload v0.1.2 dist/*.whl --clobber
```

If you don’t upload the wheel locally, the **workflow** will build it and attach it automatically.

---

## Outputs

- A Python wheel (`dist/*.whl`) attached under **Releases → Assets** for the corresponding `vX.Y.Z` tag.

---

## FAQ

**Q: Can I make the job _only_ run manually?**  
Yes. Remove the `push: tags:` trigger and keep only `workflow_dispatch`.

**Q: Can I publish to PyPI instead of just GitHub Releases?**  
Yes. Add a step using `pypa/gh-action-pypi-publish` and set `PYPI_API_TOKEN` in repo secrets.
