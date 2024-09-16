addpath(genpath("../utils/"), genpath("../global_planner/"));

clear all; clc;

% Load environment
load("warehouse.mat");
map_size = size(warehouse);
disp(map_size(1))
G = 1;

% Simulation mode
mode = "static";

% Number of runs and algorithms
num_runs = 5;
algorithms = {'dijkstra', 'a_star', 'gbfs'};  % The three algorithms
num_algorithms = length(algorithms);  % Total number of algorithms

% Pre-allocate arrays to store path lengths for each algorithm
path_lengths = zeros(num_runs, num_algorithms);  % Store the path lengths for each algorithm

goal = [18, 29];  % Goal position
map_size = size(grid_map);  % Size of the grid map

% Generate random start points for each run
start_points = zeros(num_runs, 2);  % Store start points
for i = 1:num_runs
    start_points(i, :) = [randi(map_size(1)), randi(map_size(2))];  % Random start
end

% Run each algorithm with the same start points
for j = 1:num_algorithms
    planner_name = algorithms{j};  % Get the algorithm name
    planner = str2func(planner_name);  % Convert to function handle
    
    for i = 1:num_runs
        start = start_points(i, :);  % Get the start point for this run
        [path, flag, cost, expand] = planner(grid_map, start, goal);  % Call the planner
        
        % Calculate and store the path length (number of nodes in path)
        if isempty(path)
            path_lengths(i, j) = 0;  % No path found, set length to 0
        else
            path_lengths(i, j) = length(path);  % Path length is the number of nodes
        end
    end
end

% Calculate statistics for path lengths
mean_path_lengths = mean(path_lengths);
median_path_lengths = median(path_lengths);

% Sjekk at det finnes gyldige path_lengths før du beregner modus
mode_path_lengths = zeros(1, num_algorithms);
for j = 1:num_algorithms
    valid_lengths = path_lengths(:, j);
    valid_lengths = valid_lengths(valid_lengths > 0);  % Filtrer ut null-verdier
    
    % Sjekk antall gyldige lengder
    if isempty(valid_lengths)
        mode_path_lengths(j) = NaN;  % Sett modus til NaN hvis ingen gyldige lengder
    elseif length(valid_lengths) == 1
        mode_path_lengths(j) = valid_lengths;  % Hvis det er bare ett element, returner det
  
    end
end

% Display the statistics for path lengths
disp('Mean path lengths:');
disp(mean_path_lengths);

disp('Median path lengths:');
disp(median_path_lengths);

disp('Mode of path lengths:');
disp(mode_path_lengths);

% Plot the path lengths for all algorithms in one bar chart
figure;
bar(path_lengths);  % Create a bar chart for path lengths
xlabel('Run Number');
ylabel('Path Length');
title('Path Length per Run for Different Algorithms');
legend(algorithms, 'Location', 'best');  % Add a legend for algorithms
xticks(1:num_runs);  % Set x-ticks to match run numbers