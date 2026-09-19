#include "cppdefs.h"
#ifdef SEAICE
!!
!!git $Id: f3cd98c7 2024-12-27 19:13:42 UTC arango $
!!================================================= Hernan G. Arango ===
!! Copyright (c) 2002-2025 The ROMS Group                              !
!!   Licensed under a MIT/X style license                              !
!!   See License_ROMS.md                                               !
!!======================================================================
!!                                                                     !
!!  This routine reads and reports seaice model input parameters.      !
!!                                                                     !
!!======================================================================
!!
# if defined ICE_MODEL
#  include <ice_inp.h>
# endif
#else
      SUBROUTINE read_IcePar
      END SUBROUTINE read_IcePar
#endif
