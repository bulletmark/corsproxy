NAME = $(shell basename $(CURDIR))
PYNAME = $(subst -,_,$(NAME))
PYFILES = $(PYNAME)

check::
	ruff check $(PYFILES)
	mypy $(PYFILES)
	pyright $(PYFILES)
	vermin -v --exclude tomllib -i --no-tips $(PYFILES)
	md-link-checker

docker::
	./docker.sh

doc::
	update-readme-usage

format::
	ruff check --select I --fix $(PYFILES) && ruff format $(PYFILES)

clean::
	@rm -rf *.egg-info .venv/ build/ dist/ __pycache__/
