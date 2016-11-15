clc
clear all
%Kp=0.810; Ki=0.173; Kd=-0.506;
load('Kp.mat')
load('Kd.mat')
load('Ki.mat')
simOut = sim('Stank_01','SimulationMode','normal','AbsTol','auto',...
            'StopTime', '1000', ... 
            'ZeroCross','on', ...
            'SaveTime','on','TimeSaveName','tout', ...
            'SaveState','off','StateSaveName','xout',...
            'SaveOutput','on','OutputSaveName','yout',...
            'SignalLogging','on','SignalLoggingName','logsout', 'ReturnWorkspaceOutputs', 'on')      
        
TransResp = simOut.get('TransResp')

Tiempo = TransResp.time;
Amplitud = TransResp.signals.values;
figure(1)
plot(Tiempo,Amplitud)
grid

yfinal=50 % SetPoint
Parametros = stepinfo(Amplitud,Tiempo)
Vest=(Parametros.SettlingMax + Parametros.SettlingMin)/2;
error= yfinal-Vest;
Parametros = stepinfo(Amplitud,Tiempo,yfinal)
Tss=Parametros.SettlingTime;    %Tiempo de Estabilización
Tr=Parametros.RiseTime;         %Tiempo de Levantamiento
Tp=Parametros.PeakTime;         %Tiempo de Sobre impulso
Mp=Parametros.Overshoot;        %Sobre Impulso [%]
Peak=Parametros.Peak;           %Pico Maximo


W_Tss=1;
W_Tr=0.8;
W_Tp=0.5;
W_err=100;
W_Peak=1;

Peaks=Peak+Mp
Tiempos=(W_Tss*Tss+W_Tr*Tr+W_Tp*Tp)
Errores=W_err*abs(error)

F=Tiempos + Errores+Peaks
