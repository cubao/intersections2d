PYTHON_EXECUTABLE ?= python3

all:
	@echo nothing special
clean:
	rm -rf build dist **/*.egg-info *.egg-info
package:
	$(PYTHON_EXECUTABLE) setup.py bdist_wheel
install: package
	$(PYTHON_EXECUTABLE) -m pip install dist/*.whl -U --force-reinstall
upload: package
	$(PYTHON_EXECUTABLE) setup.py bdist_wheel upload -r local
