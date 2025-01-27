# Copyright (C) 2013 Mark Blakeney. This program is distributed under
# the terms of the GNU General Public License.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or any
# later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License at <http://www.gnu.org/licenses/> for more
# details.

NAME = $(shell basename $(CURDIR))

check:
	ruff check $(NAME)
	mypy $(NAME)
	pyright $(NAME)
	shellcheck *.sh
	vermin -i -vv --no-tips --exclude tomllib $(NAME)

docker:
	./docker.sh

doc:
	update-readme-usage

clean:
	rm -rf  __pycache__
