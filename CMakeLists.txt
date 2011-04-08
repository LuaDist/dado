# Copyright (C) 2007-2009 LuaDist.
# Created by Peter Kapec
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

PROJECT(dado NONE)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
INCLUDE(dist.cmake)

# Install all files and documentation
INSTALL (DIRECTORY src/dado DESTINATION ${INSTALL_LMOD})
INSTALL (FILES src/check.lua DESTINATION ${INSTALL_LMOD})

INSTALL (FILES src/string.extra.lua DESTINATION ${INSTALL_LMOD}/string RENAME extra.lua)
INSTALL (FILES src/table.extra.lua DESTINATION ${INSTALL_LMOD}/table RENAME extra.lua)

INSTALL (FILES src/rm_check.lua DESTINATION ${INSTALL_BIN})

INSTALL (FILES README DESTINATION ${INSTALL_DATA})
INSTALL (DIRECTORY tests/ DESTINATION ${INSTALL_TEST})
INSTALL (DIRECTORY doc/ DESTINATION ${INSTALL_DOC})
