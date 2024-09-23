addpath(genpath("../utils/"), genpath("../global_planner/"));

clear all; clc;

% Set a random seed for reproducibility
rng(42);  % Set a seed to get the same random points every time

% Load environment
load("warehouse.mat");
map_size = size(warehouse);  % Use 'warehouse' as the map variable

% Assume that 1 represents free space and 2 represents obstacles.
free_space_value = 1;

G = 1;

% Simulation mode
mode = "static";

% Number of runs and algorithms
num_runs = 40;  % Set to 30 runs with random start points and a fixed goal point
algorithms = {'dijkstra', 'a_star', 'gbfs', 'jps'}; 
num_algorithms = length(algorithms);

% Pre-allocate arrays to store path lengths and times for each algorithm
path_lengths = zeros(num_runs, num_algorithms);
times = zeros(num_runs, num_algorithms);

% Define a time limit for each algorithm per run (in seconds)
time_limit = 5;  % Set a time limit for each algorithm

% Find all free spaces in the warehouse map
[free_rows, free_cols] = find(warehouse == free_space_value); 
free_spaces = [free_rows, free_cols];  % Combine rows and columns into a list of free spaces
num_free_spaces = size(free_spaces, 1);  % Define num_free_spaces based on free spaces

if num_free_spaces == 0
    error('No free spaces available in the grid.');
end

% Set a fixed goal point at (19, 29)
fixed_goal = [19, 29];  % Manually set the fixed goal point

% Generate random start points for each run (with fixed goal point)
start_points = zeros(num_runs, 2);
for i = 1:num_runs
    % Generate random start points from the free spaces
    rand_idx_start = randi(num_free_spaces);  % Pick random start point
    start_points(i, :) = free_spaces(rand_idx_start, :);  
end

% Run each algorithm with the same start points and fixed goal point
paths = cell(num_runs, num_algorithms);  % Store paths for visualization
for j = 1:num_algorithms
    planner_name = algorithms{j};
    planner = str2func(planner_name);  % Convert to function handle
    
    for i = 1:num_runs
        start = start_points(i, :);
        goal = fixed_goal;
        tic;  % Start timer
        
        % Run the algorithm and stop if it takes too long
        try
            [path, flag, ~, expand] = planner(warehouse, start, goal);  % Use 'warehouse' here
        catch
            warning(['Error running ', planner_name, ' on run ', num2str(i)]);
            continue;  % Skip this iteration if the algorithm fails
        end
        
        elapsed_time = toc;  % Measure elapsed time
        
        if elapsed_time > time_limit
            warning(['Algorithm ', planner_name, ' exceeded time limit on run ', num2str(i)]);
            continue;  % Skip if time limit is exceeded
        end
        
        times(i, j) = elapsed_time;  % Store the elapsed time
        
        % Calculate path length
        if isempty(path)
            path_lengths(i, j) = 0;
        else
            path_lengths(i, j) = length(path);
            paths{i, j} = path;  % Store the path for visualization
        end
    end
end

% Calculate mean values
mean_path_lengths = mean(path_lengths);
mean_times = mean(times);

% Create a table to display the results
algorithm_names = {'Dijkstra', 'A*', 'GBFS', 'JPS'}';
result_table = table(algorithm_names, mean_path_lengths', mean_times', ...
                     'VariableNames', {'Algorithm', 'MeanPathLength', 'MeanTime'});

% Display the table
disp(result_table);

% Plot the warehouse map with start and fixed goal for each run
figure;
imagesc(warehouse);  % Display the warehouse map
hold on;
colormap("sky");  
axis equal;
title('Warehouse Map with Paths for Different Start Points and Fixed Goal (19, 29)');
xlabel('X');
ylabel('Y');

% Plot start and goal points with specific colors and shapes
for i = 1:num_runs
    plot(fixed_goal(2), fixed_goal(1), 'r*', 'MarkerSize', 10);  % Plot goal (red star)
    plot(start_points(i, 2), start_points(i, 1), 'bo', 'MarkerSize', 8);  % Plot start points (blue circle)
end

% Assign colors: A* = blue, Dijkstra = green, GBFS = red, JPS = cyan
algorithm_colors = {'g', 'b', 'r', 'c'}; 

% Plot paths for each algorithm with assigned colors
for j = 1:num_algorithms
    for i = 1:num_runs
        if ~isempty(paths{i, j})
            path = paths{i, j};
            
            % Interpolate with cubic spline to smooth the path
            t = 1:length(path);
            t_interp = linspace(1, length(path), 100);  % 100 interpolated points
            path_interp = interp1(t, path, t_interp, 'spline');  % Spline interpolation
            
            plot(path_interp(:, 2), path_interp(:, 1), algorithm_colors{j}, 'LineWidth', 2);  % Plot the smoothed path with color
        end
    end
end

% Update the legend for the current plot
    legend({'Goal (red star)', 'Start (blue circle)', 'Dijkstra', 'A*', 'GBFS', 'JPS'}, 'Location', 'best');
hold off;

% Plot the path lengths for all algorithms in one bar chart
figure;
bar(path_lengths);
xlabel('Run Number');
ylabel('Path Length');
title('Path Length per Run for Different Algorithms');
legend(algorithms, 'Location', 'best');
xticks(1:num_runs);

% Plot histogram for path lengths with clearer heights and separate colors
figure;
for j = 1:num_algorithms
    subplot(1, num_algorithms, j);
    histogram(path_lengths(:, j), 'FaceColor', algorithm_colors{j}, 'EdgeColor', 'k');  % Set color for each algorithm
    title(['Path Length Histogram - ' algorithms{j}]);
    xlabel('Path Length');
    ylabel('Frequency');
end
set(gcf, 'Position', [100, 100, 800, 400]);  % Resize the figure for better clarity

% Plot the times for all algorithms in a separate figure with smaller histogram bars
figure;
bar(times, 'BarWidth', 0.4);  % Set a smaller bar width for clarity
xlabel('Run Number');
ylabel('Time (seconds)');
title('Time Taken per Run for Different Algorithms');
legend(algorithms, 'Location', 'best');
xticks(1:num_runs);
set(gcf, 'Position', [100, 100, 800, 400]);  % Resize the figure for better clarity


% Calculate and plot CDF for path lengths
figure;
for j = 1:num_algorithms
    % Sort the path lengths for algorithm j
    sorted_lengths = sort(path_lengths(:, j));
    % Calculate cumulative probabilities
    cum_prob = (1:num_runs) / num_runs;
    
    % Plot the CDF
    subplot(1, num_algorithms, j);
    plot(sorted_lengths, cum_prob, 'LineWidth', 2);
    xlabel('Path Length');
    ylabel('CDF');
    title(['CDF of Path Lengths - ' algorithms{j}]);
end

% Calculate and plot CDF for times
figure;
for j = 1:num_algorithms
    % Sort the times for algorithm j
    sorted_times = sort(times(:, j));
    % Calculate cumulative probabilities
    cum_prob = (1:num_runs) / num_runs;
    
    % Plot the CDF
    subplot(1, num_algorithms, j);
    plot(sorted_times, cum_prob, 'LineWidth', 2);
    xlabel('Time (seconds)');
    ylabel('CDF');
    title(['CDF of Times - ' algorithms{j}]);
end
