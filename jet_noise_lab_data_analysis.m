clear
%channel 0:microphone data
%channel 1:nothing
%channel 2:square wave 261Hz
%channel 3:time signal

%importing the data-------------------------------------------------------

%testhigh.dat
testhigh = load("testhigh.dat");

%splitting the channels
testhigh_mc = testhigh(1, :);
testhigh_sq = testhigh(3, :);
testhigh_time = testhigh(4, :);

%testhigh80.dat
testhigh80 = load("testhigh80.dat");

%splitting the channels
testhigh80_mc = testhigh80(1, :);
testhigh80_sq = testhigh80(3, :);
testhigh80_time = testhigh80(4, :);

%processing the data -----------------------------------------------------

%testing with square wave
Pa_testhigh_sq = convert_to_Pressure(testhigh_sq);
[fft_testhigh_sq, fft_freq_sq] = performFFT(Pa_testhigh_sq);

%testhigh
Pa_testhigh_mc = convert_to_Pressure(testhigh_mc);
[fft_testhigh_mc,fft_freq_highmc] = performFFT(Pa_testhigh_mc);

%testhigh80

Pa_testhigh80_mc = convert_to_Pressure(testhigh80_mc);
[fft_testhigh80_mc,fft_freq_high80mc] = performFFT(Pa_testhigh80_mc);

%creating the plots ------------------------------------------------------

figure;
plot(testhigh_time(1:2000),testhigh_sq(1:2000));
ylabel('Frequency / Hz');
xlabel('Time / s');
title('Square Wave Signal');

%testing with square wave
% Create a plot
figure;
plot(fft_freq_sq, fft_testhigh_sq);

% Add labels and title
ylabel('Signal Intensity / Pa');
xlabel('Frequencies / Hz');
title('Square Wave Fourier Transform');
%ylim([0,1e+5]);

%testhigh
% Create a plot
figure;
plot(fft_freq_highmc, fft_testhigh_mc);
ylabel('Signal Intensity / Pa');
xlabel('Frequencies / Hz');
title('Turbojet Noise Pressure in Frequency Space at Idle');

%testhigh80
% Create a plot
figure;
plot(fft_freq_high80mc, fft_testhigh80_mc);
ylabel('Signal Intensity / Pa');
xlabel('Frequencies / Hz');
title('Turbojet Noise Pressure in Frequency Space 80% Throttle');

%Functions ----------------------------------------------------------------

%Function for converting the mV recorded data into decibels
function pressure = convert_to_Pressure(signalData)
    %conversion factor from V to pascals
    V_to_Pa_conversion = 0.0495;

    %conversion factor for dB calculation
    It = 2e-5;  % Reference sound intensity in Pa

    %converting V to Pa
    pressure = signalData / V_to_Pa_conversion;
    %pressure(pressure == 0) = 1e-10; % Add a small offset


    %USE MAX FUNCTOON
    % Calculate Sound Pressure Level (SPL)
    maxSPL = 20 * log10(max(abs(pressure)) / It);

    %USE RMS FUNCTION
    % Calculate root-mean-square (RMS) value

    %rmsValue = rms(pressure);
    decibel = 20 * log10((abs(pressure)) / It);
    rmsValue = rms(decibel);
 
    disp(['Maximum SPL: ', num2str(maxSPL), ' dB']);
    disp(['RMS Value: ', num2str(rmsValue), ' dB']);
end

%Function performing an fft taking the sampling frequency as 40000 and the duration as 1
function [transformed_data, frequencies] = performFFT(input_data)
    %setting constants
    Fs = 40000; %sampling frequency
    L = 1; %signal duration

    n = Fs * L; %number of samples

    %performing the fft
    fft_result = fft(input_data, n);
    %fft is symmetric so we take out the second half of values
    fft_result = fft_result(1:n/2);

    %converting from k space to frequency space
    %(multiplying the array of k values by the frequency resolution
    frequencies = (0:n/2-1)*Fs/n;

    %taking the absolute values so remove the complex aspect
    transformed_data = abs(fft_result);
    transformed_data = transformed_data/n;
    transformed_data(2:end-1) = 2*transformed_data(2:end-1);
end