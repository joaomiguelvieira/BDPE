clc
clearvars

%% obtain baseline
% initialize arrays
cache_hits_baseline   = 0;
cache_misses_baseline = 0;
number_of_bdp         = 42658304;

% extract information from the gem5 output file
stats = fopen("darknet_baseline_separate_file_out/stats.txt");

line = fgetl(stats);
while ischar(line)
    if contains(line, "system.cpu.dcache.ReadReq_hits::total")
        words = strsplit(line);
        cache_hits_baseline = str2double(words(2));
    end

    if contains(line, "system.cpu.dcache.ReadReq_misses::total")
        words = strsplit(line);
        cache_misses_baseline = str2double(words(2));
    end

    line = fgetl(stats);
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
    
    line = fgetl(stats);
    while ischar(line)
        if contains(line, "system.cpu.dcache.ReadReq_hits::total")
            words = strsplit(line);
            cache_hits(i) = str2double(words(2));
        end
        
        if contains(line, "system.cpu.dcache.ReadReq_misses::total")
            words = strsplit(line);
            cache_misses(i) = str2double(words(2));
        end
        
        line = fgetl(stats);
    end
    
    mem_accesses(i) = cache_hits(i) + cache_misses(i);
    mem_spare(i) = (mem_accesses_baseline - mem_accesses(i)) / number_of_bdp;
    
    fclose(stats);
end

plot.hit_rates     = str2double(hit_rates(1:length(hit_rates) - 1));
plot.mem_spares    = mem_spare(1:length(mem_spare) - 1);
plot.timings       = [1700.376, 1694.860, 1695.145, 1695.077, 1695.238];
plot.cache_misses  = [cache_misses_baseline; cache_misses(1:length(cache_misses) - 1)];
plot.xcache_misses = ["Baseline", hit_rates(1:length(hit_rates) - 1)];
