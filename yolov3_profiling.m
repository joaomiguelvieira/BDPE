%% Initialize
clearvars;
clc;
close all;

%% Build workspace
call_freq = fopen("call_freq.txt");

segs = 135200;
graphs.addrs = zeros(segs, 1);
graphs.freq  = zeros(segs, 1);
iter = 0;

aux = fgetl(call_freq);
while ischar(aux)
    words = strsplit(aux);
    
    iter = iter + 1;
    graphs.addrs(iter) = str2double(words(1));
    graphs.freq(iter)  = str2double(words(2));

    aux = fgetl(call_freq);
end

save("yolov3_profiling.mat");

%% Plot results 
load yolov3_profiling.mat;

figure('Position', [699, 259, 560, 300]);
bar(graphs.freq(1:4000), 'r'); hold on;
bar([zeros(4000, 1); graphs.freq(4001:end)])
set(gca,'yscale','log')
xlabel("Kernel relative address");
ylabel("Number of uses");

set(findall(gcf,'-property','FontSize'),'FontSize',12)
saveas(gcf, 'img/kernel_usage_all.eps', 'epsc');

figure('Position', [699, 259, 280, 300]);
bar(graphs.freq(1:4000), 'r')
set(gca,'yscale','log')
xlabel("Kernel relative address");
ylabel("Number of uses");
set(gca, 'YGrid', 'on', 'XGrid', 'off');

set(findall(gcf,'-property','FontSize'),'FontSize',12)
saveas(gcf, 'img/kernel_usage_zoom.eps', 'epsc');