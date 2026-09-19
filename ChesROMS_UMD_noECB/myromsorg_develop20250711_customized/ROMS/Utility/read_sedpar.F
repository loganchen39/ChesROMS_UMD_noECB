#include "cppdefs.h"
#ifdef SEDIMENT
!!
!!git $Id: f3cd98c7 2024-12-27 19:13:42 UTC arango $
!!================================================= Hernan G. Arango ===
!! Copyright (c) 2002-2025 The ROMS Group                              !
!!   Licensed under a MIT/X style license                              !
!!   See License_ROMS.md                                               !
!!======================================================================
!!                                                                     !
!!  This routine reads and reports sediment model input parameters.    !
!!                                                                     !
!!======================================================================
!!
# include <sediment_inp.h>
#else
      SUBROUTINE read_SedPar
      END SUBROUTINE read_SedPar
#endif
