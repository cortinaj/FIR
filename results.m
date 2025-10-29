%% ============================================================
%  FIR Filter Simulation Results Plot
%  Source: Vivado testbench console log (serial FIR filter)
%  Date: 10/29/2025
%  ============================================================

% --- Raw data from simulation log (ns, x_in, y_out) ---
data = [
    95000,      0,           0;
    255000,   8816,   2103881451;
    415000,  14734,   6350912922;
    575000, -11557,   7740911403;
    735000,   1879,   8313522813;
    895000, -14265,   9092735541;
   1055000,  -8816,   6504318799;
   1215000, -10268,   7639108081;
   1375000, -11557,   8605774633;
   1535000, -10268,   9729441070;
   1695000,  -8816,   3699642419;
   1855000, -14265,   6986095691;
   2015000,   1879,   6337880358;
   2175000, -11557,   5929360538;
   2335000,  14734,  12364416327;
   2495000,   8816,   8938296522
];

% --- Extract columns ---
time_ns = data(:,1);
x_in    = data(:,2);
y_out   = data(:,3);

% --- Convert time to microseconds for readability ---
time_us = time_ns * 1e-3;

%% ------------------------------------------------------------
%  1️⃣  Plot time-domain waveforms
% -------------------------------------------------------------
figure('Name','FIR Filter Results','Color','w');
subplot(2,1,1);
plot(time_us, x_in, '-o','LineWidth',1.3);
xlabel('Time (\mus)');
ylabel('Input x_{in}');
title('FIR Filter Input (x_{in})');
grid on;

subplot(2,1,2);
plot(time_us, y_out, '-o','Color',[0.2 0.4 0.8],'LineWidth',1.3);
xlabel('Time (\mus)');
ylabel('Output y_{out}');
title('FIR Filter Output (y_{out})');
grid on;

sgtitle('Serial FIR Filter Simulation Results');

%% ------------------------------------------------------------
%  2️⃣  Normalize and compute frequency response (optional)
% -------------------------------------------------------------
% Remove DC offset, scale for FFT
x_norm = double(x_in) / max(abs(x_in));
y_norm = double(y_out) / max(abs(y_out));

N = length(y_out);
fs = 1 / ( (time_ns(2)-time_ns(1)) * 1e-9 );   % sample frequency from ns spacing
f = linspace(0, fs/2, N/2+1);

% Compute FFT magnitude
Y = fft(y_norm .* hann(N));  % use Hann window for clarity
magY = abs(Y(1:N/2+1));

figure('Name','FIR Filter Frequency Spectrum','Color','w');
plot(f/1e3, 20*log10(magY / max(magY)), 'LineWidth',1.4);
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
title('Output Spectrum of FIR Filter');
grid on;

fprintf('Effective sample rate: %.3f MHz\n', fs/1e6);
