%This is a simulation to model a video found to do stacked loops such as a
%solenoid found at 
%https://www.youtube.com/watch?v=mJfdboA4iME&ab_channel=KurtOwen
clear
clf
%%set parameters
I=1.0; %[Amps]
u0=4*pi*10^(-7); %permability
%%note R0 will need to be iterated to solve for various layers
R0=0.01; %line length meters
nR=50; %number of segments

%%graph window
xmin=-0.02;
xmax=0.02;
ymin=xmin;
ymax=xmax;
zmin=xmin;
zmax=xmax;
dx=0.005; %step size for grid

nloops=16; %number of loops [per layer]
spacing=.8*(zmax-zmin)/nloops; %will be swaped for wire parameter spacing
zlow=-0.5*((nloops-1)*spacing);

%%initialize vectors
theta=linspace(0,2*pi,nR+1);
Rx=R0*cos(theta); %x points on loops by radius
Ry=R0*sin(theta); %y points on loops by radius
Rz=zlow*ones(1,nR+1); 

Points=transpose([Rx;Ry;Rz]); 

x=xmin:dx:xmax;
y=ymin:dx:ymax;
z=zmin:dx:zmax;

[X,Y,Z]=meshgrid(x,y,z); %creates 3d grid

%%calculations
Bx=zeros(size(x));
By=zeros(size(y));
Bz=zeros(size(z));
for jt=1:nloops %for number of turns per layer
    for it=1:nR
        Rx=X-Points(it,1);
        Ry=Y-Points(it,2);
        Rz=Z-Points(it,3);

        R=sqrt(Rx.^2+Ry.^2+Rz.^2); %overall distance to point
        R=R.*(R>=dx)+dx*(R<dx); %rounding for step size

        dLx=Points(it+1,1)-Points(it,1);
        dLy=Points(it+1,2)-Points(it,2);
        dLz=0;

        %components at each point by biot-savart law
        Bx=Bx+u0*I/(4*pi)*(dLy.*Rz-dLz.*Ry).*R.^(-3);
        By=By+u0*I/(4*pi)*(dLz.*Rx-dLx.*Rz).*R.^(-3);
        Bz=Bz+u0*I/(4*pi)*(dLx.*Ry-dLy.*Rx).*R.^(-3);
    end
    plot3(Points(:,1),Points(:,2),Points(:,3),'-K')
    axis([xmin xmax ymin ymax zmin zmax])
    hold on
    quiver3([-1.1*R0,1,1*R0],[.2*R0,-.2R0])
end
quiver3(X,Y,Z, Bx,By,Bz,'b')
hold off
rotate3d on

xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')
view(-30,15)
title('b-field visualization')