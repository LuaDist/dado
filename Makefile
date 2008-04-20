# $Id: Makefile,v 1.21 2008/04/20 21:17:09 tomas Exp $

PKG= dado
V= 1.0
DIST_DIR= $(PKG)-$V
LUA_DIR= /usr/local/share/lua/5.1
DADO_DIR= $(LUA_DIR)/dado
STRING_EXTRA_DIR= $(LUA_DIR)/string
TABLE_EXTRA_DIR= $(LUA_DIR)/table
DOC_DIR= /usr/local/apache2/htdocs/doc/dado
BIN_DIR= /usr/local/bin
HTMLS= doc/index.html doc/license.html doc/examples.html
CHECK_SRC= src/check.lua
DADO_SRCS= src/dado/init.lua \
	src/dado/object.lua \
	src/dado/sql.lua
STRING_EXTRA= src/string.extra.lua
TABLE_EXTRA= src/table.extra.lua
SRCS= $(CHECK_SRC) \
	$(DADO_SRCS) \
	$(STRING_EXTRA) \
	$(TABLE_EXTRA)
TESTS= tests/overall.lua \
	tests/tsql.lua \
	tests/ttable.extra.lua \
	tests/tstring.extra.lua \
	tests/tdado.lua \
	tests/tdbobj.lua
RMCK= src/rm_check.lua


usage:
	@echo Options:
	@echo "    installdoc  = docs install"
	@echo "    installprod = clean install (without arg checks)"
	@echo "    installsrc  = source install (with arg checks)"
	@echo "    install     = installprod + installdoc"
	@echo "    dist"

install: installprod installdoc

installsrc: $(SRCS) installrmck
	mkdir -p $(LUA_DIR)
	cp $(CHECK_SRC) $(LUA_DIR)
	mkdir -p $(STRING_EXTRA_DIR)
	cp $(STRING_EXTRA) $(STRING_EXTRA_DIR)/extra.lua
	mkdir -p $(TABLE_EXTRA_DIR)
	cp $(TABLE_EXTRA) $(TABLE_EXTRA_DIR)/extra.lua
	mkdir -p $(DADO_DIR)
	cp $(DADO_SRCS) $(DADO_DIR)

installprod: installsrc installrmck
	$(BIN_DIR)/rm_check.lua $(STRING_EXTRA_DIR)/* $(TABLE_EXTRA_DIR)/* $(DADO_DIR)/*

installrmck: $(RMCK)
	mkdir -p $(BIN_DIR)
	cp $(RMCK) $(BIN_DIR)/rm_check.lua

installdoc:
	mkdir -p $(DOC_DIR)
	cp -R doc/* $(DOC_DIR)

dist: $(SRCS) $(RMCK) Makefile README $(TESTS)
	mkdir -p $(DIST_DIR)
	cp Makefile README $(DIST_DIR)
	mkdir -p $(DIST_DIR)/src
	cp $(RMCK) $(CHECK_SRC) $(STRING_EXTRA) $(TABLE_EXTRA) $(DIST_DIR)/src
	mkdir -p $(DIST_DIR)/src/dado
	cp $(DADO_SRCS) $(DIST_DIR)/src/dado
	mkdir -p $(DIST_DIR)/doc/luadoc
	cp $(HTMLS) $(DIST_DIR)/doc
	cd $(DIST_DIR)/src; luadoc * -d ../doc/luadoc
	mkdir -p $(DIST_DIR)/tests
	cp $(TESTS) $(DIST_DIR)/tests
	tar czf $(PKG)-$V.tar.gz $(DIST_DIR)
	rm -rf $(DIST_DIR)
