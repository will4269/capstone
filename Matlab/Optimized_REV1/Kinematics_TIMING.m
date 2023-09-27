clear all
close all

%This document aims to solve the high period of the solenoid of a
%accelerating projectile through the first solenoid

%This is done as it will be the longest on and will determine time high max

V0=0; %initial velocity
D0=0; %initial distance

%Distance=Vi*t+(1/2)(a(d))t^2

%solving for t
%V initial = 0

%d=a(d)*t^2

%distance to cover is 4inches or 0.106m

%a=f/0.3kg
%a at 2inches = 30m/s^2
%a at 1.5inches = 41.7m/s^2
%a at 1inches = 65.4m/s^2
%a at 0.5inches = 95.66 m/s^2
%a at 0inches = 208m/s^2
%a at -0.5inches = 398m/s^2
%a at -1 inches = 743.3m/s^2
%a at -1.5inches = 958m/s^2
%a at -2inches = 1153m/s^2
dist=[4;3.5;3;2.5;2;1.5;1;0.5;0;-0.5;-1;-1.5;-2];
dist=dist.*25.4;
a_d=[6.3837;5.5857;5.1868;4.6075;4.0730;3.5770;2.5104;2.2549;1.849;1.4823;0.9613;0.8731;0.7890];

a=fit(dist,a_d,'poly6');

%use feval 
%to evaluate a as neccesary

x=linspace(101.6,-2*25.4,1000); %linear space distance
y=feval(a,x);
plot(x,y)
title("accel vs distance")
xlabel("distance mm")
ylabel("accel m/s^2")
hold on 
scatter(dist,a_d)
hold off
%i believe average of a will give a good understanding of the time
%neccesary

%estimates
a_avg=mean(y);
t=sqrt(0.106/a_avg);
%t is  16mS
vf=a_avg*t;
%velocity at turn off is ~ 6.38m/s



%D=Vi*t+(1/2)*a(D)*t^2
%x=(dxi/dt)t+(1/2)*(ddx/ddt)*t^2
%derivative with respect to time {v=vi+at}
%dx/dt=dxi/dt+(ddx/ddt)t



%t=unk
%D is known at 4 inches
%vi is known at 0 inches
%a(D) is known

%% don't use normal kinematics
%v(t+δt)=v(t)+{a{r(t)}δt
%r(t+δt)=r(t)+v(t)δt+(a{r(t)}δt^2)/2
%a=dv/dt=dv/dr *dr/dt=v*dv/dr {dv/dr} is change in velocity with respect to
%di distance {dx/dt}=a {dv/dr}=a(d)=a(r) This is the a function

% source: https://math.stackexchange.com/questions/1819578/distance-dependent-acceleration-evaluation




%r(t+δt)=r(t)+v(t)δt+({4.109e-08*r(t)^6+1.5e-07*r(t)^5-0.0002172*r(t)^4+0.0004173*r(t)^3+0.4413*r(t)^2-13.11*r(t)+193.1}*δt^2)/2
%above is the distance relation
%below is the velocity relation
%v(t+δt)=v(t)+aδt
%or maybe
%v(t+δt)=v(t)+({4.109e-08*r(t)^6+1.5e-07*r(t)^5-0.0002172*r(t)^4+0.0004173*r(t)^3+0.4413*r(t)^2-13.11*r(t)+193.1}*δt)








%attempt 2

%source https://physics.stackexchange.com/questions/15587/how-to-get-distance-when-acceleration-is-not-constant
%a(r)={4.109e-08*r^6+1.5e-07*r^5-0.0002172*r^4+0.0004173*r^3+0.4413*r^2-13.11*r+193.1}
%v0=0
%x0=0
%0.5*v(x)^2=wc+∫a(x)dx
%t(x)=tc+∫1/v(x)dx
figure()
Velo=sqrt(2*(V0+integrate(a,x,-50.8))); %integrate to solve for the velocity/distance relationship
plot(x,Velo)
title("velocity as a dependent on distance")
xlabel("distance mm")
ylabel("velocity m/s")

figure()
%t(x)=tc+∫1/v(x)dx

time=@(x) (1./(Velo));
t=integral(time, x(end), x(1), 'ArrayValued', 1);
plot(x,flip(t,1))
title("time as a dependent on distance")
xlabel("distance mm")
ylabel("time s")

%time seems off