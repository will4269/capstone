clear
clf
%%Graph parameters
xmin=-0.15;
xmax=0.15;
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
R0=0.5; %radius to outside of barrel
num_L=5; %number of Layers
num_T=200; %number of Turns overall
segments=50; %points per loop
dx=0.005; %B field step size
%b field calculated by radius of each loop

%%Projectile inputs
R_B=0.25; %[inches] radius of projectile
Length_B=2; %[inches] length of projectile
density_B=0.255; %[lb/in^3] of projectile
Off_B=0; %[inches] projectile offset from solenoid
surface_points=20; %must be able to become an XxX matrix
%Magnetic moment of iron
m_B=4.89; %Bohr's Magneton [Joules/Tesla]



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
            Bx=Bx+u0*Current/(4*pi)*(dLy.*Rz_1-dLz.*Ry_1).*R.^(-3);
            By=By+u0*Current/(4*pi)*(dLz.*Rx_1-dLx.*Rz_1).*R.^(-3);
            Bz=Bz+u0*Current/(4*pi)*(dLx.*Ry_1-dLy.*Rx_1).*R.^(-3);
            
        end  
    end
end
quiver3(X,Y,Z,Bx,By,Bz,'-b','LineWidth',2)
axis([xmin xmax ymin ymax zmin zmax])


%%projectile modeling and properties
Mass_b=2*pi*(R_B)^2*Length_B*density_B;% [lbs]
Mass_b=Mass_b*2.205; %to kg conversion

%areas for projectile surfaces
[X_P,Y_P,Z_P] = cylinder(R_B*25.4/1000);
Z_P = Z_P*Length_B*(25.4/1000)+(num_T/num_L)*spacing+Off_B*(25.4/1000);
surf(X_P,Y_P,Z_P)
U_B=zeros(length(x),length(y),length(z)); % create 3d matrix for energy to do gradient for force [joules]
%Force equation here Gradient(M dot B)
for x_b=1:length(x)%increment across x axis
    for y_b=1:length(y)%increment across y axis
        for z_b=1:length(z)%increment across z axis
            if Z(1,1,z_b)>=Z_P(1,1) && Z(1,1,z_b)<=Z_P(2,1) %if within upper and lower bounds of cylinder
                if sqrt(X(x_b,1,1).^2+Y(1,y_b,1^2))<=(R_B*25.4/1000)%if within cylinder radius
                    U_B(x_b,y_b,z_b)=m_B*Bz(x_b,y_b,z_b); %assign if within cylinder
                end
            end
        end
    end
end
hold off

%force seems off from predicted
plot3(U_B)
Force=gradient(U_B);
Force_sum=sum(Force,"all");



%%Below is 2d B field plot atempt
hold off


%trying to figure out field slicing
% figure()
% [U,V]=meshgrid(Bx(:,10,10),Bz(10,10,:));
% [S,T]=meshgrid(X(:,10,10),Z(10,10,:));
% quiver(S,T,U,V)

