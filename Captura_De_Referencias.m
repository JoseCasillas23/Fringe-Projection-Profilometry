%Programa de Captura de Planos de Referencias 
clc;    clear all; close all; 

%% Parametros Iniciales - Image Acquisition
%Camara
%!Codigo de la extension Image Acquision
%!No se modifica a menos que cambie la camara o se requieran agregar mas
%franjas
    vid = videoinput('winvideo',2,'MJPG_1920x1080');
    src = getselectedsource(vid);
    vid.FramesPerTrigger = 4;
    vid.ReturnedColorspace = 'grayscale';
    Cap(1080,1920,4)=single(0);

 %% Creacion de Franjas
%!Parametros del patron como pixeles, periodo, amplitud e intensidad
%inicial
%! I0 y A son modificables siempre y cuando se requiera otra escala
        [x,y] = meshgrid(-450:450,-450:450);
        T = 50; %Periodo
        I0 = .5;
        A = .5;
        Fase = 0;
%% Posicionamiento en dos monitores
%! Codigo para mandar las franjas al proyector
        MP = get(0, 'MonitorPositions');
        N = size(MP, 1);
        newPosition = MP(1,:);  
        if size(MP, 1) == 1
            % Single monitor -- do nothing.   
        else
            % Multiple monitors - shift to the Nth monitor.
            newPosition(1) = newPosition(1) + MP(N,1);
        end
    % Posicionamiento de la Figura en el Proyector
        fh = figure('units', 'pixels');
        fh.set('Position', newPosition, 'units', 'normalized');
        fh.WindowState = 'maximized'; % Maximize with respect to current monitor.

%% Captura de Imagenes
for ext1=1:4
    %Desplegado de Patron de Franjas
        I = I0+A*cos(2*pi*x/T+(ext1-1)*pi/2);
        imagesc(I);
        %Pantalla completa
        set(gcf,'MenuBar','none')
        set(gca,'DataAspectRatioMode','auto')
        set(gca,'Position',[0 0 1 1])
        set(gcf,'WindowState', 'fullscreen');
        colormap(gray); axis off; title(num2str(ext1));
    % Captura - Inicio
        pause(.1);
        start(vid);
        a = single(getdata(vid));
        fr=squeeze(mean(a,4));
        Cap(:,:,ext1)=fr;
    % Captura - Final
end

%% Desplegado
figure;
for ext1=1:4
    imagesc(Cap(:,:,ext1)); colorbar; colormap("gray"); title(num2str(ext1));
    getframe
end

%% Procesamiento Franjas
I1 = Cap(:,:,1); 
I2 = Cap(:,:,2); 
I3 = Cap(:,:,3); 
I4 = Cap(:,:,4);
phi = atan2((I4-I2),(I1-I3));
figure; 
    subplot(2,2,1); imagesc(I1); colorbar; colormap(gray); 
    subplot(2,2,2); imagesc(I2); colorbar; colormap(gray); 
    subplot(2,2,3); imagesc(I3); colorbar; colormap(gray); 
    subplot(2,2,4); imagesc(I4); colorbar; colormap(gray);    
figure; 
    imagesc(phi); colorbar; colormap("gray");
    
    
 save("ref.mat");
