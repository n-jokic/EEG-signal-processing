% 2. primer, II ciklus, zadaci za rad
close all; clear all; clc;

list_factory = fieldnames(get(groot,'factory'));
index_interpreter = find(contains(list_factory,'Interpreter'));
for i = 1:length(index_interpreter)
    default_name = strrep(list_factory{index_interpreter(i)},'factory','default');
    set(groot, default_name,'latex');
end


while (1 == 1)
  izbor = menu('PRIMER II CILUS II', 'izaberite signal', 'slika signala', ...
      '1. filter bazne linije', '2. MA filter signala', 'slika OBRADA', ...
      'sacuvati sliku OBRADA', 'odstampati sliku OBRADA', ...
      'sacuvati filtriran signal','prikaz bazne linije','kraj');
%--------------------------------------------------------------------------
if (izbor == 1) % ucitavanje signala iz fajla
    [file] = uigetfile('*.txt', 'Ucitajte signal po izboru');
    fid = fopen(file, 'r'); % otvara se fajl za citanje - 'r'
    % cita se tekstualni fajl sa podacima tipa floating point ('f'):
    [s, broj] = fscanf(fid, '%f');
    fclose(fid);

    disp(['Broj ucitanih odbiraka je ' num2str(broj)]);
    start = input('\nUnesite pocetni odbirak ' , 's');
    start = str2double(start);
  
    samples = input('\nUnesite broj odbiraka ' , 's');
    samples = str2double(samples);
  
    x = s( start:(start + samples) );
    N = length(x);
  
    fs = input('\nUnesite fs u Hz (1000 za 6.txt; 200 za 7.txt) ' , 's');
    fs = str2double(fs);
    time = (0:N-1)/fs;
    st = start/fs; % pocetni trenutak izdvojenog signala
    samp = (start+samples)/fs; % kraj izdvojenog signala
    
    % racunanje frekvencijskih karakteristika signala
    f = (fs/N)*((-N/2+1):(N/2));
    xx = abs(fft(x))/length(x );
    xxfreqshift = fftshift(xx);
    p = x;
  
end
%--------------------------------------------------------------------------
if (izbor == 2) % prikaz signala
    clf
    subplot(2,1,1);
        plot(time,x, 'black');
            xlabel('vreme [s]');
            ylabel(['EKG signal  ' num2str(file)]);
            title(['signal izdvojen od ' num2str(st) ' do '...
                num2str(samp) ' [s]']); 
            grid on;
    subplot(2,1,2); 

            plot(f,xxfreqshift, 'black');
            xlabel('ucestanost [Hz]');
            grid on;
            ylabel(['Spektar EKG signala  ' num2str(file)]);
            title(['signal izdvojen od ' num2str(st) ' do '...
                num2str(samp) ' [s]']); 
            
    disp('press space to continue...');
    pause
    close
    close
    clf
    clf
    close
end
%--------------------------------------------------------------------------
if (izbor == 3) % filter bazne linije

    alpha = input('\nUnesite pol filtra (<= 1) ' , 's');
    alpha = str2double(alpha);
    % primena filtra za odstranjivanje bazne linije
    % definisanje a i b parametara
    
    b = (1+alpha)/2*[1 -1];
    a = [1 -alpha];

    % filtriranje signala
    p = filtfilt(b, a, x);

    % frekvencijski odziv filtra
    [H1, Omega] = freqz(b, a);
    Fr = 0.5 * fs * Omega / pi;
    clf
    figure(1);
        plot(Fr, abs(H1), 'black', 'Linewidth', 1); hold on;
            grid;
            title(['pol 1.filtra = ' num2str(alpha) ]);
            xlabel('ucestanost [Hz]');
            ylabel('$\|H_1(e^{j\Omega})\|$'); 
            grid on;
    disp('press space to continue...');
    pause

    pp = abs(fft(p))/length(p);
    ppfreqshift = fftshift(pp);
    clf
    figure(2);
        subplot(2,1,1);
            plot(time, x, 'black', time, p, 'r--');
                grid on;
                xlabel('vreme [s]');
                ylabel(['EKG signal  ' num2str(file)]);
                title(['za pol 1. filtra = ' num2str(alpha) ]);
                legend('originalni', 'odstranjena bazna linija'); 
        subplot(2,1,2);
            plot(f, ppfreqshift, 'black');
                title(['Spektar filtriranog EKG signala ' num2str(file)]);
                xlabel('ucestanost [Hz]');
                axis([-fs/2 fs/2 0 max(ppfreqshift)]);
    
                grid on
    disp('press space to continue...');
    pause
    close
    close
    close
    clf
    clf
    close
end
%--------------------------------------------------------------------------
if (izbor == 4) % MA filter signala
    % implementiranje MA filtra
    order = input('\nUnesite red MA filtra ', 's');
    order = str2double(order);
    aM = [1 zeros(1,order-1)];
    bM = ones(1,order)/order;

    % filtriranje signala
    y = filtfilt(bM, aM, p);
    filtriranEKG = y;
    save filtriranEKG;

    % frekvencijski odziv
    [H2, Omega] = freqz(bM, aM);
    Fr = 0.5 * fs * Omega / pi;
    clf
    figure(1);
        plot(Fr, abs(H2), 'black', 'Linewidth', 1); hold on;
            grid;
            title(['red 2. filtra = ' num2str(order) ]);
            xlabel('ucestanost [Hz]');
            ylabel('$\|H_1(e^{j\Omega})\|$');
    disp('press space to continue...');        
    pause
    clf
    figure(2);
        subplot(2,1,1);
            plot(time, p,'black', time, y, 'r--');
                grid;
                xlabel('vreme [s]');
                ylabel(['EKG signal ' num2str(file)]);
                title(['pol 1. filtra = ' num2str(alpha) ...
                    ' red 2.filtra (MA) = ', num2str(order) ]);
                legend('originalni', 'filtriran');  
                 
    yy = abs(fft(filtriranEKG))/length(filtriranEKG);
    yyfreqshift = fftshift(yy);

    subplot(2,1,2);
        plot(f, yyfreqshift, 'black');
            title(['spektar filtriranog EKG signala ' num2str(file)]);
            xlabel('ucestanost [Hz]');
            grid on;
            axis([-fs/2 fs/2 0 max(yyfreqshift)]);
    disp('press space to continue...');
    pause
    close
    close
    close
    clf
    clf
    close
end
%--------------------------------------------------------------------------
if (izbor == 5) % prikaz
    figure(1);                                                                                                                                                  
        orient tall;
        subplot(3,1,1); % originalni signal
        plot(time,x, 'black');
           xlabel('vreme [s]');
           ylabel(['EKG signal  ' num2str(file)]);
           title(['signal izdvojen od ' num2str(st) ' do '...
               num2str(samp) ' [s]']); 
           grid on;
            
        subplot(3,1,2); % odstranjena bazna linija
        plot(time, p, 'black');
                grid on;
                xlabel('vreme [s]');
                ylabel(['EKG signal  ' num2str(file)]);
                title(['za pol 1. filtra = ' num2str(alpha) ]);
                
        
        subplot(3,1,3); % potisnut sum
        
        plot(time, y, 'black');
                grid;
                xlabel('vreme [s]');
                ylabel(['EKG signal ' num2str(file)]);
                title(['pol 1. filtra = ' num2str(alpha) ...
                    ' red 2.filtra (MA) = ', num2str(order) ]);
                
                disp('press space to continue...');
    pause
    close
    clf
    figure(2);
        orient tall;
        subplot(3,1,1); % frekvencijski odziv 1. filtra
        plot(Fr, abs(H1), 'black', 'Linewidth', 1); hold on;
            grid;
            title(['pol 1.filtra = ' num2str(alpha) ]);
            xlabel('ucestanost [Hz]');
            ylabel('$\|H_1(e^{j\Omega})\|$');
            
        subplot(3,1,2); % frekvencijski odziv 2. filtra 
        plot(Fr, abs(H2), 'black', 'Linewidth', 1); hold on;
            grid;
            title(['red 2. filtra = ' num2str(order) ]);
            xlabel('ucestanost [Hz]');
            ylabel('$\|H_1(e^{j\Omega})\|$');
        
        subplot(3,1,3); % spektar originalnog i filtriranog signala
        
        plot(f,xxfreqshift, 'black');
            xlabel('ucestanost [Hz]');
            grid on;
            ylabel(['Spektar EKG signala  ' num2str(file)]);
            title(['signal izdvojen od ' num2str(st) ' do '...
                num2str(samp) ' [s]']);
            hold on;
            
        plot(f, yyfreqshift, 'r');
            title(['spektar filtriranog EKG signala ' num2str(file)]);
            xlabel('ucestanost [Hz]');
            grid on;
            axis([-fs/2 fs/2 0 max(yyfreqshift)*3]);
            
            legend('originalni', 'odstranjena bazna linija'); 
            
            disp('press space to continue...');
            
    pause
    close
    clf
    clf
    close
 end
%--------------------------------------------------------------------------
if (izbor == 6)
    figure(1);                                                                                                                                                  
        orient tall;
        subplot(3,1,1); % originalni signal
        plot(time,x, 'black');
           xlabel('vreme [s]');
           ylabel(['EKG signal  ' num2str(file)]);
           title(['signal izdvojen od ' num2str(st) ' do '...
               num2str(samp) ' [s]']); 
           grid on;
            
        subplot(3,1,2); % odstranjena bazna linija
        plot(time, p, 'black');
                grid on;
                xlabel('vreme [s]');
                ylabel(['EKG signal  ' num2str(file)]);
                title(['za pol 1. filtra = ' num2str(alpha) ]);
                
        
        subplot(3,1,3); % potisnut sum
        
        plot(time, y, 'black');
                grid;
                xlabel('vreme [s]');
                ylabel(['EKG signal ' num2str(file)]);
                title(['pol 1. filtra = ' num2str(alpha) ...
                    ' red 2.filtra (MA) = ', num2str(order) ]);
    hold on;
    saveas(figure(1), '.\EKG_signal', 'jpg')
    
    disp('press space to continue...');
    pause
    close
    close
    figure(2);
        orient tall;
        subplot(3,1,1); % frekvencijski odziv 1. filtra
        plot(Fr, abs(H1), 'black', 'Linewidth', 1); hold on;
            grid;
            title(['pol 1.filtra = ' num2str(alpha) ]);
            xlabel('ucestanost [Hz]');
            ylabel('$\|H_1(e^{j\Omega})\|$');
            
        subplot(3,1,2); % frekvencijski odziv 2. filtra 
        plot(Fr, abs(H2), 'black', 'Linewidth', 1); hold on;
            grid;
            title(['red 2. filtra = ' num2str(order) ]);
            xlabel('ucestanost [Hz]');
            ylabel('$\|H_1(e^{j\Omega})\|$');
        
        subplot(3,1,3); % spektar originalnog i filtriranog signala
        
        plot(f,xxfreqshift, 'black');
            xlabel('ucestanost [Hz]');
            grid on;
            ylabel(['Spektar EKG signala  ' num2str(file)]);
            title(['signal izdvojen od ' num2str(st) ' do '...
                num2str(samp) ' [s]']);
            hold on;
            
        plot(f, yyfreqshift, 'r');
            title(['spektar filtriranog EKG signala ' num2str(file)]);
            xlabel('ucestanost [Hz]');
            grid on;
            axis([-fs/2 fs/2 0 max(yyfreqshift)*3]);
            
            legend('originalni', 'filtrirani'); 

     saveas(figure(2), '.\SPEKTAR', 'jpg');
     
     disp('press space to continue...');
    pause
    close
    close
    clf
    clf
    close
end
%--------------------------------------------------------------------------
if (izbor == 7) % stampa sliku OBRADA.jpeg
    figure(1);                                                                                                                                                  
        orient tall;
        subplot(3,1,1); % originalni signal
        plot(time,x, 'black');
           xlabel('vreme [s]');
           ylabel(['EKG signal  ' num2str(file)]);
           title(['signal izdvojen od ' num2str(st) ' do '...
               num2str(samp) ' [s]']); 
           grid on;
            
        subplot(3,1,2); % odstranjena bazna linija
        plot(time, p, 'black');
                grid on;
                xlabel('vreme [s]');
                ylabel(['EKG signal  ' num2str(file)]);
                title(['za pol 1. filtra = ' num2str(alpha) ]);
                
        
        subplot(3,1,3); % potisnut sum
        
        plot(time, y, 'black');
                grid;
                xlabel('vreme [s]');
                ylabel(['EKG signal ' num2str(file)]);
                title(['pol 1. filtra = ' num2str(alpha) ...
                    ' red 2.filtra (MA) = ', num2str(order) ]);
    hold on;
    print -dwinc 
    close
    disp('press space to continue...');
    pause
    figure(2);
        orient tall;
        subplot(3,1,1); % frekvencijski odziv 1. filtra
        plot(Fr, abs(H1), 'black', 'Linewidth', 1); hold on;
            grid;
            title(['pol 1.filtra = ' num2str(alpha) ]);
            xlabel('ucestanost [Hz]');
            ylabel('$\|H_1(e^{j\Omega})\|$');
            
        subplot(3,1,2); % frekvencijski odziv 2. filtra 
        plot(Fr, abs(H2), 'black', 'Linewidth', 1); hold on;
            grid;
            title(['red 2. filtra = ' num2str(order) ]);
            xlabel('ucestanost [Hz]');
            ylabel('$\|H_1(e^{j\Omega})\|$');
        
        subplot(3,1,3); % spektar originalnog i filtriranog signala
        
        plot(f,xxfreqshift, 'black');
            xlabel('ucestanost [Hz]');
            grid on;
            ylabel(['Spektar EKG signala  ' num2str(file)]);
            title(['signal izdvojen od ' num2str(st) ' do '...
                num2str(samp) ' [s]']);
            hold on;
            
        plot(f, yyfreqshift, 'r');
            title(['spektar filtriranog EKG signala ' num2str(file)]);
            xlabel('ucestanost [Hz]');
            grid on;
            axis([-fs/2 fs/2 0 max(yyfreqshift)*3]);
            
            legend('originalni', 'filtrirani'); 
            
    print -dwinc 
    disp('press space to continue...');
    pause
    close
    close
    clf
    clf
    close
end
%--------------------------------------------------------------------------
if (izbor == 8) % cuva se filtriran signal
    save('filtriranEKG', 'y');

    fid = fopen('filtriran EKG.txt', 'a');  % txt file (Word pad)
    fprintf(fid, ['\nfiltriran EKG signal ', num2str(file), '\n']);
    fprintf(fid, '\n');
    fprintf(fid, '%8.2f  \n', y');
    fclose(fid);
    
    disp('press space to continue...');
    pause
    close
    close
    clf
    clf
    close
end
%--------------------------------------------------------------------------
if (izbor == 9)
    figure(2);
    plot(time, x, 'black', time, x - p, 'r--');
        grid on;
        xlabel('vreme [s]');
        ylabel(['EKG signal  ' num2str(file)]);
        title(['za pol 1. filtra = ' num2str(alpha) ]);
        legend('originalni', 'estimirana bazna linija'); 
    
   disp('press space to continue...');
    pause
    close
    close
    clf
    clf
    close
end
%--------------------------------------------------------------------------
if (izbor == 10)
    clc
    close
    clear
return
end
%--------------------------------------------------------------------------
end