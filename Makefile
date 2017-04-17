# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    = -c .
SPHINXBUILD   = sphinx-build
SPHINXPROJ    = EffectiveDjango
SOURCEDIR     = source
BUILDDIR      = build
BUILDBRANCH 	= gh-pages

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

html:
	@$(SPHINXBUILD) -b html $(SOURCEDIR) "$(BUILDDIR)/" $(SPHINXOPTS) $(O)

push:
	MESSAGE = $(shell git log -1 --pretty=format:"%s (%h)")
	
	git --git-dir=$(BUILDDIR)/.git checkout $(BUILDBRANCH)
	git --git-dir=$(BUILDDIR)/.git add .
	git --git-dir=$(BUILDDIR)/.git commit -m '$(MESSAGE)'
	git --git-dir=$(BUILDDIR)/.git push origin gh-pages

.PHONY: help html Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
