---
title: Alliance — OpenCV
type: source
updated: 2026-05-02
sources: [alliance-docs/OpenCV.md]
tags: [hpc, alliance, opencv, cuda, computer-vision, python]
---

# Alliance — OpenCV

How to load and use OpenCV on Alliance clusters. Source: https://docs.alliancecan.ca/wiki/OpenCV

## Loading OpenCV with CUDA

```bash
module load gcc cuda opencv/X.Y.Z
```

Replace `X.Y.Z` with the desired version (`module spider opencv` to list). The module includes:
- CUDA-accelerated OpenCV
- All **contrib (extra) modules** — including ArUco, SIFT, etc.
- Python bindings for multiple Python versions

## Python usage

```bash
# Find compatible Python versions for a given opencv version
module spider opencv/X.Y.Z

# Or search directly for the Python wrapper
module spider opencv_python/X.Y.Z

# Load OpenCV with Python and scipy stack
module load gcc opencv/X.Y.Z python/3.11 scipy-stack

# Test import
python -c "import cv2; print(cv2.__version__)"
```

Available Python package variants (all included in the module):
- `opencv_python`
- `opencv_contrib_python`
- `opencv_python_headless` ← **use this on cluster** (no display required)
- `opencv_contrib_python_headless`

## OpenEXR support

For reading `.exr` files (common in graphics/rendering pipelines):

```bash
OPENCV_IO_ENABLE_OPENEXR=1 python myscript.py
```

## Troubleshooting: `ModuleNotFoundError: No module named 'cv2'`

Two common causes:

**1. Forgot to load the opencv module:**
```bash
module load gcc opencv/X.Y.Z python/3.11
```

**2. Virtual environment loaded before opencv module (wrong order):**
```bash
# Correct order:
deactivate                                  # deactivate venv first
module load gcc opencv/X.Y.Z python/3.11    # load modules
source ~/envs/myenv/bin/activate            # then reactivate venv
python -c "import cv2"                      # verify
```

## In a SLURM job script

```bash
#SBATCH --account=rrg-<pi>
#SBATCH --gres=gpu:1
...

module load gcc cuda/12.6 opencv/4.x.x python/3.11 scipy-stack
source ~/envs/myenv/bin/activate

python process_frames.py
```

## Connections

- [[narval-cheat-sheet]]
- [[alliance-ml-tutorial]]
- [[alliance-available-software]] — module-vs-wheelhouse-vs-container tiers
