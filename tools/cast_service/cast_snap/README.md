
uv creates and manages an environment for you, but it doesn’t leave a .venv/ folder in your workspace unless you explicitly ask for one.
uv add black

https://cursor.com/docs/configuration/languages/python

Web Frameworks: Django, Flask, FastAPI
Data Science: Jupyter, NumPy, Pandas
Machine Learning: TensorFlow, PyTorch, scikit-learn
Testing: pytest, unittest
API: requests, aiohttp
Database: SQLAlchemy, psycopg2

image.png
MLLXLJJ2XVFJ:oneoffs a805120$ uv run python - <<'PY'
import sys, pkgutil
print("uv uses:", sys.executable)
print("boto3 present?", bool(pkgutil.find_loader("boto3")))
PY
uv uses: /Users/a805120/.local/share/uv/python/cpython-3.10.18-macos-aarch64-none/bin/python3.10
boto3 present? False