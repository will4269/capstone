close all
%% Inputs
Shape="Solid"; %"Solid" or "Hoop"
Radius_Minor=0.001; %projectile hoop hollow diameter"M"
Radius_Major=0.003175; %Projectile outside diameter "M" {1/8 = 3.175mm}
Length=0.08255; %3.25in to M is 0.08255 "M"
Vertical_Off=0.00; %Off set from coordinate 0z 
%Or total
Vertical_Off=Vertical_Off+max(Point_3d(1,3,:)); %highest point of solenoid
Density=7e3; %AlNiCo=7*10^3 kg/m^3 , 7.5*10^3 kg/m^3
M=2.48; % AlNiCo 5 2.48 J/T, NdFeB 0.75 J/T
ur=50629.02;%relative permeability

%% Volume and Mass Equation
Volume=Length*pi.*(Radius_Major)^2;
Mass=Volume*Density;
if(Shape=="Hoop")
    Volume=Volume-Length*pi.*(Radius_Minor)^2;
    Mass=Volume*Density;
end



%% areas for projectile surfaces

% O means outer
[X_O,Y_O,Z_O] = cylinder(Radius_Major);
Z_O=Length.*Z_O+Vertical_Off; %add offset
surf(X_O,Y_O,Z_O) %plot of cylinder
hold on
quiver3(X,Y,Z,HX,HY,HZ)
xlim([xmin xmax])
ylim([ymin ymax])
zlim([zmin zmax])
xlabel("x[m]")
ylabel("y[m]")
zlabel("z[m]")

%% Outer Energy data
U_B=zeros(length(x),length(y),length(z)); % create 3d matrix for energy to do gradient for force [joules]

%Energy Equation Assuming Projectile Alingment

for x_O=1:length(x)%increment across x axis
    for y_O=1:length(y)%increment across y axis
        for z_O=1:length(z)%increment across z axis
            if Z(1,1,z_O)>=Z_O(1,1) && Z(1,1,z_O)<=Z_O(2,1) %if within upper and lower bounds of cylinder
                %disp("here")
                if sqrt(X(x_O,1,1).^2+Y(1,y_O,1^2))<=(Radius_Major)%if within cylinder radius
                    %disp("here")
                    U_B(x_O,y_O,z_O)=-M*u0*ur*HZ(x_O,y_O,z_O)*dx*dx*dz; %assign if within cylinder
                end
            end
        end
    end
end


%% Inner Energy Data
%I means inner
if(Shape=="Hoop")
    hold on
    [X_I,Y_I,Z_I] = cylinder(Radius_Minor);
    Z_I=Length.*Z_I+Vertical_Off; %add offset
    surf(X_I,Y_I,Z_I) %plot of cylinder
    hold off

    %Energy Removal system Assuming Projectile Alingment
    U_B2=zeros(length(x),length(y),length(z)); % create 3d matrix for energy to do gradient for force [joules]

    for x_O=1:length(x)%increment across x axis
        for y_O=1:length(y)%increment across y axis
            for z_O=1:length(z)%increment across z axis
                if Z(1,1,z_O)>=Z_I(1,1) && Z(1,1,z_O)<=Z_I(2,1) %if within upper and lower bounds of cylinder
                    %disp("here")
                    if sqrt(X(x_O,1,1).^2+Y(1,y_O,1^2))<=(Radius_Minor)%if within cylinder radius
                        %disp("here")
                        U_B2(x_O,y_O,z_O)=-M*BZ(x_O,y_O,z_O); %assign if within cylinder
                    end
                end
            end
        end
    end
    Temp=sum(U_B,"all");
    Temp_2=sum(U_B2,"all"); 

end
hold off

%%Force generation
Force=gradient(U_B);
Force=abs(Force);
Force_sum=sum(Force,'all');
accel=Force_sum/Mass;

%Issue Force is a product of field density

%%clear all unneccesary
clearvars -except Point_3d HX HY HZ BX BY BZ u0 x y z X Y Z U_B U_B2 Force Force_sum accel Mass Volume Temp Temp_2 dz dx xmin xmax ymin ymax zmin zmax

