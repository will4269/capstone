close all
%%Inital 3d mesh maker
%%Graph parameters
dx=0.01; %step of meshgrid
u0=(4*pi)*10^(-7);
current=30.0;
%initial matrix

%max value height
z_temp=max(Point_3d(1,3,:));
%max value radius
r_temp=max(Point_3d(1,2,:));

xmin=-2*r_temp;
xmax=2*r_temp;
ymin=xmin;
ymax=xmax;
zmin=-z_temp;
zmax=2*z_temp;
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
[BX,BY,BZ]=meshgrid(x,y,z);

%From last time meshgrid was y,x,z {b-field calc} from force_output
%added

%goal is biot savart across entire curve at all points
%https://www.youtube.com/watch?v=I8X1EpH_VQY&ab_channel=KhanAcademyIndia-English



%dB=(u0/4pi)*I*(dl-> x r^)/(|r|^2)

temp=size(Point_3d); %storing temp of point_3d dimensions
temp_2=size(x); %storing temp of size of derivative

 for inc=1:temp(3)-1 %across all data points, until last

     dl_x=Point_3d(1,1,inc+1)-Point_3d(1,1,inc); %dl is point minus previous point [x]
     dl_y=Point_3d(1,2,inc+1)-Point_3d(1,2,inc); %dl is point minus previous point [y]
     dl_z=Point_3d(1,3,inc+1)-Point_3d(1,3,inc); %dl is point minus previous point [z]
     dl=[dl_x,dl_y,dl_z]; %dl as an x,y,z  vector

     ref=[Point_3d(1,1,inc),Point_3d(1,2,inc),Point_3d(1,3,inc)]; %point to reference, to create r^ and R

     for x_p=1:temp_2(1) %x position step in loop
        for y_p=1:temp_2(1) %y position step in loop
            for z_p=1:temp_2(1) %Z position step in loop
                %r is standin for distance from point to field
                r_x=X(x_p,y_p,z_p)-ref(1);
                r_y=Y(x_p,y_p,z_p)-ref(2);
                r_z=Z(x_p,y_p,z_p)-ref(3);
                r=[r_x,r_y,r_z]; %create r vector
                r_mag=sqrt(r_x^2 + r_y^2 + r_z^2); %magnitude of vector
                r_hat=r/r_mag; %create r hat vector
               
                %disp(cross(dl,r_hat))
                B=(u0/(4*pi))*current*(cross(dl,r_hat))/(r_mag^2);%B-field vector components
                BX(x_p,y_p,z_p)=BX(x_p,y_p,z_p)+B(1);
                BY(x_p,y_p,z_p)=BY(x_p,y_p,z_p)+B(2);
                BZ(x_p,y_p,z_p)=BZ(x_p,y_p,z_p)+B(3);
            end
        end
     end
 end
 figure()
 quiver3(X,Y,Z,BX,BY,BZ)
 title("vector field")
 xlim([xmin xmax])
ylim([ymin ymax])
zlim([zmin zmax])
xlabel("x[m]")
ylabel("y[m]")
zlabel("z[m]")