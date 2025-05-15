
# CI Pipeline - Professional Documentation

Welcome! This documentation presents a **complete, high-quality overview** of the CI pipeline for the `dev` branch, including detailed flow visualizations, a layered stack view, and instructions for local CI testing with ACT.

---

## 1. Flow Diagram with Icons

This flow diagram visually represents the CI steps with custom icons for clarity and professionalism.

```html
<svg width="1100" height="120" xmlns="http://www.w3.org/2000/svg" style="font-family: Arial, sans-serif;">
  <!-- Background -->
  <rect width="1100" height="120" fill="#f9f9f9" rx="10" ry="10" />
  
  <!-- Steps -->
  <!-- Checkout code -->
  <g>
    <rect x="20" y="20" width="160" height="80" fill="#007ACC" rx="8" ry="8" />
    <image href="https://cdn-icons-png.flaticon.com/512/61/61112.png" x="45" y="35" width="30" height="30" />
    <text x="105" y="70" fill="white" font-size="14" text-anchor="middle" dominant-baseline="middle" font-weight="600">Checkout code</text>
  </g>

  <!-- Arrow -->
  <path d="M180 60 L220 60" stroke="#333" stroke-width="3" marker-end="url(#arrowhead)"/>
  
  <!-- Set up Node.js -->
  <g>
    <rect x="220" y="20" width="160" height="80" fill="#007ACC" rx="8" ry="8" />
    <image href="https://cdn-icons-png.flaticon.com/512/919/919825.png" x="250" y="35" width="30" height="30" />
    <text x="300" y="70" fill="white" font-size="14" text-anchor="middle" dominant-baseline="middle" font-weight="600">Set up Node.js</text>
  </g>

  <!-- Arrow -->
  <path d="M380 60 L420 60" stroke="#333" stroke-width="3" marker-end="url(#arrowhead)"/>

  <!-- Install dependencies -->
  <g>
    <rect x="420" y="20" width="160" height="80" fill="#007ACC" rx="8" ry="8" />
    <image href="https://cdn-icons-png.flaticon.com/512/892/892692.png" x="450" y="35" width="30" height="30" />
    <text x="500" y="70" fill="white" font-size="14" text-anchor="middle" dominant-baseline="middle" font-weight="600">Install dependencies</text>
  </g>

  <!-- Arrow -->
  <path d="M580 60 L620 60" stroke="#333" stroke-width="3" marker-end="url(#arrowhead)"/>

  <!-- Lint the code -->
  <g>
    <rect x="620" y="20" width="160" height="80" fill="#007ACC" rx="8" ry="8" />
    <image href="https://cdn-icons-png.flaticon.com/512/1250/1250630.png" x="650" y="35" width="30" height="30" />
    <text x="700" y="70" fill="white" font-size="14" text-anchor="middle" dominant-baseline="middle" font-weight="600">Lint the code</text>
  </g>

  <!-- Arrow -->
  <path d="M780 60 L820 60" stroke="#333" stroke-width="3" marker-end="url(#arrowhead)"/>

  <!-- Run unit tests -->
  <g>
    <rect x="820" y="20" width="160" height="80" fill="#007ACC" rx="8" ry="8" />
    <image href="https://cdn-icons-png.flaticon.com/512/3063/3063828.png" x="850" y="35" width="30" height="30" />
    <text x="900" y="70" fill="white" font-size="14" text-anchor="middle" dominant-baseline="middle" font-weight="600">Run unit tests</text>
  </g>

  <!-- Arrow -->
  <path d="M980 60 L1020 60" stroke="#333" stroke-width="3" marker-end="url(#arrowhead)"/>

  <!-- Build check -->
  <g>
    <rect x="1020" y="20" width="160" height="80" fill="#007ACC" rx="8" ry="8" />
    <image href="https://cdn-icons-png.flaticon.com/512/2483/2483400.png" x="1050" y="35" width="30" height="30" />
    <text x="1100" y="70" fill="white" font-size="14" text-anchor="middle" dominant-baseline="middle" font-weight="600">Build check</text>
  </g>

  <!-- Arrowhead Marker -->
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" 
    refX="10" refY="3.5" orient="auto" fill="#333">
      <polygon points="0 0, 10 3.5, 0 7" />
    </marker>
  </defs>
</svg>
```

---

## 2. Layered Stack Visualization

Layered stack view clarifies the separation of job phases and their detailed steps.

```html
<canvas id="layeredStack" width="700" height="320" style="border-radius: 12px; box-shadow: 0 0 10px rgba(0,0,0,0.1);"></canvas>

<script>
const canvas = document.getElementById('layeredStack');
const ctx = canvas.getContext('2d');

// Colors and styling
const blue = '#2380f7';
const green = '#2a8f3b';
const padding = 20;
const sectionWidth = 660;
const sectionHeight = 140;

// Draw blue section - Build and Test
ctx.fillStyle = blue;
ctx.fillRect(padding, padding, sectionWidth, sectionHeight);
ctx.fillStyle = 'white';
ctx.font = 'bold 18px Arial';
ctx.fillText('Build and Test', padding + 15, padding + 30);
ctx.font = '14px Arial';
const buildSteps = [
  'Checkout code',
  'Set up Node.js',
  'Install dependencies',
  'Lint the code',
  'Run unit tests',
  'Build check (dry-run)'
];
buildSteps.forEach((step, i) => {
  ctx.fillText('• ' + step, padding + 15, padding + 55 + i * 22);
});

// Draw green section - Docker Build and Push
ctx.fillStyle = green;
ctx.fillRect(padding, padding + sectionHeight + 30, sectionWidth, sectionHeight);
ctx.fillStyle = 'white';
ctx.font = 'bold 18px Arial';
ctx.fillText('Docker Build and Push', padding + 15, padding + sectionHeight + 30 + 30);
ctx.font = '14px Arial';
const dockerSteps = [
  'Checkout code',
  'Setup Docker Buildx',
  'Extract version',
  'Login to GH Container Registry',
  'Build and Push Docker image'
];
dockerSteps.forEach((step, i) => {
  ctx.fillText('• ' + step, padding + 15, padding + sectionHeight + 30 + 55 + i * 22);
});
</script>
```

---

## 3. Testing Locally with ACT

[ACT](https://github.com/nektos/act) enables you to **run GitHub Actions workflows locally**, allowing fast feedback without pushing commits.

### Why use ACT?

- Save time by testing workflows on your machine before pushing.
- Debug complex workflows quickly.
- Replicate GitHub Actions environment locally.

### How to use ACT for this CI pipeline:

1. **Install ACT**:  
```bash
brew install act       # macOS (using Homebrew)
# or see https://github.com/nektos/act#installation for other OSes
```

2. **Run the workflow locally:**  
From your repo root, run:  
```bash
act -j build-and-test
```  
This runs the `build-and-test` job locally.

3. **Run the full pipeline:**  
To run both jobs respecting dependencies:  
```bash
act -j docker-build-and-push
```  
Since `docker-build-and-push` depends on `build-and-test`, ACT runs both in order.

4. **Use Docker:**  
Make sure Docker is running locally since your workflow uses Docker commands.

### Tips:

- Use `-P ubuntu-latest=nektos/act-environments-ubuntu:18.04` to specify the environment if needed.  
- Use `--secret-file` to pass secrets for private registries.  

---

# Complete YAML file reference for CI pipeline:

```yaml
name: CI - Dev

on:
  push:
    branches:
      - dev

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./client
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 22

      - name: Install dependencies
        run: npm ci

      - name: Lint the code
        run: npm run lint

      - name: Run unit tests
        run: npm test -- --watchAll=false

      - name: Build check (dry-run)
        run: npm run build

  docker-build-and-push:
    needs: build-and-test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    defaults:
      run:
        working-directory: ./client
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Extract version from package.json
        id: extract_version
        run: |
          echo "version=$(jq -r .version package.json)" >> $GITHUB_OUTPUT

      - name: Login to GitHub Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and Push Docker image
        uses: docker/build-push-action@v5
        with:
          context: ./client
          file: ./client/Dockerfile
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:dev
            ghcr.io/${{ github.repository }}:dev-${{ steps.extract_version.outputs.version }}
```

---


