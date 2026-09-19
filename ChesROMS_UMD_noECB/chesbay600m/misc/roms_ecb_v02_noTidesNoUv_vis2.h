/*
*******************************************************************************
**
** Options for ROMS-ECB.
**
** The CPP flags "CARBON","OXYGEN","BIO_SEDIMENT","DENITRIFICATION",
** should always be activated when using ECB.
**
** Application flag:   ROMS_ECB
** Input script:       roms_*.in
*/

#undef SEDIMENT   /*Activate ROMS' sediment module.     */
#undef ECB        /*Activate ECB biogeochemistry.       */
#undef T_PASSIVE  /*Optional passive Eulerian   tracers.*/
#undef FLOATS     /*Optional passive Lagrangian tracers.*/

/*See https://doi.org/10.1016/j.scitotenv.2021.145157 for info on inorganic sediments.*/
#ifdef   SEDIMENT
# define SUSPLOAD
/* Allow for exchanges of inorganic sediments between the sediment bed and the water column, but
 * enforce time-invariant sediment bed properties for simplicity.*/
# define FREEZE_SEDBED            /*Custom modification inside myroms.org.*/
# define MB_BBL
# undef  SSW_BBL
# ifdef  MB_BBL
#  define REROUTE_DWAVE_TO_DWAVEP /*Custom modification inside myroms.org.*/
#  define MB_CALC_UB
#  define WAVES_HEIGHT
#  define WAVES_BOT_PERIOD
#  define MB_BBL_IMPOSE_MIN_Z0    /*Custom modification inside myroms.org.*/
#  undef  ANA_WWAVE               /*If undefined, read forcing from NetCDF files*/
#  undef  MB_CALC_ZNOT
# endif
# ifdef  SSW_BBL
#  define REROUTE_DWAVE_TO_DWAVEP /*Custom modification inside myroms.org.*/
#  define SSW_CALC_UB             /*Computing bottom orbital velocity internally */
#  define WAVES_HEIGHT
#  define WAVES_BOT_PERIOD
#  undef  ANA_WWAVE               /*If undefined, read forcing from NetCDF files*/
#  undef  SSW_CALC_ZNOT           /*Computing bottom roughness        internally */
#  ifdef SSW_CALC_ZNOT
#   define SSW_ZORIP              /*Bedform roughness from ripples*/
#   define SSW_ZOBL               /*Bedload roughness for  ripples*/
#  endif
# endif
# undef  BEDLOAD_MPM
#endif

/* Basic physics options */
#define UV_ADV
#define UV_COR
#define SOLVE3D
#define SALINITY
#define NONLIN_EOS
#define WET_DRY    /*Activate ROMS wetting-drying.*/

/* Basic numerics options */
#define SINGLE_PRECISION  /*Limit memory usage and exchanges*/
#define OMEGA_IMPLICIT    /*Implicit scheme for vertical advection (Shchepetkin, 2015)*/
#define LIMIT_BSTRESS     /*Prevent unrealistically-high bottom stress.*/
#define DJ_GRADPS
#define MASKING
#define CURVGRID          /*Activates wind rotation.*/
#undef  UV_VIS2           /*Explicit horizontal viscosity.*/
#ifdef  UV_VIS2
# define MIX_S_UV         /*`Horizontal' defined as `along topo-following levels'*/
#endif
#define TS_DIF2           /*Explicit horizontal diffusion of T,S.*/
#ifdef  TS_DIF2
# define MIX_S_TS         /*`Horizontal' defined as `along topo-following levels'*/
# undef  MIX_GEO_TS       /*`Horizontal' defined as `along constant depths'*/
#endif
#undef  SPLINES

/* Surface and bottom boundary conditions */
#define ATM_PRESS
#define LONGWAVE_OUT
#define WIND_MINUS_CURRENT  /*Take into account v_water*/
#define LIMIT_STFLX_COOLING /*Suppress surf. cooling if freezing*/
#define BULK_FLUXES
#define SOLAR_SOURCE
#define EMINUSP
#define UV_LOGDRAG
#undef  UV_QDRAG
#if defined SSW_BBL || defined MB_BBL
# undef UV_QDRAG            /*Conflicts with SSW_BBL.*/
# undef UV_LOGDRAG          /*Conflicts with SSW_BBL.*/
#endif

/* The default myroms.org code allows for saving the *surface* vertical level of 3-D passive tracers
 * into the `Quicksave' outputs, but it does not allow the same for the *bottom* vertical level.
 * CPP `QUICKSAVE_BOTTOM' is a customization that fills that gap.*/
#define QUICKSAVE_BOTTOM /*Custom modification inside myroms.org.*/

#define ANA_BSFLUX  /*Analytical Bottom Salinity    Flux (zero)*/
#define ANA_BTFLUX  /*Analytical Bottom Temperature Flux (zero)*/

#if defined T_PASSIVE || defined SEDIMENT || defined ECB
/* When ANA_?PFLUX is set to #undef, the user must provide flux values inside NetCDF forcing files.
 * Note that these fluxes are introduced during the physical advection-diffusion stage, and thus
 * they are meant to represent additional processes that are not already accounted for by the
 * existing surface/bottom fluxes of ECB (e.g., a prescribed alkalinity flux associated with
 * calcification in a oyster bed). Providing fluxes with zero values for all the tracers is
 * equivalent to setting ANA_?PFLUX to #define.*/
# undef  ANA_SPFLUX  /*Analytical Surface Passive tracer FLUX*/
# undef  ANA_BPFLUX  /*Analytical Bottom  Passive tracer FLUX*/

# if !defined ANA_BPFLUX && defined SEDIMENT
/* For unclear reasons, the myroms.org code is able to read a *surface* flux of sand_xx, but it
 * lacks a block of code allowing it to do the same for a *bottom* flux of sand_xx.
 * `BPFLUX_FROM_FRC_FILES' fills that gap. The CPP flag does the same for biological variables
 * (see the block of code inside ecb_var.h).*/
#  define BPFLUX_FROM_FRC_FILES /*Custom modification inside myroms.org.*/
# endif
#endif

/* Vertical sub-grid scale (SGS) closure */
#define GLS_MIXING
#ifdef  GLS_MIXING
# define KANTHA_CLAYSON
# define N2S2_HORAVG
#endif
#define LIMIT_VDIFF /*Prevent numerical instabilities in SGS scheme.*/
#define LIMIT_VVISC

/* Open boundary condition settings */
#undef  SSH_TIDES
#ifdef  SSH_TIDES
# define RAMP_TIDES
# define ADD_FSOBC
#endif
#undef  UV_TIDES
#ifdef  UV_TIDES
# define ADD_M2OBC
#endif

/* Outputs, Diagnostics outputs */
#define AVERAGES
#define AVERAGES_FLUXES /* Write out surface and bottom average fluxes */
#define STATIONS
#define DIAGNOSTICS /*N.B. This flag affects DIAGNOSTICS_BIO; see below.*/
#ifdef  DIAGNOSTICS
# undef DIAGNOSTICS_TS /*For, e.g., salt_rate, NO3_rate, etc.*/
# undef DIAGNOSTICS_UV
#endif
#define HDF5 /*Activate NetCDF-4 deflation to limit size of output files.*/
#define DEFLATE
#undef  PERFECT_RESTART
#undef  AVERAGES_AKV
#undef  AVERAGES_AKT

#ifdef  ECB              /*If ECB biogeochemistry is activated...*/
# define CARBON          /*Must be defined at all times when using ECB.*/
# define OXYGEN          /*Must be defined at all times when using ECB.*/
# define BIO_SEDIMENT    /*Must be defined at all times when using ECB.*/
# define DENITRIFICATION /*Must be defined at all times when using ECB.*/

/*If MASK_SURFBOTT_BGC_FLUXES_IF_DRY is set to #define, a safeguard is introduced inside
 *  pre_step3d.F to guarantee that the surface/bottom biogeochemical fluxes are zero while a grid
 *  cell is dry. The ROMS developers already had similar safeguards for salinity/temperature but
 *  it's unclear if it extended beyond that. This option specifically targets biogeochemical fluxes
 *  prescribed inside input forcing files (notably atmospheric nitrogen deposition) since they are
 *  defined throughout the model domain regardless of the state of a grid cell (wet or dry). Note
 *  that the surface/bottom fluxes computed by ECB are already masked depending on wet/dry and thus
 *  are not of concern.*/
# define MASK_SURFBOTT_BGC_FLUXES_IF_DRY /*Custom modification inside myroms.org*/

/*If MASK_WETLANDS_SAV is set to #define, then the d/dt equations of ECB and the bottom/surface
 *  fluxes computed by ECB are set to zero inside wetlands/SAV. This modification is implemented at
 *  the very end of ecb.h (rather than throughout the code), just before the line:
 *    t(i,j,k,nnew,ibio)=t(i,j,k,nnew,ibio)+cff*Hz(i,j,k)
 *  This CPP option allows the user to prescribe what the biogeochemical sinks/sources should be
 *  inside wetlands/SAV beds (based on input forcing files of bottom or surface fluxes) without
 *  having ECB interfering.*/
# undef  MASK_WETLANDS_SAV /*Custom modification inside myroms.org*/

/*Use inorganic sediment concentrations in the calculation of light attenuation with depth. The
 * option requires SEDIMENT to be defined as well as NNS > 1.*/
# define SANDS_PROXY_ISS

# define RW14_OXYGEN_SC  /*Wanninkhof 2014 coefficients.*/
# define RW14_CO2_SC
# define TALK_NONCONSERV /*Add sinks/sources of alkalinity.            */
# define PCO2AIR_DATA    /*Eq.1 from https://doi.org/10.5194/bg-17-3779-2020*/
# define pCO2_RZ         /*Carbonate system  routines by Zeebe and Wolf-Gladrow (2001)*/
# ifdef  pCO2_RZ
#  undef  ORGANIC_ALK_CHALK_BAYWIDE /*Remove organic alkalinity; York OR Potomac OR Bay-wide*/
#  undef  ORGANIC_ALK_CHALK_YORK    /*Remove organic alkalinity; York OR Potomac OR Bay-wide*/
#  undef  ORGANIC_ALK_CHALK_POTOMAC /*Remove organic alkalinity; York OR Potomac OR Bay-wide*/
#  undef  GAS_TRANSFER_VELOCITY_HO2016 /*Overwrite the Wanninkhof velocity with Ho et al. 2016.*/
#  define pCO2_RZ_CAIWANG_1998 /*Either Cai&Wang OR Millero.*/
#  undef  pCO2_RZ_MILLERO_2010 /*Either Cai&Wang OR Millero.*/
# endif

/*Treat chlorophyll as a purely diagnostic variable, and derive it from phytoplankton using the
 * empirical carbon-to-chlorophyll ratio of Cerco & Noel 2004 (a function of diffuse light
 * attenuation).*/
# define CHLA_AS_A_DIAGNOSTIC

/*Net sulfate reduction inside sediments; see https://doi.org/10.1007/s12237-024-01421-z */
# undef  NET_SULFATE_REDUCTION

/*PO4 limitation on phyto growth; https://doi.org/10.5194/bg-9-4707-2012 */
# undef  PO4

# undef  CHEM_ENHANCEMENT_CO2_AIR_SEA_FLUX /*E.g. Wanninkhof & Knox 1996*/

# if defined DIAGNOSTICS
#  define DIAGNOSTICS_BIO
# endif
#endif
