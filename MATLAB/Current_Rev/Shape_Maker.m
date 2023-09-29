clear all

%The goal of this document is to plot a 3d shape to resemble the solenoid.

Num_Points=20000; % number of points on entire curve
Num_Turns=10; %number of turns total
Shape="Rectangle"; %Determines shape of solenoid
%options Rectangle or Trumpet or Triangle
% rectangle is a cylinder | rectangle cross section
% Triangle is a sloped solenoid | triangular cross section
%Note this will be done by turns reduced by per layer
%start at num_Turns at layer 1
%ask for input of how many turns to subtract
%
%EX
%Num_turns=8, reduce by 2


%
%
% x|x|             Layer 4: 0
% x|x|x|x|         Layer 3: 4
% x|x|x|x|x|x|     Layer 2: 6
% x|x|x|x|x|x|x|x| layer 1: 8



Radius_init=0.0127; %initial radius of shape [m]
Wire_Awg=16; %wire gauge to be used to space wires/adjust radii


%%calc start
Wire_d=0.005*92^((36-Wire_Awg)/39); %wire diameter [inches]
Wire_d=Wire_d*(25.4/1000); %wire diameter [m]
Points_rev=Num_Points/Num_Turns; %number of points on loop
Step=Wire_d; %serves as a step between points while traversing vertically

Theta_Step=Num_Points/Num_Turns; %defines step distance between points on a single turn [used in angle math] [radians]
Step=Step/Theta_Step; %steps vertically wire's diameter divided by theta_step [used in linear math] [m]


%%Rectangle Properties
if(Shape=="Rectangle") 
    disp("# of turns for this is number of turns on layer all layers")
    disp("# of points for this is number of points total") 
    prompt="Enter # of layers factor of Num_Turns\n\r";
    Num_Layers=input(prompt);

    Layer_points=Num_Points/Num_Layers; % dictates number of points per layer

    Layer_prev=0; %initilize Layer_prev for starting layer
    
    Point_3d=zeros(1,3,Num_Points); %store 3d values of solenoid points

    for Layers=1:Num_Layers %step through layers
        if(Layer_prev==0)%on initial layer
            Layer_radii=Radius_init;
            Theta=linspace(0,2*pi,Points_rev); %angle step per rev
            Rx=(Wire_d*0.5+Layer_radii).*cos(Theta); %assign initial layer radii x
            Ry=(Wire_d*0.5+Layer_radii).*sin(Theta); %assign initial layer radii y
        elseif(Layer_prev~=Layers) %when going to next layer, expand radii
            %increment few points of loop out to showcase traversal
           Ry=(Wire_d*0.5+Wire_d*Layer_prev+Layer_radii).*sin(Theta);
           Rx=(Wire_d*0.5+Wire_d*Layer_prev+Layer_radii).*cos(Theta);
            %Expand radius
        end
        for Layer_set=1:Num_Points/Num_Layers %for a layer of turns
            %Point 3d works on 1x3xnum of point matrix
            %1x1x: is x
            %1x2x: is y
            %1x3x: is z

            %Layer_Prev serves as an indexer

            Radius_Index=mod(Layer_set,Points_rev); %counteracts overflow
            if(Radius_Index==0)
                Radius_Index=1;
            end
            Point_3d(1,1,Layer_set+(Layer_prev*Num_Points/Num_Layers))=Rx(1,Radius_Index); %modulo is to loop around the circle
            Point_3d(1,2,Layer_set+(Layer_prev*Num_Points/Num_Layers))=Ry(1,Radius_Index); %modulo is to loop around the circle
            if(mod(Layer_prev,2)==0)
                Point_3d(1,3,Layer_set+(Layer_prev*Num_Points/Num_Layers))=Step*Layer_set; %adds constantly until top of solenoid
            else
                Point_3d(1,3,Layer_set+(Layer_prev*Num_Points/Num_Layers))=(Step*Num_Points/Num_Layers)-(Step*Layer_set); %adds constantly until top of solenoid
            end
       
            %disp(((Layer_set+(Layer_prev*Num_Points/Num_Layers)))) err
            %check

        end
        Layer_prev=Layers; %this serves to detect layer change
    end
end
%%End Rectanlge

%%Triangle Propeties
if(Shape=="Triangle") 
    disp("# of turns for this is number of turns on layer 1")
    disp("# of points for this is number of points per turn")
    prompt="Enter # of turns to reduce per layer\n\";
    Num_Reduce=input(prompt);
    Num_Layers=floor(Num_Turns/Num_Reduce); %number of layers is a function of initial turns and reduce rate


    
    Layer_prev=0; %initilize Layer_prev for starting layer
    Layer_set_prev=0;
    %calculate # of turns accurate
    Turns_accurate=Num_Turns; %assign initial turns
    for inc=1:Num_Layers %increment through layers
        Turns_accurate=Turns_accurate+(Num_Turns-Num_Reduce*inc); %verified with 8 and -2
    end
    %Turns_Accurate is the new number of turns
    Points_rev=Num_Points;
    Step=Step/Num_Points; %steps vertically wire's diameter divided by theta_step [used in linear math] [m]

    Point_3d=zeros(1,3,Num_Points*Turns_accurate); % redefine points_3d
    for Layers=1:Num_Layers %step through layers
        %gonna loop across the length of a barrel, and then increment
        %height
        Turns=(Num_Turns-Num_Reduce*Layer_prev); % storage for reused variable
        if(Layer_prev==0)%on initial layer
            Layer_radii=Radius_init;
            Theta=linspace(0,2*pi*Turns,Points_rev*Turns); %angle step per rev
            Rx=(Wire_d*0.5+Layer_radii).*cos(Theta); %assign initial layer radii x
            Ry=(Wire_d*0.5+Layer_radii).*sin(Theta); %assign initial layer radii y
            disp(Rx(1,1))
        elseif(Layer_prev~=Layers) %when going to next layer, expand radii
            %increment few points of loop out to showcase traversal
            Theta=linspace(0,2*pi*Turns,Points_rev*Turns); %angle step per rev
           Ry=(Wire_d*0.5+Wire_d*Layer_prev+Layer_radii).*sin(Theta);
           Rx=(Wire_d*0.5+Wire_d*Layer_prev+Layer_radii).*cos(Theta);
           disp(Rx(1,1))
            %Expand radius
        end

        for Layer_set=1:(Num_Points)*(Turns)%for a layer of turns, generate respective point amount
            %Point 3d works on 1x3xnum of point matrix
            %1x1x: is x
            %1x2x: is y
            %1x3x: is z

            %Layer_Prev serves as an indexer

            Radius_Index=mod(Layer_set,Points_rev); %counteracts overflow
            if(Radius_Index==0)
                Radius_Index=1;
            end

            Point_3d(1,1,Layer_set+Layer_set_prev)=Rx(1,Radius_Index); %modulo is to loop around the circle
            Point_3d(1,2,Layer_set+Layer_set_prev)=Ry(1,Radius_Index); %modulo is to loop around the circle
            Point_3d(1,3,Layer_set+Layer_set_prev)=Step*Layer_set; %adds constantly until top of solenoid
            %disp(Point_3d(1,3,Layer_set))
            %disp(((Layer_set+(Layer_prev*Num_Points/Num_Layers)))) %err
            %check
            

        end
        Layer_set_prev=Layer_set_prev+Layer_set; %store previous, set amount
        Layer_prev=Layers; %this serves to detect layer change
    end

end
%%End Triangle

%%Trumpet Properties
if(Shape=="Trumpet") 
    disp("# of turns for this is number of turns on layer 1")
    disp("# of points for this is number of points per turn")
    prompt="Enter divisor for reduction rate ('halving' only)\n\";
    Divider=input(prompt);
    prompt="Enter # of turns to reduce on layer, halving must be even 1\n\";
    Num_Reduce=input(prompt);

    if(Divider=="root")
        
    elseif(Divider=="halving")
        Turns_Per_Layer=[Num_Turns];
        Turns_total=Num_Turns;
        temps=Num_Reduce; %temp storage of reducing rate
        temps_2=0;%temp storage of all reduction
        Num_Layers=1; % counting layers
        Turns_accurate=Num_Turns*2-Num_Reduce;
        
        while Turns_total>=1 %while turns at a layer has not been reduced
            temps_2=temps_2+temps; %store reduction sum
            Turns_total=Num_Turns-temps_2;
            temps=ceil(temps/2);  %reduces reduction rate per loop (at least 1)
            Num_Layers=Num_Layers+1;
            Turns_Per_Layer(end+1)=Turns_total;
        end%number of layers is a function of initial turns, reduce 
    end
    Num_Layers=Num_Layers-1; % number of layers set
    %Turns_Accurate is the new number of turns



    
    Layer_prev=0; %initilize Layer_prev for starting layer
    Layer_set_prev=0;
   
    
    
    Points_rev=Num_Points;
    Step=Step/Num_Points; %steps vertically wire's diameter divided by theta_step [used in linear math] [m]

    Point_3d=zeros(1,3,Num_Points*Turns_accurate); % redefine points_3d
    for Layers=1:Num_Layers %step through layers
        %gonna loop across the length of a barrel, and then increment
        %height

        Turns=Turns_Per_Layer(1,Layer_prev+1); % storage for reused variable
        if(Layer_prev==0)%on initial layer
            Layer_radii=Radius_init;
            Theta=linspace(0,2*pi*Turns,Points_rev*Turns); %angle step per rev
            Rx=(Wire_d*0.5+Layer_radii).*cos(Theta); %assign initial layer radii x
            Ry=(Wire_d*0.5+Layer_radii).*sin(Theta); %assign initial layer radii y
            %disp(Rx(1,1))
        elseif(Layer_prev~=Layers) %when going to next layer, expand radii
            %increment few points of loop out to showcase traversal
           Theta=linspace(0,2*pi*Turns,Points_rev*Turns); %angle step per rev
           Ry=(Wire_d*0.5+Wire_d*Layer_prev+Layer_radii).*sin(Theta);
           Rx=(Wire_d*0.5+Wire_d*Layer_prev+Layer_radii).*cos(Theta);
          % disp(Rx(1,1))
            %Expand radius
        end

        for Layer_set=1:(Num_Points)*(Turns_Per_Layer(1,Layer_prev+1))%for a layer of turns, generate respective point amount
            %Point 3d works on 1x3xnum of point matrix
            %1x1x: is x
            %1x2x: is y
            %1x3x: is z

            %Layer_Prev serves as an indexer

            Radius_Index=mod(Layer_set,Points_rev); %counteracts overflow
            if(Radius_Index==0)
                Radius_Index=1;
            end

            Point_3d(1,1,Layer_set+Layer_set_prev)=Rx(1,Radius_Index); %modulo is to loop around the circle
            Point_3d(1,2,Layer_set+Layer_set_prev)=Ry(1,Radius_Index); %modulo is to loop around the circle
            Point_3d(1,3,Layer_set+Layer_set_prev)=Step*Layer_set; %adds constantly until top of solenoid
            if(mod(Layer_prev,2)==0)
                Point_3d(1,3,Layer_set+Layer_set_prev)=Step*(Num_Points)*(Turns_Per_Layer(1,Layer_prev+1))-Step*Layer_set; %increment down from top
            else
                Point_3d(1,3,Layer_set+Layer_set_prev)=Step*Layer_set; %adds constantly until top of solenoid
            end
            %disp(Point_3d(1,3,Layer_set))
            %disp(((Layer_set+(Layer_prev*Num_Points/Num_Layers)))) %err
            %check
            

        end
        Layer_set_prev=Layer_set_prev+Layer_set; %store previous, set amount
        Layer_prev=Layers; %this serves to detect layer change

    end

end
%%End Trumpet

%plot values below
plot3(squeeze(Point_3d(1,1,:)),squeeze(Point_3d(1,2,:)),squeeze(Point_3d(1,3,:)))
xlabel("x[m]")
ylabel("y[m]")
zlabel("z[m]")