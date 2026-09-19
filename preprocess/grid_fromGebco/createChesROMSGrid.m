%% Step 1: Clone and add roms_matlab
addpath(genpath('/glade/u/home/lgchen/lgchen_work/bin/ChesROMS/roms_matlab'))
addpath(genpath('/glade/u/home/lgchen/lgchen_work/bin/ChesROMS/myscript'))

%% Step 2: Define domain
lon_min=-77.4;
lon_max=-74.0;

lat_min=35.2;
lat_max=39.7;

dx=600;
dy=600;


%% Step 3: Set UTM 18N projection
utmstruct=defaultm('utm');
utmstruct.zone='18N';
utmstruct.geoid=wgs84Ellipsoid('meter');
utmstruct=defaultm(utmstruct);

%% Convert boundary to projected meters:
lonc=[lon_min lon_max lon_min lon_max];
latc=[lat_min lat_min lat_max lat_max];

[xc,yc]=mfwdtran(utmstruct,latc,lonc); % xc[4], yc[4]

xmin=min(xc); xmax=max(xc);
ymin=min(yc); ymax=max(yc);

% Domain center:
Xc=.5*(xmin+xmax); % = 4.3627e+5
Yc=.5*(ymin+ymax); % = 4.1464e+6


%% Step 5: Define grid size
% Remember cartesian_grid uses psi-point counts:
Im=round((xmax-xmin)/dx);  % 516, psi count in xi direction
Jm=round((ymax-ymin)/dy);  % 836, psi count in eta direction

Theta=0;
Lplt=false;

% Then expected dimensions:
%eta_rho = Jm + 1;
%xi_rho  = Im + 1;

%eta_u = Jm + 1;
%xi_u  = Im;

%eta_v = Jm;
%xi_v  = Im + 1;

%eta_psi = Jm;
%xi_psi  = Im;


%% Step 6: Generate Cartesian grid
% If needed use rotate_cartesian depending on your repo version
% R=cartesian_grid([],Im,Jm,dx,dy,Xc,Yc,Theta,Lplt);
R=rotate_cartesian([],Im,Jm,dx,dy,Xc,Yc,Theta,Lplt);
% Reset metric if desired:
%R.pm=ones(size(R.x_rho))/dx;
%R.pn=ones(size(R.x_rho))/dy;


%% Step 7: Convert projected coordinates x/y back to lon/lat
[lat_rho,lon_rho]= minvtran(utmstruct,R.x_rho,R.y_rho);
[lat_u,lon_u]= minvtran(utmstruct,R.x_u,R.y_u);
[lat_v,lon_v]= minvtran(utmstruct,R.x_v,R.y_v);
[lat_psi,lon_psi]= minvtran(utmstruct,R.x_psi,R.y_psi);


%% Step 7: Create ROMS grid NetCDF skeleton
Gname='chesapeake_600m_utm18n.nc';
%[Mp,Lp]=size(lon_rho);  % [518, 838] [x, y]
[Lp,Mp]=size(lon_rho);  % [518, 838] [x, y]
status=c_grid(Lp,Mp,Gname,true,true);

% now check
ncinfo(Gname,'lon_rho').Size
ncinfo(Gname,'lon_u').Size
ncinfo(Gname,'lon_v').Size
ncinfo(Gname,'lon_psi').Size
% expected:
%lon_rho : [Mp,   Lp]
%lon_u   : [Mp,   Lp-1]
%lon_v   : [Mp-1, Lp]
%lon_psi : [Mp-1, Lp-1]


%% Verify dimensions before bathymetry, they should match
disp(size(lon_rho))
disp(size(lon_u))
disp(size(lon_v))
disp(size(lon_psi))

disp(ncinfo(Gname,'lon_rho').Size)
disp(ncinfo(Gname,'lon_u').Size)
disp(ncinfo(Gname,'lon_v').Size)
disp(ncinfo(Gname,'lon_psi').Size)


%% Step : Read GEBCO bathymetry
B='/glade/u/home/lgchen/lgchen_work/bin/ChesROMS/myscript/gebco_2025_n41.0_s34.0_w-79.0_e-73.0.nc';
blon=ncread(B,'lon');
blat=ncread(B,'lat');
z=ncread(B,'elevation')';
% Convert to positive depth
depth=-double(z);
depth(depth<0)=0;

% Interpolate
F=griddedInterpolant({blat,blon},depth,'linear','nearest');

h=F(lat_rho,lon_rho);

% Build mask FIRST
mask_rho=ones(size(h));  % 1 being water
mask_rho(h<=0)=0;        % 0 being land

% Enforce minimum wet depth
%hmin=5;
hmin=0.750777  % from VIMS grid
h(h>0 & h<hmin)=hmin;
h(mask_rho==0)=hmin;


%% Step 9: Compute staggered masks
% wrong, mask_u and mask_v size mismatch
%mask_u=mask_rho(:,1:end-1).*mask_rho(:,2:end);
%mask_v=mask_rho(1:end-1,:).*mask_rho(2:end,:);
%mask_psi=mask_rho(1:end-1,1:end-1).*...
%    mask_rho(1:end-1,2:end).*...
%    mask_rho(2:end,1:end-1).*...
%    mask_rho(2:end,2:end);

mask_u = mask_rho(1:end-1,:) .* mask_rho(2:end,:);
mask_v = mask_rho(:,1:end-1) .* mask_rho(:,2:end);
mask_psi = mask_rho(1:end-1,1:end-1) .* ...
           mask_rho(2:end,1:end-1)   .* ...
           mask_rho(1:end-1,2:end)   .* ...
           mask_rho(2:end,2:end);

disp(size(mask_rho))
disp(size(mask_u))
disp(size(mask_v))
disp(size(mask_psi))

disp(ncinfo(Gname,'mask_rho').Size)
disp(ncinfo(Gname,'mask_u').Size)
disp(ncinfo(Gname,'mask_v').Size)
disp(ncinfo(Gname,'mask_psi').Size)


%% calculate f which is the Coriolis parameter at RHO-points
Omega = 7.2921159e-5;  % Earth rotation rate, rad/s
f = 2 * Omega * sin(deg2rad(lat_rho));


%% displace x_rho, y_pho, x_psi, y_psi, x_u, y_u, x_v, y_v to the origin as VIMS
% not sure if it's necessary
R.x_rho = R.x_rho - (R.x_rho(1, 1) + 300)  % so it starts at -300
R.y_rho = R.y_rho - (R.y_rho(1, 1) + 300)
R.x_psi = R.x_psi - (R.x_psi(1, 1) - 0)  % so it starts at 0
R.y_psi = R.y_psi - (R.y_psi(1, 1) - 0)
R.x_u = R.x_u - (R.x_u(1, 1) - 0)  % so it starts at 0
R.y_u = R.y_u - (R.y_u(1, 1) + 300)
R.x_v = R.x_v - (R.x_v(1, 1) + 300)  % so it starts at -300
R.y_v = R.y_v - (R.y_v(1, 1) - 0)


%% Step : Check bathymetry roughness and smooth
% try for rx0 <= 0.2; 
% If too rough, smooth with your own iterative rx0 smoother.
%rx_x=abs(diff(h,1,2))./(h(:,2:end)+h(:,1:end-1));
%rx_y=abs(diff(h,1,1))./(h(2:end,:)+h(1:end-1,:));
%rx0=max([rx_x(:);rx_y(:)])  % 0.9224, too large

rx0max = 0.2;
niter = 500;

rx0_before = calc_rx0(h, mask_rho)

h_smooth = smooth_rx0(h, mask_rho, rx0max, niter);

rx0_after = calc_rx0(h_smooth, mask_rho)

%ncwrite(Gname,'h',h_smooth)


%% Step 11: Write grid variables
ncwrite(Gname,'spherical',1)
ncwrite(Gname,'xl',dx*Im)
ncwrite(Gname,'el',dx*Jm)

ncwrite(Gname,'lon_rho',lon_rho)
ncwrite(Gname,'lat_rho',lat_rho)

ncwrite(Gname,'lon_u',lon_u)
ncwrite(Gname,'lat_u',lat_u)

ncwrite(Gname,'lon_v',lon_v)
ncwrite(Gname,'lat_v',lat_v)

ncwrite(Gname,'lon_psi',lon_psi)
ncwrite(Gname,'lat_psi',lat_psi)

ncwrite(Gname,'x_rho',R.x_rho)
ncwrite(Gname,'y_rho',R.y_rho)

ncwrite(Gname,'x_u',R.x_u)
ncwrite(Gname,'y_u',R.y_u)

ncwrite(Gname,'x_v',R.x_v)
ncwrite(Gname,'y_v',R.y_v)

ncwrite(Gname,'x_psi',R.x_psi)
ncwrite(Gname,'y_psi',R.y_psi)

%ncwrite(Gname,'f',zeros(ncinfo(Gname,'dndx').Size))
ncwrite(Gname,'f',f)
ncwrite(Gname,'angle',R.angle)
ncwrite(Gname,'pm',(1./600)*ones(size(R.pm))) % or 1 ./ R.pm, element-wise reciprocal
ncwrite(Gname,'pn',(1./600)*ones(size(R.pn))) % or 1 ./ R.pn, 

ncwrite(Gname,'dndx',zeros(ncinfo(Gname,'dndx').Size))
ncwrite(Gname,'dmde',zeros(ncinfo(Gname,'dmde').Size))

%ncwrite(Gname,'h',h)
ncwrite(Gname,'h',h_smooth)

ncwrite(Gname,'mask_rho',mask_rho)
ncwrite(Gname,'mask_u',mask_u)
ncwrite(Gname,'mask_v',mask_v)
ncwrite(Gname,'mask_psi',mask_psi)




%% helper functions
% smooth bathymetry roughness (i.e. h) to satisfy rx0
function h = smooth_rx0(h, mask_rho, rx0max, niter)

factor = (1+rx0max)/(1-rx0max)

for iter = 1:niter
    h_old = h;

    % xi-direction neighbors
    for j = 1:size(h,1)
        for i = 1:size(h,2)-1
            if mask_rho(j,i)==1 && mask_rho(j,i+1)==1
                h1 = h(j,i);
                h2 = h(j,i+1);
                r = abs(h2-h1)/(h2+h1);
                if r > rx0max
                    if h2 > h1
                        h(j,i+1) = h1*factor;
                    else
                        h(j,i) = h2*factor;
                    end
                end

            end
        end
    end

    % eta-direction neighbors
    for j = 1:size(h,1)-1
        for i = 1:size(h,2)
            if mask_rho(j,i)==1 && mask_rho(j+1,i)==1
                h1 = h(j,i);
                h2 = h(j+1,i);
                r = abs(h2-h1)/(h2+h1);

                if r > rx0max
                    if h2 > h1
                        h(j+1,i) = h1*factor;
                    else
                        h(j,i) = h2*factor;
                    end
                end

            end
        end
    end

    change = max(abs(h(:)-h_old(:)));
    rx0_now = calc_rx0(h, mask_rho);
    fprintf('iter %4d: rx0 = %.4f, max dh = %.6f\n', iter, rx0_now, change);

    if rx0_now <= rx0max
        break
    end

    if change < 1.0e-6
        break
    end
end

end




function rx0 = calc_rx0(h, mask_rho)

rx = [];

% xi-direction
h1 = h(:,1:end-1);
h2 = h(:,2:end);

m1 = mask_rho(:,1:end-1);
m2 = mask_rho(:,2:end);

wet = (m1==1 & m2==1);

r = abs(h2-h1)./(h2+h1);
rx = [rx; r(wet)];

% eta-direction
h1 = h(1:end-1,:);
h2 = h(2:end,:);

m1 = mask_rho(1:end-1,:);
m2 = mask_rho(2:end,:);

wet = (m1==1 & m2==1);

r = abs(h2-h1)./(h2+h1);
rx = [rx; r(wet)];

rx0 = max(rx);

end




%%
