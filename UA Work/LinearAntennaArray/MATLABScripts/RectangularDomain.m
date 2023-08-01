function [points,ax] = RectangularDomain(x_dim,y_dim,z_dim,n_pts)
%RECTANGULARDOMAIN Generates imaging domain for linear antenna array
%   Inputs:
%       -> x_dim:       total x distance
%       -> y_dim:       dist between antennas
%       -> z_dim:       vertical dimension
%   Outputs:
%       <- points:  points in imaging domain
%       <- axes:    axes for domain
xmin = -x_dim/2;
xmax = x_dim/2;
ymin = -y_dim/2;
ymax = y_dim/2;
zmin = 0;
zmax = z_dim;

dx = (xmax-xmin)/(n_pts-1);
dy = (ymax-ymin)/(n_pts-1);
dz = (zmax-zmin)/(n_pts-1);

X0 = xmin:dx:xmax;
Y0 = ymin:dy:ymax;
Z0 = zmin:dz:zmax;

X = [];
Y = [];
Z = [];

for m = 1:length(Z0)
    z = Z0(m);
    for n = 1:length(Y0)
        y = Y0(n);
        X = cat(2,X,X0);
        Y = cat(2,Y,y*ones(size(X0)));
        Z = cat(2,Z,z*ones(size(X0)));
    end
end
X = X';
Y = Y';
Z = Z';

ax = {X0,Y0,Z0};
points = cat(2,X,Y,Z);
end

