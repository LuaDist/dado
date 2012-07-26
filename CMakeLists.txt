# Copyright (C) 2007-2011 LuaDist.
# Created by Peter Kapec
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

project ( dado NONE )
cmake_minimum_required ( VERSION 2.6 )
include ( cmake/dist.cmake )
include ( lua )

install_lua_module ( dado src/dado.lua )
install_lua_module ( dado.object src/dado/object.lua )
install_lua_module ( dado.sql src/dado/sql.lua )
install_lua_module ( table.extra src/table/extra.lua )

install_data ( README )
install_test ( tests/ )
install_doc ( doc/ )

#FIX(package.path): add_lua_test ( tests/overall.lua ${CMAKE_CURRENT_SOURCE_DIR}/tests )
