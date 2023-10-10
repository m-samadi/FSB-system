% Fire Application Using Fire Fuzzy Controller (FFC)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%% Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
InitialNodeEnergy=100;
RoundsOutputSelect=3; % OutputSelect (Total=1, Random=2, both=3)

RoundCount=100;
ShowRandom_ShowSequential_StartNumber=15;
ShowRandom_ShowSequential_StepNumber=10;
ShowRandom_ShowSequential_FinishNumber=45;
ShowRandom_StepNumber=500;
TotalRoundList=zeros(RoundCount,9); % 1: RoundNumber | 2: Minimum distance between nodes | 3: Maximum distance between nodes | 4: Average distance between nodes | 5: Average remainder energy of the nodes | 6: Total consumption energy of the nodes | 7: Average consumption energy of the nodes | 8: Live nodes count | 9: Dead nodes count
TotalRoundList_Index=0;
RandomRoundList=zeros(RoundCount,9); % 1: RoundNumber | 2: Minimum distance between nodes | 3: Maximum distance between nodes | 4: Average distance between nodes | 5: Average remainder energy of the nodes | 6: Total consumption energy of the nodes | 7: Average consumption energy of the nodes | 8: Live nodes count | 9: Dead nodes count
RandomRoundList_Index=0;
RandomRoundList_Flag=zeros(RoundCount,1);

Network_Length=2000;
Network_Width=2000;

NodeNumber=50;
NodeList=zeros(NodeNumber,12); % ID | X | Y | RemainderEnergy | Dead RandomRound | Temperature | Light Intensity | Smoke | Status is Event: 1=Event, 0=Not Event | Has Data: 1=Yes, 0=No | Has Any Sensed Data: 1=Yes, 0=No | Fire Probability 
SenseNodeDataIntervalTime=2;

Temperature_ThresholdValue=50;
LightIntensity_ThresholdValue=900;
Smoke_ThresholdValue=8;

DataGenerationNumber=20;
DataGenerationList=zeros(1:DataGenerationNumber,4); % Temperature | Light Intensity | Smoke | Status is Event: 1=Event, 0=Not Event
DataGenerationList_Index=0;
DataGenerationList_Navigator=1;

BaseStation_X=1000;
BaseStation_Y=1000;
BaseStationBufferSize=1000000;
BaseStation=[BaseStation_X BaseStation_Y]; % X | Y
BaseStationBuffer=zeros(1:BaseStationBufferSize,7); % Temperature | Light Intensity | Smoke | Status is Event: 1=Event, 0=Not Event | X | Y | Fire Probability
BaseStationBuffer_Index=0;

Temperature_ShapeFactor=200;
LightIntensity_ShapeFactor=1500;
Smoke_ShapeFactor=10;
FireProbability_ShapeFactor=100;

Temperature_Type='i';
LightIntensity_Type='i';
Smoke_Type='i';
FireProbability_Type='b';

Color_Level1=[50/255 205/255 50/255];
Color_Level2=[0/255 0/255 255/255];
Color_Level3=[255/255 140/255 0/255];
Color_Level4=[255/255 0/255 0/255];

PacketSize=100;
NodeThresholdEnergy=5*(10^(-9))*PacketSize;
RoundAverageRemainderEnergy=zeros(RoundCount,2);
d0=87.7;
CH_P=0.2;





%%%%% Membership functions of the fuzzy decision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Input fuzzy
%%% Temperature
MaximumTemperature=200;
U_Temperature=[-40 -15 5 15 30 50 70 100 150 200];
% VeryCold
mu_Temperature_VeryCold=[1.0 0.6 0.1 0.0 0.0 0.0 0.0 0.0 0.0 0.0];
% Cold
mu_Temperature_Cold=[0.5 1.0 0.2 0.0 0.0 0.0 0.0 0.0 0.0 0.0];
% Cool
mu_Temperature_Cool=[0.0 0.4 1.0 0.6 0.0 0.0 0.0 0.0 0.0 0.0];
% Nice
mu_Temperature_Nice=[0.0 0.0 0.5 1.0 0.3 0.0 0.0 0.0 0.0 0.0];
% Warm
mu_Temperature_Warm=[0.0 0.0 0.0 0.0 0.6 1.0 0.5 0.0 0.0 0.0];
% Hot
mu_Temperature_Hot=[0.0 0.0 0.0 0.0 0.2 0.6 0.9 1.0 1.0 1.0];

%%% Light intensity
MaximumLightIntensity=1500;
U_LightIntensity=[0 20 50 100 200 300 750 900 1200 1500];
% VeryLow
mu_LightIntensity_VeryLow=[1.0 0.6 0.2 0.0 0.0 0.0 0.0 0.0 0.0 0.0];
% Low
mu_LightIntensity_Low=[0.2 0.7 1.0 0.3 0.0 0.0 0.0 0.0 0.0 0.0];
% Middle
mu_LightIntensity_Middle=[0.0 0.0 0.0 0.4 1.0 0.3 0.0 0.0 0.0 0.0];
% High
mu_LightIntensity_High=[0.0 0.0 0.0 0.0 0.0 0.1 0.7 1.0 0.2 0.0];
% VeryHigh
mu_LightIntensity_VeryHigh=[0.0 0.0 0.0 0.0 0.0 0.0 0.2 0.4 0.7 1.0];

%%% Smoke
MaximumSmoke=10;
U_Smoke=[0 2 3 4 5 6 7 8 9 10];
% VeryLittle
mu_Smoke_VeryLittle=[1.0 0.5 0.2 0.0 0.0 0.0 0.0 0.0 0.0 0.0];
% Little
mu_Smoke_Little=[0.3 1.0 0.6 0.2 0.0 0.0 0.0 0.0 0.0 0.0];
% Middle
mu_Smoke_Middle=[0.0 0.0 0.3 0.6 1.0 0.5 0.2 0.0 0.0 0.0];
% Much
mu_Smoke_Much=[0.0 0.0 0.0 0.0 0.0 0.1 0.5 1.0 0.6 0.2];
% VeryMuch
mu_Smoke_VeryMuch=[0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.2 0.5 1.0];

%%%%% Output fuzzy
%%% Fire probability
MaximumProbability=100;
U_FireProbability=[0 25 50 75 100];
% VeryLow
mu_FireProbability_VeryLow=[1.0 0.4 0.0 0.0 0.0];
% Low
mu_FireProbability_Low=[0.3 1.0 0.2 0.0 0.0];
% Middle
mu_FireProbability_Middle=[0.0 0.4 1.0 0.3 0.0];
% High
mu_FireProbability_High=[0.0 0.0 0.5 1.0 0.3];
% VeryHigh
mu_FireProbability_VeryHigh=[0.0 0.0 0.4 0.6 1.0];





%%%%% Fuzzy rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Rule 1
mu_ABCD=fuzzyand(mu_Temperature_VeryCold,mu_LightIntensity_VeryLow,mu_Smoke_VeryLittle);
R1=rulemakem(mu_ABCD,mu_FireProbability_VeryLow);
%%% Rule 2
mu_ABCD=fuzzyand(mu_Temperature_Warm,mu_LightIntensity_VeryHigh,mu_Smoke_Middle);
R2=rulemakem(mu_ABCD,mu_FireProbability_High);
%%% Rule 3
mu_ABCD=fuzzyand(mu_Temperature_Cold,mu_LightIntensity_VeryLow,mu_Smoke_Much);
R3=rulemakem(mu_ABCD,mu_FireProbability_Low);
%%% Rule 4
mu_ABCD=fuzzyand(mu_Temperature_Cool,mu_LightIntensity_Middle,mu_Smoke_Little);
R4=rulemakem(mu_ABCD,mu_FireProbability_VeryLow);
%%% Rule 5
mu_ABCD=fuzzyand(mu_Temperature_VeryCold,mu_LightIntensity_High,mu_Smoke_Middle);
R5=rulemakem(mu_ABCD,mu_FireProbability_Low);
%%% Rule 6
mu_ABCD=fuzzyand(mu_Temperature_Cold,mu_LightIntensity_Middle,mu_Smoke_Much);
R6=rulemakem(mu_ABCD,mu_FireProbability_Middle);
%%% Rule 7
mu_ABCD=fuzzyand(mu_Temperature_Cool,mu_LightIntensity_High,mu_Smoke_Little);
R7=rulemakem(mu_ABCD,mu_FireProbability_VeryLow);
%%% Rule 8
mu_ABCD=fuzzyand(mu_Temperature_VeryCold,mu_LightIntensity_Middle,mu_Smoke_Middle);
R8=rulemakem(mu_ABCD,mu_FireProbability_Low);
%%% Rule 9
mu_ABCD=fuzzyand(mu_Temperature_Cold,mu_LightIntensity_High,mu_Smoke_Much);
R9=rulemakem(mu_ABCD,mu_FireProbability_Middle);
%%% Rule 10
mu_ABCD=fuzzyand(mu_Temperature_Nice,mu_LightIntensity_VeryHigh,mu_Smoke_Middle);
R10=rulemakem(mu_ABCD,mu_FireProbability_Middle);
%%% Rule 11
mu_ABCD=fuzzyand(mu_Temperature_Cool,mu_LightIntensity_VeryLow,mu_Smoke_VeryMuch);
R11=rulemakem(mu_ABCD,mu_FireProbability_Low);
%%% Rule 12
mu_ABCD=fuzzyand(mu_Temperature_Nice,mu_LightIntensity_Middle,mu_Smoke_Little);
R12=rulemakem(mu_ABCD,mu_FireProbability_Low);
%%% Rule 13
mu_ABCD=fuzzyand(mu_Temperature_Warm,mu_LightIntensity_VeryLow,mu_Smoke_Middle);
R13=rulemakem(mu_ABCD,mu_FireProbability_Middle);
%%% Rule 14
mu_ABCD=fuzzyand(mu_Temperature_Hot,mu_LightIntensity_Low,mu_Smoke_Much);
R14=rulemakem(mu_ABCD,mu_FireProbability_High);
%%% Rule 15
mu_ABCD=fuzzyand(mu_Temperature_Warm,mu_LightIntensity_Middle,mu_Smoke_VeryMuch);
R15=rulemakem(mu_ABCD,mu_FireProbability_VeryHigh);
%%% Rule 16
mu_ABCD=fuzzyand(mu_Temperature_Warm,mu_LightIntensity_VeryHigh,mu_Smoke_Middle);
R16=rulemakem(mu_ABCD,mu_FireProbability_High);
%%% Rule 17
mu_ABCD=fuzzyand(mu_Temperature_Hot,mu_LightIntensity_Middle,mu_Smoke_Much);
R17=rulemakem(mu_ABCD,mu_FireProbability_VeryHigh);
%%% Rule 18
mu_ABCD=fuzzyand(mu_Temperature_Warm,mu_LightIntensity_High,mu_Smoke_Little);
R18=rulemakem(mu_ABCD,mu_FireProbability_Middle);
%%% Rule 19
mu_ABCD=fuzzyand(mu_Temperature_Hot,mu_LightIntensity_Low,mu_Smoke_Middle);
R19=rulemakem(mu_ABCD,mu_FireProbability_Middle);
%%% Rule 20
mu_ABCD=fuzzyand(mu_Temperature_Hot,mu_LightIntensity_VeryHigh,mu_Smoke_VeryMuch);
R20=rulemakem(mu_ABCD,mu_FireProbability_VeryHigh);

%%% Aggregation of rules 
R=totalrule(R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16,R17,R18,R19,R20);





%%%%% Initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Node
for i=1:NodeNumber
    NodeList(i,1)=i;
    NodeList(i,2)=round(rand(1)*Network_Length);
    if NodeList(i,2)<=180
        NodeList(i,2)=181;
    end;
    if NodeList(i,2)>=1820
        NodeList(i,2)=1820;
    end;    
    
    NodeList(i,3)=round(rand(1)*Network_Width);
    if NodeList(i,3)<=180
        NodeList(i,3)=181;
    end;
    if NodeList(i,3)>=1820
        NodeList(i,3)=1820;
    end; 
    
    NodeList(i,4)=InitialNodeEnergy;
end;

%%% DataGenerationList
for i=1:DataGenerationNumber
    DataGenerationList(i,1)=round(rand(1)*200);
    DataGenerationList(i,2)=round(rand(1)*1500);
    DataGenerationList(i,3)=round(rand(1)*10);
    DataGenerationList(i,4)=round(rand(1)*100);
end;

%%% Set RandomRoundList_Flag
i=ShowRandom_ShowSequential_StartNumber;
while i<=ShowRandom_ShowSequential_FinishNumber
    RandomRoundList_Flag(i,1)=1;
        
    i=i+ShowRandom_ShowSequential_StepNumber;
end;
for i=1:RoundCount
    if mod(i,ShowRandom_StepNumber)==0
        RandomRoundList_Flag(i,1)=1;
    end;
end;





%%%%% Cycle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Continue_Flag=1;
RoundNumber=1;
while (Continue_Flag==1)&&(RoundNumber<=RoundCount)

    %%% NodeConsumptionEnergy
    NodeConsumptionEnergy=zeros(NodeNumber,1);
    for i=1:NodeNumber
        NodeConsumptionEnergy(i,1)=NodeList(i,4);
    end;  
    
    %%% Sense data by nodes
    if (RoundNumber>15)&&(mod(RoundNumber,SenseNodeDataIntervalTime)==0)
        
        for i=1:NodeNumber
            NodeList(i,6)=DataGenerationList(DataGenerationList_Navigator,1);
            NodeList(i,7)=DataGenerationList(DataGenerationList_Navigator,2);
            NodeList(i,8)=DataGenerationList(DataGenerationList_Navigator,3);
            NodeList(i,9)=DataGenerationList(DataGenerationList_Navigator,4);
 
            NodeList(i,10)=1;
            
            % Decrease consumption energy of the nodes to sense data              
            NodeList(i,4)=NodeList(i,4)-(50*(10^(-9))*PacketSize);             
            %
            if DataGenerationList_Navigator<DataGenerationNumber
                DataGenerationList_Navigator=DataGenerationList_Navigator+1; 
            else
                DataGenerationList_Navigator=1;
            end;
        end
        
    end;

    %%% Send data of the nodes to base station    
    for i=1:NodeNumber
        if (NodeList(i,10)==1)&&(NodeList(i,4)>NodeThresholdEnergy)
    
            %%% Temperature
            Temperature=NodeList(i,6);                                                      
            if Temperature<=MaximumTemperature
                Crisp=Temperature; 
            else
                Crisp=MaximumTemperature;
            end;                            
            mu_Temperature=fuzzifysn(U_Temperature,Crisp,Temperature_Type,Temperature_ShapeFactor); 

            %%% Light intensity
            LightIntensity=NodeList(i,7);
            if LightIntensity<=MaximumLightIntensity
                Crisp=LightIntensity; 
            else
                Crisp=MaximumLightIntensity;
            end;
            mu_LightIntensity=fuzzifysn(U_LightIntensity,Crisp,LightIntensity_Type,LightIntensity_ShapeFactor);                                       
            
            %%% Smoke
            Smoke=NodeList(i,8);
            if Smoke<=MaximumSmoke
                Crisp=Smoke; 
            else
                Crisp=MaximumSmoke;
            end;
            mu_Smoke=fuzzifysn(U_Smoke,Crisp,Smoke_Type,Smoke_ShapeFactor);                                                  
            
            %%% Fire probability
            mu_FireProbability=ruleresp(R,fuzzyand(mu_Temperature,mu_LightIntensity,mu_Smoke));
            FireProbability=defuzzyg(U_FireProbability,mu_FireProbability);
                                 
            if BaseStationBuffer_Index<BaseStationBufferSize
                BaseStationBuffer_Index=BaseStationBuffer_Index+1;

                BaseStationBuffer(BaseStationBuffer_Index,1)=NodeList(i,6);                                                                                          
                BaseStationBuffer(BaseStationBuffer_Index,2)=NodeList(i,7);
                BaseStationBuffer(BaseStationBuffer_Index,3)=NodeList(i,8);
                BaseStationBuffer(BaseStationBuffer_Index,4)=NodeList(i,9);
                BaseStationBuffer(BaseStationBuffer_Index,5)=NodeList(i,2);
                BaseStationBuffer(BaseStationBuffer_Index,6)=NodeList(i,3);                    
                BaseStationBuffer(BaseStationBuffer_Index,7)=FireProbability;
            end;
                        
            % Decrease consumption energy of sended data to base station 
            Distance=sqrt(((NodeList(i,2)-BaseStation(1))^2)+((NodeList(i,3)-BaseStation(2))^2));
            if Distance<=d0
                NodeList(i,4)=NodeList(i,4)-(50*(10^(-9))*PacketSize+10*(10^(-11))*PacketSize*(Distance^2));
            else
                NodeList(i,4)=NodeList(i,4)-(50*(10^(-9))*PacketSize+13*(10^(-16))*PacketSize*(Distance^4));
            end;
            
            % Update NodeList
            NodeList(i,10)=0;
            NodeList(i,11)=1;
            NodeList(i,12)=FireProbability;
            
        end;
    end;     
    
    %%% TotalRoundList
    TotalRoundList(RoundNumber,1)=RoundNumber;    
    % 
    Distance=zeros(1,NodeNumber^2);
    Distance_Index=0;
    for i=1:NodeNumber
        for j=1:NodeNumber
            if i<j
                Distance_Index=Distance_Index+1;
                
                Distance_Value=sqrt(((NodeList(i,2)-NodeList(j,2))^2)+((NodeList(i,3)-NodeList(j,3))^2));
                Distance(1,Distance_Index)=Distance_Value;
            end;
        end;
    end;
    TotalRoundList(RoundNumber,2)=min(Distance(1,1:Distance_Index)); 
    %
    Distance=zeros(1,NodeNumber^2);
    Distance_Index=0;
    for i=1:NodeNumber
        for j=1:NodeNumber
            if i<j
                Distance_Index=Distance_Index+1;
                
                Distance_Value=sqrt(((NodeList(i,2)-NodeList(j,2))^2)+((NodeList(i,3)-NodeList(j,3))^2));
                Distance(1,Distance_Index)=Distance_Value;
            end;
        end;
    end;
    TotalRoundList(RoundNumber,3)=max(Distance(1,1:Distance_Index)); 
    %
    Distance=zeros(1,NodeNumber^2);
    Distance_Index=0;
    for i=1:NodeNumber
        for j=1:NodeNumber
            if i<j
                Distance_Index=Distance_Index+1;
                
                Distance_Value=sqrt(((NodeList(i,2)-NodeList(j,2))^2)+((NodeList(i,3)-NodeList(j,3))^2));
                Distance(1,Distance_Index)=Distance_Value;
            end;
        end;
    end;
    TotalRoundList(RoundNumber,4)=round((sum(Distance(1,1:Distance_Index)))/NodeNumber);           
    %
    Sum=0;
    for i=1:NodeNumber
        Sum=Sum+NodeList(i,4);
    end;
    if (Sum/NodeNumber)>NodeThresholdEnergy
        TotalRoundList(RoundNumber,5)=Sum/NodeNumber;    
    else
        TotalRoundList(RoundNumber,5)=NodeThresholdEnergy;
    end;
    %
    for i=1:NodeNumber
        NodeConsumptionEnergy(i,1)=NodeConsumptionEnergy(i,1)-NodeList(i,4);
    end;    
    Sum=0;
    for i=1:NodeNumber
        Sum=Sum+NodeConsumptionEnergy(i,1);
    end;
    TotalRoundList(RoundNumber,6)=Sum;    
    %
    TotalRoundList(RoundNumber,7)=TotalRoundList(RoundNumber,6)/NodeNumber;
    %
    Count=0;
    for i=1:NodeNumber
        if NodeList(i,4)>NodeThresholdEnergy
            Count=Count+1;
        end;
    end;
    TotalRoundList(RoundNumber,8)=Count; 
    %
    TotalRoundList(RoundNumber,9)=NodeNumber-TotalRoundList(RoundNumber,8);        

    %%% RandomRoundList
    if RandomRoundList_Flag(RoundNumber,1)==1
        RandomRoundList_Index=RandomRoundList_Index+1;
        
        RandomRoundList(RandomRoundList_Index,1)=TotalRoundList(RoundNumber,1);        
        RandomRoundList(RandomRoundList_Index,2)=TotalRoundList(RoundNumber,2);
        RandomRoundList(RandomRoundList_Index,3)=TotalRoundList(RoundNumber,3);
        RandomRoundList(RandomRoundList_Index,4)=TotalRoundList(RoundNumber,4);
        RandomRoundList(RandomRoundList_Index,5)=TotalRoundList(RoundNumber,5);
        RandomRoundList(RandomRoundList_Index,6)=TotalRoundList(RoundNumber,6);
        RandomRoundList(RandomRoundList_Index,7)=TotalRoundList(RoundNumber,7);        
        RandomRoundList(RandomRoundList_Index,8)=TotalRoundList(RoundNumber,8);        
        RandomRoundList(RandomRoundList_Index,9)=TotalRoundList(RoundNumber,9);
    end;
    
    %%% Check dead state of the nodes
    for i=1:NodeNumber
        if NodeList(i,4)<NodeThresholdEnergy
            NodeList(i,5)=RoundNumber;    
        end;
    end; 
    
    %%% Check dead state of the all nodes
    if TotalRoundList(RoundNumber,9)>round(NodeNumber/2)
        Continue_Flag=0;
    end;    
    
    %%%%% Display the chart of the conditions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    figure(1);
    
    hold on;
    
    for i=1:NodeNumber
        plot(NodeList(i,2),NodeList(i,3),'o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',5);

        if (NodeList(i,12)>=0)&&(NodeList(i,12)<=25)
            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),175);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level1,'MarkerFaceColor',Color_Level1,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),150);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level1,'MarkerFaceColor',Color_Level1,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),125);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level1,'MarkerFaceColor',Color_Level1,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),100);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level1,'MarkerFaceColor',Color_Level1,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),75);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level1,'MarkerFaceColor',Color_Level1,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),50);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level1,'MarkerFaceColor',Color_Level1,'MarkerSize',1); 

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),25);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level1,'MarkerFaceColor',Color_Level1,'MarkerSize',1); 
        elseif (NodeList(i,12)>25)&&(NodeList(i,12)<=50)
            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),175);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level2,'MarkerFaceColor',Color_Level2,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),150);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level2,'MarkerFaceColor',Color_Level2,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),125);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level2,'MarkerFaceColor',Color_Level2,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),100);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level2,'MarkerFaceColor',Color_Level2,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),75);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level2,'MarkerFaceColor',Color_Level2,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),50);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level2,'MarkerFaceColor',Color_Level2,'MarkerSize',1); 

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),25);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level2,'MarkerFaceColor',Color_Level2,'MarkerSize',1); 
        elseif (NodeList(i,12)>50)&&(NodeList(i,12)<=75)
            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),175);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level3,'MarkerFaceColor',Color_Level3,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),150);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level3,'MarkerFaceColor',Color_Level3,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),125);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level3,'MarkerFaceColor',Color_Level3,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),100);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level3,'MarkerFaceColor',Color_Level3,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),75);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level3,'MarkerFaceColor',Color_Level3,'MarkerSize',1);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),50);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level3,'MarkerFaceColor',Color_Level3,'MarkerSize',1); 

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),25);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level3,'MarkerFaceColor',Color_Level3,'MarkerSize',1); 
        elseif (NodeList(i,12)>75)&&(NodeList(i,12)<=100)
            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),175);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level4,'MarkerFaceColor',Color_Level4,'MarkerSize',1.5);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),150);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level4,'MarkerFaceColor',Color_Level4,'MarkerSize',1.5);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),125);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level4,'MarkerFaceColor',Color_Level4,'MarkerSize',1.5);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),100);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level4,'MarkerFaceColor',Color_Level4,'MarkerSize',1.5);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),75);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level4,'MarkerFaceColor',Color_Level4,'MarkerSize',1.5);

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),50);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level4,'MarkerFaceColor',Color_Level4,'MarkerSize',1.5); 

            [Axis_X Axis_Y]=DrawCircle(NodeList(i,2),NodeList(i,3),25);
            plot(Axis_X,Axis_Y,'o','MarkerEdgeColor',Color_Level4,'MarkerFaceColor',Color_Level4,'MarkerSize',1.5);            
        end;
        
    end;
    
    hold off;
    
    grid on;
    title('Fire Application');
    xlabel('X');
    ylabel('Y');

    %%% Display and increase RoundNumber
    RoundNumber
    RoundNumber=RoundNumber+1;
end;





%%%%% Set NodeThresholdEnergy of the deaded nodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:NodeNumber
    if NodeList(i,4)<NodeThresholdEnergy
        NodeList(i,4)=NodeThresholdEnergy;
    end;
end;
