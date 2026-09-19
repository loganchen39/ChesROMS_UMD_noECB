%
%  D_MERCATOR2ROMS:  Driver script to create a ROMS initial conditions
%
%  This a user modifiable script that can be used to prepare ROMS
%  initial conditions NetCDF file from Mercator dataset. It sets-up
%  all the necessary parameters and variables. USERS can use this
%  as a prototype for their application.
%

% svn $Id$
%=========================================================================%
%  Copyright (c) 2002-2025 The ROMS Group                                 %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.md                            Hernan G. Arango      %
%=========================================================================%

% Set file names.

%OPR_Dir = '/home/arango/ocean/toms/repository/Projects/philex/Mercator/OPR';
%RTR_Dir = '/home/arango/ocean/toms/repository/Projects/philex/Mercator/RTR';
glorys_dir = '/glade/u/home/lgchen/ChesROMS/ChesROMS_UMD/data/glorys12v1/initial';

%Tfile = 'ext-PSY3V2R2_1dAV_20070101_20070102_gridT_R20070110.nc.gz';
%Ufile = 'ext-PSY3V2R2_1dAV_20070101_20070102_gridU_R20070110.nc.gz';
%Vfile = 'ext-PSY3V2R2_1dAV_20070101_20070102_gridV_R20070110.nc.gz';
fn_glorys_ini = 'mercatorglorys12v1_gl12_mean_19931231_R19940105.nc';

%GRDname = 'philex_grd_b.nc';
%INIname = 'philex_ini_mercator_b.nc';
%GRDname = '/glade/u/home/lgchen/ChesROMS/ChesROMS_UMD/myscript/grid_UMD.nc';
GRDname = '/glade/u/home/lgchen/ChesROMS/ChesROMS_UMD/preprocess/grid/grid_UMD.nc';
%INIname = '/glade/u/home/lgchen/ChesROMS/ChesROMS_UMD/myscript/ini_ChesROMS-UMD_fromGlorys12v1_1993-12-31_v02_uv.nc';
%INIname = '/glade/u/home/lgchen/ChesROMS/ChesROMS_UMD/preprocess/initial/ini_ChesROMS-UMD_fromGlorys12v1_1993-12-31_v04_uv.nc';
INIname = '/glade/u/home/lgchen/ChesROMS/ChesROMS_UMD/preprocess/initial/ini_ChesROMS-UMD_fromGlorys12v1_1993-12-31_v04_ts.nc';

addpath(genpath('/glade/u/home/lgchen/lgchen_work/bin/ChesROMS/roms_matlab'));

CREATE = true;                   % logical switch to create NetCDF
report = false;                  % report vertical grid information

% Get number of grid points.

[Lr,Mr]=size(ncread(GRDname,'h'));

Lu = Lr-1;   Lv = Lr;
Mu = Mr;     Mv = Mr-1;

%--------------------------------------------------------------------------
%  Create initial conditions NetCDF file.
%--------------------------------------------------------------------------

% Set full path of Mercator files assigned as initial conditions.

%fileT=fullfile(RTR_Dir,Tfile); lenT=length(fileT)-3;
%fileU=fullfile(RTR_Dir,Ufile); lenU=length(fileU)-3;
%fileV=fullfile(RTR_Dir,Vfile); lenV=length(fileV)-3;

%--------------------------------------------------------------------------
%  Set application parameters in structure array, S.
%--------------------------------------------------------------------------

S.ncname      = INIname;     % output NetCDF file

S.spherical   = 1;           % spherical grid

S.Lm          = Lr-2;        % number of interior RHO-points, X-direction
S.Mm          = Mr-2;        % number of interior RHO-points, Y-direction
%S.N           = 42;          % number of vertical levels at RHO-points
S.N           = 20;          % number of vertical levels at RHO-points
S.NT          = 2;           % total number of tracers

S.Vtransform  = 2;           % vertical transfomation equation
%S.Vstretching = 2;           % vertical stretching function
S.Vstretching = 4;           % vertical stretching function

%S.theta_s     = 7.0;         % S-coordinate surface control parameter
%S.theta_b     = 0.1;         % S-coordinate bottom control parameter
%S.Tcline      = 150.0;       % S-coordinate surface/bottom stretching width
S.theta_s     = 6.0;         % S-coordinate surface control parameter
S.theta_b     = 1.0;         % S-coordinate bottom control parameter
S.Tcline      = 10.0;       % S-coordinate surface/bottom stretching width
S.hc          = S.Tcline;    % S-coordinate stretching width

%--------------------------------------------------------------------------
%  Set grid variables.
%--------------------------------------------------------------------------

S.h           = ncread(GRDname, 'h');            % bathymetry

S.lon_rho     = ncread(GRDname, 'lon_rho');      % RHO-longitude
S.lat_rho     = ncread(GRDname, 'lat_rho');      % RHO-latitude

S.lon_u       = ncread(GRDname, 'lon_u');        % U-longitude
S.lat_u       = ncread(GRDname, 'lat_u');        % U-latitude

S.lon_v       = ncread(GRDname, 'lon_v');        % V-longitude
S.lat_v       = ncread(GRDname, 'lat_v');        % V-latitude

S.mask_rho    = ncread(GRDname, 'mask_rho');     % RHO-mask
S.mask_u      = ncread(GRDname, 'mask_u');       % U-mask
S.mask_v      = ncread(GRDname, 'mask_v');       % V-mask

S.angle       = ncread(GRDname, 'angle');        % curvilinear angle

%  Set vertical grid variables.

kgrid=0;                                          % RHO-points

[S.s_rho, S.Cs_r]=stretching(S.Vstretching, ...
                             S.theta_s, S.theta_b, S.hc, S.N,         ...
                             kgrid, report);

kgrid=1;                                          % W-points			 

[S.s_w,   S.Cs_w]=stretching(S.Vstretching, ...
                             S.theta_s, S.theta_b, S.hc, S.N,         ...
                             kgrid, report);


%--------------------------------------------------------------------------
%  Interpolate initial conditions from Mercator data to application grid.
%--------------------------------------------------------------------------

disp(' ')
disp(['Interpolating from Mercator to ROMS grid ...']);
disp(' ')

%  Uncompress input Mercator files.

%s=unix(['gunzip ',fileT]);
%s=unix(['gunzip ',fileU]);
%s=unix(['gunzip ',fileV]);

abs_fn_glorys_ini = fullfile(glorys_dir, fn_glorys_ini);

%  Read Mercator data has a time coordinate counter (seconds) that
%  starts on 11-Oct-2006.
%time=nc_read(fileT(1:lenT),'time_counter');
%mydate=datestr(datenum('11-Oct-2006')+time/86400-0.5,0);

time=nc_read(abs_fn_glorys_ini,'time');
mydate=datestr(datenum('01-Jan-1950')+time/24,0);

disp([ '    Processing: ', mydate]);
disp(' ')
  
%  Get Mercator grid.

Tlon=nc_read(abs_fn_glorys_ini,'longitude');
Tlat=nc_read(abs_fn_glorys_ini,'latitude');
Tdepth=nc_read(abs_fn_glorys_ini,'depth');

Ulon=nc_read(abs_fn_glorys_ini,'longitude');
Ulat=nc_read(abs_fn_glorys_ini,'latitude');
Udepth=nc_read(abs_fn_glorys_ini,'depth');

Vlon=nc_read(abs_fn_glorys_ini,'longitude');
Vlat=nc_read(abs_fn_glorys_ini,'latitude');
Vdepth=nc_read(abs_fn_glorys_ini,'depth');

%  In the western Pacific, the level 50 (z=5727.9 m) of the Mercator data
%  is all zeros. Our grid needs depth of Zr=-5920 m.  Therefore, the depths
%  are modified in level 49 (z=5274.7 m) to bound the vertical interpolation.

Tdepth(49)=6000; Udepth(49)=6000; Vdepth(49)=6000;
Tdepth(50)=6100; Udepth(50)=6100; Vdepth(50)=6100;


%  Read in initial conditions fields.

Zeta=nc_read(abs_fn_glorys_ini,'zos');
Temp=nc_read(abs_fn_glorys_ini,'thetao');
Salt=nc_read(abs_fn_glorys_ini,'so');
Uvel=nc_read(abs_fn_glorys_ini,'uo');
Vvel=nc_read(abs_fn_glorys_ini,'vo');

disp('Temp: ');
disp(size(Temp)); % (4320, 2041, 50), not the original (1, 50, 2041, 4320)
%v = squeeze(Temp(:,1000,1));
%disp(v);


%  Determine Mercator Land/Sea mask.  Since Mercator is a Z-level
%  model, the mask is 3D.

Rmask3d=ones(size(Temp));
ind=find(Temp == 0);
Rmask3d(ind)=0;

disp('Rmask3d');
disp(size(Rmask3d));
%v = squeeze(Rmask3d(:, 1000, 1));
%disp(v);

clear ind


[Tlon_2d, Tlat_2d] = ndgrid(Tlon, Tlat);
[Ulon_2d, Ulat_2d] = ndgrid(Ulon, Ulat);
[Vlon_2d, Vlat_2d] = ndgrid(Vlon, Vlat);
disp('Tlon_2d');
disp(size(Tlon_2d));

%  Compress input Mercator files.

%s=unix(['gzip ',fileT(1:lenT)]);
%s=unix(['gzip ',fileU(1:lenU)]);
%s=unix(['gzip ',fileV(1:lenV)]);

%  Set initial conditions time (seconds). The time coordinate for this
%  ROMS application is "seconds since 2007-01-01 00:00:00". The 0.5
%  coefficient here is to account Mecator daily average.

%MyTime=time/86400-(datenum('1-Jan-2007')-datenum('11-Oct-2006'))-0.5;

%S.ocean_time = MyTime*86400;
%S.ocean_time = 86400;               % set to Jan 1, because of forcing

%hours since 1950-01-01, same as the original glorys data 
%so no conversion needed; 
 S.ocean_time = time; 

%  Interpolate free-surface initial conditions.

zeta=mercator2roms('zeta',S,Zeta,Tlon_2d,Tlat_2d,Rmask3d(:,:,1));

%  Compute ROMS model depths.  Ignore free-sruface contribution
%  so interpolation is bounded below mean sea level.

ssh=zeros(size(zeta));

igrid=1;
[S.z_r]=set_depth(S.Vtransform, S.Vstretching,                        ...
                  S.theta_s, S.theta_b, S.hc, S.N,                    ...
		  igrid, S.h, ssh, report);
	      
igrid=3;
[S.z_u]=set_depth(S.Vtransform, S.Vstretching,                        ...
                  S.theta_s, S.theta_b, S.hc, S.N,                    ...
		  igrid, S.h, ssh, report);

igrid=4;
[S.z_v]=set_depth(S.Vtransform, S.Vstretching,                        ...
                  S.theta_s, S.theta_b, S.hc, S.N,                    ...
		  igrid, S.h, ssh, report);

%  Compute ROMS vertical level thicknesses (m).
	      
N=S.N;
igrid=5;
[S.z_w]=set_depth(S.Vtransform, S.Vstretching,                        ...
                  S.theta_s, S.theta_b, S.hc, S.N,                    ...
		  igrid, S.h, zeta, report);

S.Hz=S.z_w(:,:,2:N+1)-S.z_w(:,:,1:N);


%  Interpolate temperature and salinity.
disp('before interpolating temp ...');
temp=mercator2roms('temp',S,Temp,Tlon_2d,Tlat_2d,Rmask3d,Tdepth);

disp('before interpolating salt ...');
salt=mercator2roms('salt',S,Salt,Tlon_2d,Tlat_2d,Rmask3d,Tdepth);


% Interpolate uv
%disp('before interpolating Urho ...');
%Urho=mercator2roms('u'   ,S,Uvel,Ulon_2d,Ulat_2d,Rmask3d,Udepth);
%disp('before interpolating Vrho ...');
%Vrho=mercator2roms('v'   ,S,Vvel,Vlon_2d,Vlat_2d,Rmask3d,Vdepth);

%  Process velocity: rotate and/or average to staggered C-grid locations.
%[u,v]=roms_vectors(Urho,Vrho,S.angle,S.mask_u,S.mask_v);

%  Compute barotropic velocities by vertically integrating (u,v).
%[ubar,vbar]=uv_barotropic(u,v,S.Hz);


%--------------------------------------------------------------------------
%  Create initial condition Netcdf file.
%--------------------------------------------------------------------------

if (CREATE),
  [status]=c_initial(S);

%  Set attributes for "ocean_time".

 %avalue='seconds since 2007-01-01 00:00:00';
  avalue='hours since 1950-01-01 00:00:00'; % units from glorys12v1
  [status]=nc_attadd(INIname,'units',avalue,'ocean_time');
  
  avalue='gregorian';
  [status]=nc_attadd(INIname,'calendar',avalue,'ocean_time');

%  Set global attributes.

 %avalue='Philippine Archipelago Straits, ~5.5 km resolution, Grid b';
  avalue='Chesapeake bay and Delaware bay';
  [status]=nc_attadd(INIname,'title',avalue);

  avalue='Mercator system PSY3V2 daily average, 0.25 degree resolution';
  avalue='Glorys12v1';
  [status]=nc_attadd(INIname,'data_source',avalue);

  [status]=nc_attadd(INIname,'grd_file',GRDname);
end,

%--------------------------------------------------------------------------
%  Write out initial conditions.
%--------------------------------------------------------------------------

if (CREATE),
  disp(' ')
  disp([ 'Writing initial conditions ...']);
  disp(' ')

  [status]=nc_write(INIname, 'spherical',   S.spherical);
  [status]=nc_write(INIname, 'Vtransform',  S.Vtransform);
  [status]=nc_write(INIname, 'Vstretching', S.Vstretching);
  [status]=nc_write(INIname, 'theta_s',     S.theta_s);
  [status]=nc_write(INIname, 'theta_b',     S.theta_b);
  [status]=nc_write(INIname, 'Tcline',      S.Tcline);
  [status]=nc_write(INIname, 'hc',          S.hc);
  [status]=nc_write(INIname, 's_rho',       S.s_rho);
  [status]=nc_write(INIname, 's_w',         S.s_w);
  [status]=nc_write(INIname, 'Cs_r',        S.Cs_r);
  [status]=nc_write(INIname, 'Cs_w',        S.Cs_w);

  [status]=nc_write(INIname, 'h',           S.h);
  [status]=nc_write(INIname, 'lon_rho',     S.lon_rho);
  [status]=nc_write(INIname, 'lat_rho',     S.lat_rho);
  [status]=nc_write(INIname, 'lon_u',       S.lon_u);
  [status]=nc_write(INIname, 'lat_u',       S.lat_u);
  [status]=nc_write(INIname, 'lon_v',       S.lon_v);
  [status]=nc_write(INIname, 'lat_v',       S.lat_v);
  
  IniRec = 1;

  [status]=nc_write(INIname, 'ocean_time', S.ocean_time, IniRec);

  [status]=nc_write(INIname, 'zeta', zeta, IniRec);
  %[status]=nc_write(INIname, 'ubar', ubar, IniRec);
  %[status]=nc_write(INIname, 'vbar', vbar, IniRec);
  %[status]=nc_write(INIname, 'u',    u,    IniRec);
  %[status]=nc_write(INIname, 'v',    v,    IniRec);
  [status]=nc_write(INIname, 'temp', temp, IniRec);
  [status]=nc_write(INIname, 'salt', salt, IniRec);
end,

%--------------------------------------------------------------------------
%  Set masking indices to facilitate plotting.  They can be used to
%  replace ROMS Land/Sea mask with NaNs.
%--------------------------------------------------------------------------

inr2d=find(S.mask_rho == 0);
inr3d=find(repmat(S.mask_rho,[1,1,N]) == 0);
