function F=Funcion_Objetivo_PID(x)

Kp=x(1); %Constante Proporcional
Ki=x(2); %Constante Integral
Kd=x(3); %Constante Derivativa

%%%%%%% Guarda las constantes para ser usadas en simulink %%%%%%%%
save Kp; 
save Ki;
save Kd;
%%%%Restricciones según Criterios de Diseño %%%%%%
%Mp<= 4 %
%

% correr simulink e obtener Valores simulados

sprintf('Kp=%3.3f, Ki=%3.3f, Kd=%3.3f',x(1),x(2),x(3)) 
%Ssimular = sim('Stank_01',[0 1000]);

%%%%%% Conocer los parametros de simulación del modelo%%%%%

% model = 'Stank_01';
% load_system(model)
% simMode = get_param(model, 'SimulationMode')
% simMode = get_param(model, 'AbsTol')
% simMode = get_param(model, 'ZeroCross')
% simMode = get_param(model, 'SaveTime')
% simMode = get_param(model, 'TimeSaveName')
% simMode = get_param(model, 'SaveState')
% simMode = get_param(model, 'StateSaveName')
% simMode = get_param(model, 'SaveOutput')
% simMode = get_param(model, 'OutputSaveName')
% simMode = get_param(model, 'SignalLogging')
% simMode = get_param(model, 'SignalLoggingName')

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

        
%%%%%%%%%%%%%%%%%%%%%%%%%%5
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Asiganción de pesos Función Objetivo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
W_Tss=5;
W_Tr=5;
W_Tp=1;
W_err=100;
W_Peak=100;

%Peaks=W_Peak*(Peak+Mp)
Peaks=W_Peak*(Mp)
Tiempos=(W_Tss*Tss+W_Tr*Tr+W_Tp*Tp)
Errores=W_err*abs(error)

F=Tiempos + Errores + Peaks
 