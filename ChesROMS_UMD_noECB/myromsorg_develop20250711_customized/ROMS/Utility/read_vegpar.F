#include "cppdefs.h"
#ifdef VEGETATION
!!
!!git $Id: 1cbc67d8 2025-06-05 22:10:38 UTC arango $
!!================================================= Hernan G. Arango ===
!! Copyright (c) 2002-2024 The ROMS/TOMS Group                         !
!!   Licensed under a MIT/X style license                              !
!!   See License_ROMS.txt                                              !
!!======================================================================
!!                                                                     !
!!  This routine reads and reports vegetation model input parameters.  !
!!                                                                     !
!!======================================================================
!!
# include <vegetation_inp.h>
#else
      SUBROUTINE read_vegpar
      END SUBROUTINE read_vegpar
#endif
