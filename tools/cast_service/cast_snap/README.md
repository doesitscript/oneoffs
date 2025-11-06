
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

i-054443c7dc4253556
python cast_snapshot_tool.py \
  --profile $PROFILE \
  --region us-east-2 \
  --filter tag:Application=cast \
  --filter tag:Environment=dev \
  --filter tag:Role=server \
  --policy cast-manual-baseline \
  --tag CreatedBy=handoff \
  --wait
  
Key
	
Value

Hostname
brd26w080n1
Environment
dev
Name
brd-ue2-dev-cast-srv-01
ManagedBy
Terraform
Owner
cast-team
Application
cast

i-00a3cb5faf95c6561

Key
	
Value

Name
ec2-ecs-cast-02
python cast_snapshot_tool.py \
  --profile $PROFILE \
  --region us-east-2 \
  --instance-id i-00a3cb5faf95c6561 \
  --policy cast-manual-baseline \
  --tag CreatedBy=handoff \
  --wait