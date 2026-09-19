#include "cppdefs.h"
#if defined TANGENT && defined BIOLOGY

/*
** git $Id: fcba9f6d 2024-07-23 17:06:43 UTC arango $
************************************************************************
**                                                                    **
** This routine computes the tangent linear source and sink terms for **
** the selected biology model.                                        **
**                                                                    **
************************************************************************
*/

# if defined BIO_FENNEL
!!#  include <tl_fennel.h>
# elif defined NEMURO
!!#  include <tl_nemuro.h>
# elif defined NPZD_FRANKS
#  include <tl_npzd_Franks.h>
# elif defined NPZD_IRON
#  include <tl_npzd_iron.h>
# elif defined NPZD_POWELL
#  include <tl_npzd_Powell.h>
# endif
#else
      MODULE tl_biology_mod
      END MODULE tl_biology_mod
#endif
