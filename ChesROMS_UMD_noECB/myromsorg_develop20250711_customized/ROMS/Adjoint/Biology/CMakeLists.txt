# git $Id: f3cd98c7 2024-12-27 19:13:42 UTC arango $
#:::::::::::::::::::::::::::::::::::::::::::::::::::::: David Robertson :::
# Copyright (c) 2002-2025 The ROMS Group                                :::
#   Licensed under a MIT/X style license                                :::
#   See License_ROMS.md                                                 :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#
# Source code list for sub-directory "ROMS/Adjoint/Biology"

list( APPEND _files
      ROMS/Adjoint/Biology/ad_biology.F
)

set ( ROMS_Adjoint_Biology_files
      ${_files}
      PARENT_SCOPE
)
