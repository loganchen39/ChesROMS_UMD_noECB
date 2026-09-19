#include "cppdefs.h"
#if defined NONLINEAR && defined FLOATS && defined FLOAT_BIOLOGY
!
!git $Id: f3cd98c7 2024-12-27 19:13:42 UTC arango $
!================================================== Hernan G. Arango ===
!  Copyright (c) 2002-2025 The ROMS Group                              !
!    Licensed under a MIT/X style license                              !
!    See License_ROMS.md                                               !
!=======================================================================
!                                                                      !
!  These routine computes the behavior for biological floats.          !
!                                                                      !
!=======================================================================
!
# ifdef FLOAT_OYSTER
#  include <oyster_floats.h>
# endif
#else
      MODULE biology_floats_mod
      END MODULE biology_floats_mod
#endif
