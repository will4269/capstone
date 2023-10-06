close all
%%Inital 3d mesh maker
%%Graph parameters
dx=0.004; %step of meshgrid
u0=(4*pi)*10^(-7);
current=30.0;
scale=8;
%initial matrix

%max value height
z_temp=max(Point_3d(1,3,:));
%max value radius
r_temp=max(Point_3d(1,2,:));

xmin=-scale*r_temp;
xmax=scale*r_temp;
ymin=xmin;
ymax=xmax;
zmin=-scale*z_temp;
zmax=(scale+1)*z_temp;
clear vars r_temp z_temp
plot3(squeeze(Point_3d(1,1,:)),squeeze(Point_3d(1,2,:)),squeeze(Point_3d(1,3,:)))
title("solenoid and field")
%hold on
xlim([xmin xmax])
ylim([ymin ymax])
zlim([zmin zmax])
xlabel("x[m]")
ylabel("y[m]")
zlabel("z[m]")
%%mesh making
x=xmin:dx:xmax; %set array of x
y=ymin:dx:ymax; %set array of y
%step into z by the same y and z amount
dz=(zmax-zmin)/((xmax-xmin)/dx);%create z step based on x step
%dz=ceil(zmin-zmax)/dz;%refit properly
z=zmin:dz:zmax; %set array of z

%%mesh run
[X,Y,Z]=meshgrid(x,y,z);
[HX,HY,HZ]=meshgrid(x,y,z);%hfield
%From last time meshgrid was y,x,z {b-field calc} from force_output
%added

%goal is biot savart across entire curve at all points
%https://www.youtube.com/watch?v=I8X1EpH_VQY&ab_channel=KhanAcademyIndia-English



%dB=(u0/4pi)*I*(dl-> x r^)/(|r|^2)

temp=size(Point_3d); %storing temp of point_3d dimensions
temp_2=size(x); %storing temp of size of derivative
for inc=1:temp(3)-1 %across all data points, until last
     %inc=1; %testing field maker
     dl_x=Point_3d(1,1,inc+1)-Point_3d(1,1,inc); %dl is point minus previous point [x]
     dl_y=Point_3d(1,2,inc+1)-Point_3d(1,2,inc); %dl is point minus previous point [y]
     dl_z=Point_3d(1,3,inc+1)-Point_3d(1,3,inc); %dl is point minus previous point [z]
     dl=[dl_x,dl_y,dl_z]; %dl as an x,y,z  vector

     ref=[Point_3d(1,1,inc),Point_3d(1,2,inc),Point_3d(1,3,inc)]; %point to reference, to create r^ and R

     for x_p=1:temp_2(2) %x position step in loop
        for y_p=1:temp_2(2) %y position step in loop
            for z_p=1:temp_2(2) %Z position step in loop
                %r is standin for distance from point to field


                %%checking space incrementation
                %disp(temp_2(2))

%                 if(x_p <3 && y_p <3 && z_p <3)
%                     disp([X(x_p,y_p,z_p);Y(x_p,y_p,z_p);Z(x_p,y_p,z_p)])
%                     disp([x_p;y_p;z_p])
%                     disp("level")
%                     %This showcases that incrementation across x,y,z is
%                     %correct
%                 end

                r_x=X(x_p,y_p,z_p)-ref(1); %generate x distance
                r_y=Y(x_p,y_p,z_p)-ref(2); %generate y distance
                r_z=Z(x_p,y_p,z_p)-ref(3); %generate z distance
                r=[r_x,r_y,r_z]; %create r vector
                r_mag=sqrt(r_x^2 + r_y^2 + r_z^2); %magnitude of vector
                r_hat=r/r_mag; %create r hat vector

%                 disp(dl) %printing dl
%                 disp(r) %printing r vector
%                 disp(cross(dl,r_hat))
%                 disp("one")
                %cross product aligns x,y,z 
                H=(current/(4*pi))*(cross(dl,r_hat))/(r_mag^2);%B-field vector components
                %must update all points in B-field for eahc iteration of
                %wire
                HX(x_p,y_p,z_p)=HX(x_p,y_p,z_p)+H(1);
                HY(x_p,y_p,z_p)=HY(x_p,y_p,z_p)+H(2);
                HZ(x_p,y_p,z_p)=HZ(x_p,y_p,z_p)+H(3);
            end
        end
     end
end

%%H-field plotting start
figure()
quiver3(X,Y,Z,HX,HY,HZ)
hold on
plot3(squeeze(Point_3d(1,1,:)),squeeze(Point_3d(1,2,:)),squeeze(Point_3d(1,3,:)))
title("vector field [H-field] No-internal Material 3d")
xlim([xmin xmax])
ylim([ymin ymax])
zlim([zmin zmax])
xlabel("x[m]")
ylabel("y[m]")
zlabel("z[m]")

figure()
quiver(Y(:,ceil(length(y)/2),:),Z(:,ceil(length(z)/2),:),HY(:,ceil(length(y)/2),:),HZ(:,ceil(length(z)/2),:))
title("vector field [H-field] No-internal Material 2d")
xlim([xmin xmax])
ylim([ymin ymax])
zlim([zmin zmax])
xlabel("x[m]")
ylabel("z[m]")
%%H-field plotting end




%%clear all unneccesary
clearvars -except Point_3d HX HY HZ u0 x y z X Y Z dz dx xmin xmax ymin ymax zmin zmax