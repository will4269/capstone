clear all
close all
%%Graph parameters {}
xmin=-0.1;
xmax=0.1;
ymin=xmin;
ymax=xmax;
zmin=xmin;
zmax=xmax;

%%inputs
u0=4*pi*10^(-7); %permability
AWG=16;
AWG_d=0.005*92^((36-AWG)/39); %diameter [inches]
insul_thick=0.001; %insulation thickness [inches]
Current=30.0; %[amps]
R0=0.25; %radius to outside of barrel [inches]
num_L=1; %number of Layers
num_T=1; %number of Turns overall
segments=50; %points per loop
dx=0.01; %B field step size
%b field calculated by radius of each loop

% %%Projectile inputs
% R_B=0.25; %[inches] radius of projectile
% Length_B=3.25; %[inches] length of projectile
% density_B=0.255; %[lb/in^3] of projectile
% Off_B=0; %[inches] projectile offset from solenoid
% surface_points=20; %must be able to become an XxX matrix
% %Magnetic moment of iron
% m_B=4.89; %Bohr's Magneton [Joules/Tesla]



%%calculations
%spacing is determined initally to be a wire diameter + 2 insul thick
spacing=(AWG_d+2*insul_thick)*(25.4/1000); %[inches->m]
%zmax=0.0+spacing*num_T/num_L-zmin;
%%determine circumferences
%circumferences=zeros(1,num_L)
radii=zeros(1,num_L);
radii(1,1)=(R0+insul_thick+AWG_d/2)*(25.4/1000);
%circumferences(1,1)=2*pi*(R0+insul_thick+AWG_d/2)
for n=2:num_L
    radii(1,n)=(R0+insul_thick+AWG_d/2+2*(insul_thick+AWG_d/2)*(n-1))*(25.4/1000);
    %circumferences(1,n)=2*pi*(R0+insul_thick+AWG_d/2+2*(insul_thick+AWG_d/2)*n)
end
%%3d space setup
theta=linspace(0,2*pi,segments);
Rx=zeros(num_L,segments); %2d arrays of layers x points
Ry=zeros(num_L,segments); %2d arrats of layers x points
Rz=zeros(num_T/num_L,segments); %2d array of layes x points

%iterate to assign radii of circles
for n=1:num_L %for all raddii
    for t=1:segments %fill data points
        Rx(n,t)=radii(1,n)*cos(theta(1,t));
        Ry(n,t)=radii(1,n)*sin(theta(1,t));
    end
end

%iterate to assign height posistion of circles unique as it has to traverse
%all levels

for k=1:num_T/num_L %for all heights
    for t=1:segments %fill data points
        Rz(k,t)=spacing*k;
    end    
end

for k=1:num_T/num_L %for all heights
    for n=1:num_L %for all raddii
        plot3(Rx(n,:),Ry(n,:),Rz(k,:),'--k')
        hold on
    end
end

xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')
view([0,0])

%above here has worked

%%Now B field through biot savart law and derivative estimates

%%map 3d space
x=xmin:dx:xmax; %set array of x
y=ymin:dx:ymax; %set array of y
z=zmin:dx:zmax; %set array of z
%this range to calculate b field
[X,Y,Z]=meshgrid(x,y,z); %creates 3d grid off of bounds

Bx=zeros(size(x));
By=zeros(size(y));
Bz=zeros(size(z));
%need to sum all b fields together

%go at each height, then each ring and each time solve b dield
for k=1:num_T/num_L %for all heights
    for n=1:num_L %for all raddii
        Rx_1=Rx(n,:);
        Ry_1=Ry(n,:);
        Rz_1=Rz(k,:);

        Points=transpose([Rx_1;Ry_1;Rz_1]); %rotate matrix simulate cross product


        
        %%calculations

        %determine B field by steps of dx

        for t=1:segments-1 %fill data points
            Rx_1=X-Points(t,1);
            Ry_1=Y-Points(t,2);
            Rz_1=Z-Points(t,3);
            R=sqrt(Rx_1.^2+Ry_1.^2+Rz_1.^2); %overall distance to point
            R=R.*(R>=dx)+dx*(R<dx); %rounding for step size

            dLx=Points(t+1,1)-Points(t,1);
            dLy=Points(t+1,2)-Points(t,2);
            dLz=0;

            %components at each point by biot-savart law
            Bx=Bx+u0*Current/(4*pi)*(dLy.*Rz_1-dLz.*Ry_1).*R.^(-2);
            By=By+u0*Current/(4*pi)*(dLz.*Rx_1-dLx.*Rz_1).*R.^(-2);
            Bz=Bz+u0*Current/(4*pi)*(dLx.*Ry_1-dLy.*Rx_1).*R.^(-2);
            
        end  
    end
end
quiver3(X,Y,Z,Bx,By,Bz,'-b','LineWidth',2)
axis([xmin xmax ymin ymax zmin zmax])
title('3d map of solenoid and b field')
hold off
%2D plot attempt number 2
figure()

%contour(By(30,:,:),Bz(30,:,:),Bz)
quiver(Y(:,ceil(end/2),:),Z(:,ceil(end/2),:),By(:,ceil(end/2),:),Bz(:,ceil(end/2),:))
xlabel("y [m]")
ylabel("z [m]")
title("2d cut plot")


