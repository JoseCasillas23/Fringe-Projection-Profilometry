%#Comentarios para realizar cambios
%#Realizarlos antes de tomar las medidas

%% Limpieza de Consola
clear all; close all;

%% Cargar Datos de Referencia
%#Tomar una nueva referencia
    load("ref.mat");
    ref = phi;

%% Inicializar Camara
    vid = videoinput('winvideo',2,'MJPG_1920x1080');%#Cambiar Calidad de la Camara
    src = getselectedsource(vid);
    vid.FramesPerTrigger = 10;
    vid.ReturnedColorspace = 'grayscale';
    Cap(1080,1920,10)=single(0);

%% Patron de Franjas a Proyectar
    %Patron de Franjas
        [x,y] = meshgrid(-250:250,-250:250);%# Bajar el periodo de las franjas
        T = 50; %Periodo
        I0 = .5;
        A = .5;
        Fase = 0;

  %% Posicionar Imagenes en un 2nd Monitor
    %Parametros Para Posicionamiento de la Figura en el Proyector
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

%% Desplegado de Imagenes Capturadas
    figure;
    for ext1=1:4
        imagesc(Cap(:,:,ext1)); colorbar; colormap("gray"); title(num2str(ext1));
        getframe
    end

%% Procesamiento Franjas
    I1=Cap(:,:,1); 
    I2=Cap(:,:,2); 
    I3=Cap(:,:,3); 
    I4=Cap(:,:,4);
    
    phi=atan2((I4-I2),(I1-I3));
    
    figure; 
    %#Cambiar ROI para el nuevo sistema ROI Actual = 265:484,430:828
        subplot(2,2,1); imagesc(I1(250:650,850:1250),[0 255]); colorbar; colormap(gray); 
        subplot(2,2,2); imagesc(I2(250:650,850:1250),[0 255]); colorbar; colormap(gray); 
        subplot(2,2,3); imagesc(I3(250:650,850:1250),[0 255]); colorbar; colormap(gray); 
        subplot(2,2,4); imagesc(I4(250:650,850:1250),[0 255]); colorbar; colormap(gray); 
    
    figure; imagesc(phi(250:650,850:1250)); colorbar; colormap("gray");
    Ampl=sqrt((I4-I2).^2+(I1-I3).^2);

    %% Aplicar Mascara
    %#Cambiar Parametros de la Mascara 
    Mask=Ampl*0;
    Mask(Ampl>40)=1;
    Rest=phi.*Mask;
    
%% Ecuacion para Obtener el Perfil
    phi_s=angle(exp(-1i*Rest).*exp(1i*ref)).*Mask;


%% ROI
%#Actualizar los parametros ROI, Actual = 300:800,550:1400
%     reg=phi_s(250:650,850:1250);
%     figure; imagesc(reg,[-3 3]); colorbar; colormap("jet");
%     figure; surf(reg); colorbar; colormap("jet"); shading interp; view(152,78)


