'''
Description: combine initial condition of salt, temp, and u, v from source glorys12v1 using rep roms_matlab.
Author: Ligang Chen
Date created: 06/23/2026
Date last modified: 06/23/2026 
'''


import os
import sys
import glob
import datetime
import calendar
# import warnings

import numpy as np
import xarray as xr
import scipy
import pandas as pd
# import seaborn as sns

# import matplotlib.pyplot as plt


DIR_MAIN = '/glade/u/home/lgchen/ChesROMS/ChesROMS_UMD/myscript'
FN_INI_TS = 'ini_ChesROMS-UMD_fromGlorys12v1_1993-12-31_v01_ts.nc'
FN_INI_UV = 'ini_ChesROMS-UMD_fromGlorys12v1_1993-12-31_v02_uv.nc'

ds_uv = xr.open_dataset(filename_or_obj=DIR_MAIN + "/" + FN_INI_UV, mask_and_scale=True)
ds_ts = xr.open_dataset(filename_or_obj=DIR_MAIN + "/" + FN_INI_TS, mask_and_scale=True)

ds_uv['temp'].data = ds_ts['temp'].data
ds_uv['salt'].data = ds_ts['salt'].data

lst_var = ['zeta', 'ubar', 'vbar', 'u', 'v', 'temp', 'salt']
FillValue = 1.e+37
for var in lst_var:
    ds_uv[var].data = xr.where(ds_uv[var].data == 0, FillValue, ds_uv[var].data)
    ds_uv[var].data = xr.where(np.isnan(ds_uv[var].data), FillValue, ds_uv[var].data)
    ds_uv[var].encoding['_FillValue'] = FillValue

ds_uv.to_netcdf('./ini_ChesROMS-UMD_fromGlorys12v1_1993-12-31_v03.nc')

