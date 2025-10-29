%% ===============================================================
%  FIR Filter Simulation Analysis
%  For serial FIR testbench log with columns:
%     tone_idx , time_ns , x_in , y_out
%  ===============================================================
clc; clear; close all;

%% === Step 1: Load or manually paste data ===
% If you have a CSV file, use this:
% data = readmatrix('fir_multitone_output.csv');

% Otherwise, paste your console data here:
data = [
% tone_idx , time_ns , x_in , y_out
0,5615000,0,0;
0,5625000,0,0;
0,5635000,0,0;
0,5645000,0,0;
0,5655000,0,0;
0,5665000,0,0;
0,5675000,0,0;
0,5685000,0,0;
0,5695000,0,0;
0,5705000,0,0;
0,5715000,0,0;
0,5725000,0,0;
1,5735000,0,0;
1,6375000,14265,6191030097;
1,7015000,8816,6191030097;
1,7655000,-8816,8609620428;
1,8295000,-14265,9042918854;
1,8935000,0,8609620428;
1,9575000,14265,6191030097;
1,10215000,8816,6191030097;
1,10855000,0,8609620428;
1,10865000,0,8753385350;
1,10875000,0,4746155039;
1,10885000,0,9085489104;
1,10895000,0,5341987391;
1,10905000,0,5606897902;
1,10915000,0,1343829899;
1,10925000,0,5395967338;
1,10935000,0,1650014954;
1,10945000,0,2235172157;
1,10955000,0,2494960658;
1,10965000,0,1902104537;
1,10975000,0,940693212;
1,10985000,0,4615816589;
1,10995000,0,575947897;
1,11005000,0,370745007;
1,11015000,0,996208;
1,11025000,0,3968041202;
1,11035000,0,0
];

tone_idx = data(:,1);
time_ns  = data(:,2);
x_in     = data(:,3);
y_out    = data(:,4);

%% === Step 2: Basic info ===
tones = unique(tone_idx);
num_tones = numel(tones);

fprintf('Loaded %d tones with %d samples total.\n', num_tones, numel(x_in));

%% === Step 3: Plot time-domain for each tone ===
figure('Color','w');
for k = 1:num_tones
    idx = (tone_idx == tones(k));
    subplot(num_tones,1,k);
    plot(time_ns(idx)*1e-3, x_in(idx), 'b','LineWidth',1.2); hold on;
    plot(time_ns(idx)*1e-3, y_out(idx)/max(abs(y_out)), 'r','LineWidth',1.2);
    xlabel('Time (\mus)');
    ylabel('Amplitude');
    title(sprintf('Tone %d — Time-domain Input/Output', tones(k)));
    legend('x_{in}','y_{out} (normalized)');
    grid on;
end
sgtitle('FIR Filter Time-Domain Responses');

%% === Step 4: Compute gain for each tone ===
amp_in  = zeros(num_tones,1);
amp_out = zeros(num_tones,1);

for k = 1:num_tones
    idx = (tone_idx == tones(k));
    % skip zeros at start
    valid_idx = find(abs(x_in(idx)) > 0, 1):numel(find(idx));
    if isempty(valid_idx)
        amp_in(k)  = 0;
        amp_out(k) = 0;
    else
        amp_in(k)  = max(abs(x_in(idx)));
        amp_out(k) = max(abs(y_out(idx)));
    end
end

gain_db = 20*log10(amp_out ./ max(amp_in));
freqs_norm = linspace(0,1,num_tones);   % normalized frequency range

%% === Step 5: Plot frequency response ===
figure('Color','w');
plot(freqs_norm*pi, gain_db, 'b-o','LineWidth',1.5);
xlabel('Normalized Frequency (\times \pi rad/sample)');
ylabel('Magnitude (dB)');
title('FIR Filter Frequency Response (from Simulation)');
ylim([-40 100]);
xlim([0 1.05*pi]);
grid on;
