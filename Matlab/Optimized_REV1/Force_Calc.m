
%%inputs
u0=4*pi*10^(-7); %permability
%%Projectile inputs
R_B=0.25; %[inches] radius of projectile
Length_B=4; %[inches] length of projectile
density_B=0.255; %[lb/in^3] of projectile
Off_B=3; %[inches] projectile offset from solenoid
surface_points=20; %must be able to become an XxX matrix
%Magnetic moment of iron
m_B=4.89; %Bohr's Magneton [Joules/Tesla]




%%projectile modeling and properties
Mass_b=2*pi*(R_B)^2*Length_B*density_B;% [lbs]
Mass_b=Mass_b*2.205; %to kg conversion

%areas for projectile surfaces
[X_P,Y_P,Z_P] = cylinder(R_B*25.4/1000);
Z_P = Z_P*Length_B*(25.4/1000)+(num_T/num_L)*spacing+Off_B*(25.4/1000);
surf(X_P,Y_P,Z_P) %plot of cylinder
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
%plot3(U_B[:,61,61]U_B[61,:,61],)
%figure()
Force=gradient(U_B);
Force=abs(Force);
Force_sum=sum(Force,'all');
accel=Mass_b/Force_sum;
%title("Energy Plot")
%scatter3( x, y, z, [], U_B(:,:,:) );