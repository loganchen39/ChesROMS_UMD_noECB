# git $Id: f3cd98c7 2024-12-27 19:13:42 UTC arango $
#:::::::::::::::::::::::::::::::::::::::::::::::::::::: David Robertson :::
# Copyright (c) 2002-2025 The ROMS Group                                :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.md                                                 :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#
# Source code list for sub-directory "ROMS/Programs"

list( APPEND _files
      ROMS/Programs/types.F
      ROMS/Programs/yaml_parser_test.F
)

set ( ROMS_Programs_files
      ${_files}
      PARENT_SCOPE
)
