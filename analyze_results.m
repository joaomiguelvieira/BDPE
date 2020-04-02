clc
clearvars

%% obtain baseline
% initialize arrays
cache_hits_baseline   = 0;
cache_misses_baseline = 0;
number_of_bdp         = 42658304;

% extract information from the gem5 output file
stats = fopen("darknet_baseline_separate_file_out/stats.txt");

aux = fgetl(stats);
while ischar(aux)
    if contains(aux, "system.cpu.dcache.ReadReq_hits::total")
        words = strsplit(aux);
        cache_hits_baseline = str2double(words(2));
    end

    if contains(aux, "system.cpu.dcache.ReadReq_misses::total")
        words = strsplit(aux);
        cache_misses_baseline = str2double(words(2));
    end

    aux = fgetl(stats);
end

mem_accesses_baseline = cache_hits_baseline + cache_misses_baseline;

fclose(stats);

%% read results for accelerated systems
% initialize arrays
hit_rates    = ["10", "20", "30", "40", "50", "real"];
cache_hits   = zeros(length(hit_rates), 1);
cache_misses = zeros(length(hit_rates), 1);
mem_accesses = zeros(length(hit_rates), 1);
mem_spare    = zeros(length(hit_rates), 1);

% extract information from the gem5 output files
for i = 1:length(hit_rates)
    filename = strcat("m5out_accelerated_hit_rate_", hit_rates(i), "/stats.txt");
    stats = fopen(filename);
    
    aux = fgetl(stats);
    while ischar(aux)
        if contains(aux, "system.cpu.dcache.ReadReq_hits::total")
            words = strsplit(aux);
            cache_hits(i) = str2double(words(2));
        end
        
        if contains(aux, "system.cpu.dcache.ReadReq_misses::total")
            words = strsplit(aux);
            cache_misses(i) = str2double(words(2));
        end
        
        aux = fgetl(stats);
    end
    
    mem_accesses(i) = cache_hits(i) + cache_misses(i);
    mem_spare(i) = (mem_accesses_baseline - mem_accesses(i)) / number_of_bdp;
    
    fclose(stats);
end

graphs.hit_rates     = str2double(hit_rates(1:length(hit_rates) - 1));
graphs.mem_spares    = mem_spare(1:length(mem_spare) - 1);
graphs.timings       = [1917.167, 1700.376, 1694.860, 1695.145, 1695.077, 1695.238];
graphs.cache_misses  = [cache_misses_baseline; cache_misses(1:length(cache_misses) - 1)];
graphs.xcache_misses = ["BL", hit_rates(1:length(hit_rates) - 1)];

% memory accesses spares
figure('Position', [699, 259, 280, 250]);
bar(graphs.mem_spares);
ylim([0, 0.6]);
yticks(linspace(0, 0.6, 7));
%ylim([min(graphs.mem_spares) - (max(graphs.mem_spares) - min(graphs.mem_spares)) * .1, max(graphs.mem_spares) + (max(graphs.mem_spares) - min(graphs.mem_spares)) * .1]);
%yticks(linspace(min(graphs.mem_spares) - (max(graphs.mem_spares) - min(graphs.mem_spares)) * .1, max(graphs.mem_spares) + (max(graphs.mem_spares) - min(graphs.mem_spares)) * .1, 7))
set(gca, 'xticklabel', graphs.hit_rates);
ytickformat('%.2f');
ylabel({"Relative memory"; "accesses reduction"});
xlabel("BPDE usage rate [%]");

set(findall(gcf,'-property','FontSize'),'FontSize',12)
saveas(gcf,'img/mem_spares.eps', 'epsc');

% timings
figure('Position', [699, 259, 280, 250]);
yyaxis left
bar(graphs.timings);
%ylim([0, max(graphs.timings) * 1.1]);
%ylim([min(graphs.timings) - (max(graphs.timings) - min(graphs.timings)) * .1, max(graphs.timings) + (max(graphs.timings) - min(graphs.timings)) * .1]);
ylim([1672,1936]);
%yticks(linspace(0, max(graphs.timings) * 1.1, 7))
%yticks(linspace(min(graphs.timings) - (max(graphs.timings) - min(graphs.timings)) * .1, max(graphs.timings) + (max(graphs.timings) - min(graphs.timings)) * .1, 7))
yticks(linspace(1672,1936,7));
%xlim([min(graphs.hit_rates), max(graphs.hit_rates)]);
%ytickformat('%.2f');
ylabel("Inference time [ms]");
yyaxis right
plot([1 2 3 4 5 6], abs(graphs.timings - graphs.timings(1)) * 100 / graphs.timings(1), '-o');
ylim([0, 12]);
yticks(linspace(0, 12, 7));
set(gca, 'xticklabel', graphs.xcache_misses);
%xticks(graphs.hit_rates);
ylabel("Performance gains [%]");
%annotation('doublearrow', [], []);
xlabel("BPDE usage rate [%]");

set(findall(gcf,'-property','FontSize'),'FontSize',12)
saveas(gcf, 'img/timings.eps', 'epsc');

% cache misses
figure('Position', [699, 259, 280, 300]);
bar(graphs.cache_misses);
ylim([min(graphs.cache_misses) - (max(graphs.cache_misses) - min(graphs.cache_misses)) * .1, max(graphs.cache_misses) + (max(graphs.cache_misses) - min(graphs.cache_misses)) * .1]);
yticks(linspace(min(graphs.cache_misses) - (max(graphs.cache_misses) - min(graphs.cache_misses)) * .1, max(graphs.cache_misses) + (max(graphs.cache_misses) - min(graphs.cache_misses)) * .1, 7))
set(gca, 'xticklabel', graphs.xcache_misses);
ytickformat('%.5f');
ylabel("L1 data cache misses");
xlabel("BPDE usage rate [%]");

annotation('line', [.38, .48], [.86, .86], 'LineStyle', '--');
annotation('doublearrow', [.435, .435], [.21, .86]);
annotation('textbox',[.35, .4, .25, .25],'String','\approx 0.01%','FitBoxToText','on','BackgroundColor','white');

set(findall(gcf,'-property','FontSize'),'FontSize',12)
saveas(gcf, 'img/cache_misses.eps', 'epsc');

%% Plot energy results
energy_results      = xlsread("power_calculation_fdsoi.xlsx", "Sheet1", "B14:H14");
energy_results_dram = xlsread("power_calculation_fdsoi.xlsx", "Sheet1", "B13:H13");

graphs.energy_results      = [energy_results(length(energy_results)), energy_results(1:length(energy_results) - 2)];
graphs.energy_results_dram = [energy_results_dram(length(energy_results_dram)), energy_results_dram(1:length(energy_results_dram) - 2)];

figure('Position', [699, 259, 280, 300]);
bar(graphs.energy_results);
ylim([min(graphs.energy_results) - (max(graphs.energy_results) - min(graphs.energy_results)) * .1, max(graphs.energy_results) + (max(graphs.energy_results) - min(graphs.energy_results)) * .1]);
yticks(linspace(min(graphs.energy_results) - (max(graphs.energy_results) - min(graphs.energy_results)) * .1, max(graphs.energy_results) + (max(graphs.energy_results) - min(graphs.energy_results)) * .1, 7))
set(gca, 'xticklabel', graphs.xcache_misses);
ytickformat('%.3f');
ylabel({"Total energy spent"; "excluding DRAM [J]"});
xlabel("BPDE usage rate [%]");

annotation('line', [.45, .55], [.859, .859], 'LineStyle', '--');
annotation('doublearrow', [.495, .495], [.225, .859]);
annotation('textbox',[.43, .25, .2, .35],'String','7.4%','FitBoxToText','on','BackgroundColor','white');

set(findall(gcf,'-property','FontSize'),'FontSize',12)
saveas(gcf, 'img/energy_results.eps', 'epsc');

figure('Position', [699, 259, 280, 300]);
bar(graphs.energy_results_dram);
ylim([min(graphs.energy_results_dram) - (max(graphs.energy_results_dram) - min(graphs.energy_results_dram)) * .1, max(graphs.energy_results_dram) + (max(graphs.energy_results_dram) - min(graphs.energy_results_dram)) * .1]);
yticks(linspace(min(graphs.energy_results_dram) - (max(graphs.energy_results_dram) - min(graphs.energy_results_dram)) * .1, max(graphs.energy_results_dram) + (max(graphs.energy_results_dram) - min(graphs.energy_results_dram)) * .1, 7))
set(gca, 'xticklabel', graphs.xcache_misses);
ytickformat('%.3f');
ylabel("Total energy spent [J]");
xlabel("BPDE usage rate [%]");

annotation('line', [.4, .5], [.859, .859], 'LineStyle', '--');
annotation('doublearrow', [.45, .45], [.225, .859]);
annotation('textbox',[.38, .25, .2, .35],'String','40.51 mJ','FitBoxToText','on','BackgroundColor','white');

set(findall(gcf,'-property','FontSize'),'FontSize',12)
saveas(gcf, 'img/energy_results_dram.eps', 'epsc');